// service/assistant_agent.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gemini_quiz_service.dart';

class AssistantAgent {
  final String uid;
  final GeminiQuizService gemini;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AssistantAgent({required this.uid, required this.gemini});

  /// 1. 습관 리스트 불러오기
  Future<List<String>> fetchUserHabits() async {
    final ref = _firestore.collection('users').doc(uid).collection('habits');
    final snap = await ref.get();
    return snap.docs.map((doc) => doc['title'].toString()).toList();
  }

  /// 2. 습관 확인 질문 생성
  Future<String?> generateHabitQuestion(List<String> habits) async {
    final prompt = '''
당신은 사용자의 말벗 AI입니다.

아래는 사용자가 평소 등록한 습관 리스트입니다:
${habits.map((h) => '- $h').join('\n')}

이 중 오늘 완료했는지 자연스럽게 물어보는 질문을 1문장 생성하세요. 예: "오늘 산책은 하셨어요?"
''';
    return await gemini.generateQuizQuestion([prompt]);
  }

  /// 3. 감정 상태 질문 생성
  Future<String> generateMoodCheck() async {
    return '오늘 기분은 어떠셨어요?'; // 고정 질문 or Gemini 이용 가능
  }

  /// 4. 문장 완성도 평가 (간단 분석)
  String evaluateSentenceQuality(String input) {
    if (input.trim().length < 8) return '말씀이 조금 짧은 것 같아요. 더 자세히 이야기해보실래요?';
    if (input.contains(RegExp(r'[ㄱ-ㅎㅏ-ㅣ]'))) return '조금 더 또렷하게 말씀해주시면 좋을 것 같아요.';
    return '말씀 감사합니다. 잘 들었습니다.';
  }

  /// 5. 대화 내역 저장
  Future<void> saveChatLog(String sender, String text) async {
    final ref = _firestore.collection('users').doc(uid).collection('chatlog');
    await ref.add({
      'sender': sender,
      'text': text,
      'timestamp': Timestamp.now(),
    });
  }

  /// 6. 퀴즈 출제
  Future<Map<String, String>> generateQuiz() async {
    // 추후 Gemini로 다양화 가능
    final prompt = '''
        넌센스 퀴즈를 하나 출제해 주세요. 다음 형식으로 답변하세요:

        문제: 세상에서 가장 뜨거운 바다는?
        정답: 열받아
        ''';

    final raw = await gemini.generateQuizQuestion([prompt]);

    if (raw == null) {
      return {
        'question': '세상에서 가장 뜨거운 바다는?',
        'answer': '열받아',
      }; // 기본 문제 fallback
    }

    final lines = raw.split('\n');
    final questionLine = lines.firstWhere((l) => l.startsWith('문제:'), orElse: () => '');
    final answerLine = lines.firstWhere((l) => l.startsWith('정답:'), orElse: () => '');

    final question = questionLine.replaceFirst('문제:', '').trim();
    final answer = answerLine.replaceFirst('정답:', '').trim();

    return {
      'question': question.isEmpty ? '세상에서 가장 뜨거운 바다는?' : question,
      'answer': answer.isEmpty ? '열받아' : answer,
    };

  }

  /// 7. 정답 평가
  bool evaluateAnswer(String userAnswer, String correctAnswer) {
    return userAnswer.trim().replaceAll(' ', '') == correctAnswer.trim().replaceAll(' ', '');
  }

  /// 8. 퀴즈 결과 저장
  Future<void> saveQuizResult({
    required String question,
    required String correctAnswer,
    required String userAnswer,
    required bool isCorrect,
  }) async {
    final ref = _firestore.collection('users').doc(uid).collection('quizResults');
    await ref.add({
      'question': question,
      'correctAnswer': correctAnswer,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'timestamp': Timestamp.now(),
    });
  }
}

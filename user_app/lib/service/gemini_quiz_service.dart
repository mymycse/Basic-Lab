import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiQuizService {
  final String apiKey;

  GeminiQuizService(this.apiKey);

  Future<String?> generateQuizQuestion(List<String> chatHistory) async {
    final prompt = _buildPrompt(chatHistory);

    final response = await http.post(
      Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBdNr19RUY83Ip9rf3Q-ApIpawj52igtHE'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {
                'text': prompt
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'];
      return text?.trim();
    } else {
      print('Gemini API error: ${response.body}');
      return null;
    }
  }

  String _buildPrompt(List<String> messages) {
    final buffer = StringBuffer();
    buffer.writeln("다음 대화 내용을 기반으로, 어르신의 기억을 확인하거나 안부를 물을 수 있는 자연스러운 질문을 한 문장으로 생성해 주세요.\n");

    for (var m in messages) {
      buffer.writeln("- $m");
    }

    buffer.writeln("\n단 하나의 질문만 출력해 주세요. 예: '오늘 점심은 드셨나요?' 혹은 '어제 병원에서 어떤 진료를 받으셨죠?'");
    return buffer.toString();
  }
}

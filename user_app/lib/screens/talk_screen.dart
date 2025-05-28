import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import '../service/gemini_quiz_service.dart';
import '../service/assistant_agent.dart';

class TalkScreen extends StatefulWidget {
  final bool isQuizMode;
  const TalkScreen({super.key, this.isQuizMode = false});

  @override
  State<TalkScreen> createState() => _TalkScreenState();
}

class _TalkScreenState extends State<TalkScreen> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final GeminiQuizService _gemini = GeminiQuizService('YOUR_GEMINI_API_KEY');
  late final AssistantAgent _agent;
  late final String _uid;

  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    _agent = AssistantAgent(uid: _uid, gemini: _gemini);
    _initTTS();
    _startConversation(); // 진입 시 자동 시작
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
    await _agent.saveChatLog('AI', text);
  }

  Future<void> _startConversation() async {
    await _startListening();
    if (!widget.isQuizMode) {
      final mood = await _agent.generateMoodCheck();
      await _speak(mood);

      final habits = await _agent.fetchUserHabits();
      if (habits.isNotEmpty) {
        final q = await _agent.generateHabitQuestion(habits);
        if (q != null) await _speak(q);
      }
    }
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize();
    if (!available) return;

    setState(() => _listening = true);
    _speech.listen(
      localeId: 'ko_KR',
      onResult: (result) {
        setState(() => _listening = false);
        _handleSpeechResult(result.recognizedWords);
      },
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    await _tts.stop();
    setState(() => _listening = false);
  }

  void _handleSpeechResult(String result) {
    _agent.saveChatLog('사용자', result);
    final feedback = _agent.evaluateSentenceQuality(result);
    _speak(feedback);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _listening ? Colors.green[600] : Colors.green[100];
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('대화하기', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green[700],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 마이크 버튼
            Container(
              width: screenWidth * 0.7,
              height: screenWidth * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _listening ? Colors.green : Colors.green[300],
              ),
              child: Icon(
                Icons.mic,
                size: screenWidth * 0.3,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // 대화 중단 or 시작 버튼
            ElevatedButton(
              onPressed: _listening ? _stopListening : _startConversation,
              style: ElevatedButton.styleFrom(
                backgroundColor: _listening ? Colors.red : Colors.green[700],
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                _listening ? '대화 중단' : '대화 시작',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

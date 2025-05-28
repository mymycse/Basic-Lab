import 'package:flutter/material.dart';
import 'talk_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('퀴즈 시작'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TalkScreen(isQuizMode: true),
              ),
            );
          },
        ),
      ),
    );
  }
}

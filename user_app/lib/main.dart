import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'utils/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/talk_screen.dart';
import 'screens/routine_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/chat_log_screen.dart';
import 'screens/setting_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '말벗',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'GmarketSans',
      ),
      home: const HomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/talk': (context) => const TalkScreen(),
        '/routine': (context) => const RoutineScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/chatlog': (context) => const ChatLogScreen(),
        '/settings': (context) => const SettingScreen(),
      },
    );
  }
}

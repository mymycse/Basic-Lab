import 'package:flutter/material.dart';
import 'package:user_app/screens/home_screen.dart';
import 'package:user_app/screens/signup_screen.dart';
import 'package:user_app/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _id = TextEditingController();
  final _pw = TextEditingController();
  String _errorMessage = '';

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    final userId = _id.text.trim();
    final password = _pw.text.trim();

    final user = await _auth.loginUserWithIdAndPassword(userId, password);

    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => _errorMessage = '로그인 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/logo.png', height: 150),

            const SizedBox(height: 30),

            TextField(
              controller: _id,
              decoration: const InputDecoration(
                labelText: '아이디',
                prefixIcon: Icon(Icons.person),
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pw,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: '비밀번호',
                prefixIcon: Icon(Icons.lock),
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            OutlinedButton(
              onPressed: _handleAuth,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal,
                side: const BorderSide(color: Colors.teal),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('로그인', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 24),

            const Text('계정 새로 생성하기', style: TextStyle(fontSize: 14, color: Colors.black)),

            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('회원가입', style: TextStyle(fontSize: 14)),
            ),

            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

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
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _id,
              decoration: const InputDecoration(labelText: '아이디', isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pw,
              decoration: const InputDecoration(labelText: '비밀번호', isDense: true),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _handleAuth,
              child: const Text('로그인'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text('회원가입'),
            ),
            const SizedBox(height: 8),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}

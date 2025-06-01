import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_app/screens/home_screen.dart';
import 'package:user_app/service/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();

  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _name = TextEditingController();
  final _rrnFront = TextEditingController();
  final _rrnBack = TextEditingController();
  final _phone1 = TextEditingController();
  final _phone2 = TextEditingController();
  final _phone3 = TextEditingController();

  final _rrnBackFocus = FocusNode();
  final _phone2Focus = FocusNode();
  final _phone3Focus = FocusNode();

  bool _agreePrivacy = false;
  bool _agreePush = false;
  int _currentStep = 0;
  String _errorMessage = '';

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    _name.dispose();
    _rrnFront.dispose();
    _rrnBack.dispose();
    _phone1.dispose();
    _phone2.dispose();
    _phone3.dispose();
    _rrnBackFocus.dispose();
    _phone2Focus.dispose();
    _phone3Focus.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreePrivacy) {
      setState(() => _errorMessage = '개인정보 처리방침에 동의해주세요.');
      return;
    }

    final userId = _id.text.trim();
    final password = _pw.text.trim();

    try {
      final user = await _auth.createUserWithEmailAndPassword(userId, password);

      if (user != null && mounted) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'id': userId,
          'name': _name.text.trim(),
          'rrn': '${_rrnFront.text.trim()}-${_rrnBack.text.trim()}',
          'phone': '${_phone1.text.trim()}-${_phone2.text.trim()}-${_phone3.text.trim()}',
          'agreePush': _agreePush,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessage = '이미 사용 중인 아이디입니다.';
        } else if (e.code == 'weak-password') {
          _errorMessage = '비밀번호는 최소 6자 이상이어야 합니다.';
        } else {
          _errorMessage = '회원가입 실패 (${e.code})';
        }
      });
    } catch (e) {
      setState(() => _errorMessage = '알 수 없는 오류가 발생했습니다.');
    }
  }

  Widget _buildRrnInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('주민등록번호', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _rrnFront,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(counterText: '', isDense: true),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.length == 6) {
                    FocusScope.of(context).requestFocus(_rrnBackFocus);
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('-', style: TextStyle(fontSize: 16)),
            ),
            SizedBox(
              width: 50,
              child: TextField(
                controller: _rrnBack,
                maxLength: 1,
                focusNode: _rrnBackFocus,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(counterText: '', isDense: true),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 6),
            const Text('●●●●●●', style: TextStyle(fontSize: 20, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('전화번호', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 70,
              child: TextField(
                controller: _phone1,
                maxLength: 3,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(counterText: '', hintText: '010', isDense: true, hintStyle: TextStyle(color: Colors.grey),),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.length == 3) {
                    FocusScope.of(context).requestFocus(_phone2Focus);
                  }
                },
              ),
            ),
            const Text('-'),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _phone2,
                maxLength: 4,
                textAlign: TextAlign.center,
                focusNode: _phone2Focus,
                decoration: const InputDecoration(counterText: '', hintText: '0000', isDense: true, hintStyle: TextStyle(color: Colors.grey),),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if (val.length == 4) {
                    FocusScope.of(context).requestFocus(_phone3Focus);
                  }
                },
              ),
            ),
            const Text('-'),
            SizedBox(
              width: 80,
              child: TextField(
                controller: _phone3,
                maxLength: 4,
                textAlign: TextAlign.center,
                focusNode: _phone3Focus,
                decoration: const InputDecoration(counterText: '', hintText: '0000', isDense: true, hintStyle: TextStyle(color: Colors.grey),),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('회원가입', style: TextStyle(color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep += 1);
                  } else {
                    _handleSignup();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  } else {
                    Navigator.pop(context);
                  }
                },
                controlsBuilder: (context, details) {
                  return Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text('확인'),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: details.onStepCancel,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                            ),
                            child: const Text('취소'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
                steps: [
                  Step(
                    title: const Text('계정 정보'),
                    content: Column(
                      children: [
                        TextField(
                          controller: _id,
                          decoration: const InputDecoration(
                            labelText: '아이디',
                            isDense: true,
                            labelStyle: TextStyle(color: Colors.black87),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _pw,
                          decoration: const InputDecoration(
                            labelText: '비밀번호',
                            isDense: true,
                            labelStyle: TextStyle(color: Colors.black87),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(color: Colors.black),

                          obscureText: true,
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                  ),
                  Step(
                    title: const Text('개인 정보'),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _name,
                          keyboardType: TextInputType.name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: '이름',
                            isDense: true,
                            labelStyle: TextStyle(color: Colors.black87),
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          style: const TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        _buildRrnInput(),
                        const SizedBox(height: 8),
                        _buildPhoneInput(),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                  ),
                  Step(
                    title: const Text('동의사항'),
                    content: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text(
                            '[필수] 개인정보 처리방침 동의',
                            style: TextStyle(color: Colors.black87),
                          ),
                          value: _agreePrivacy,
                          tileColor: Colors.transparent,
                          onChanged: (val) => setState(() => _agreePrivacy = val!),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: Colors.teal,
                          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.teal;
                            }
                            return Colors.transparent;
                          }),
                        ),
                        CheckboxListTile(
                          title: const Text(
                            '[선택] 푸시 알림 수신 동의',
                            style: TextStyle(color: Colors.black87),
                          ),
                          value: _agreePush,
                          tileColor: Colors.transparent,
                          onChanged: (val) => setState(() => _agreePush = val!),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: Colors.teal,
                          fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.teal;
                            }
                            return Colors.transparent;
                          }),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 2,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}
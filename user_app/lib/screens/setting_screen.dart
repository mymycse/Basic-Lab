import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
  late DocumentReference userRef;

  Map<String, dynamic>? userData;
  String? selectedVoice;

  @override
  void initState() {
    super.initState();
    userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final snapshot = await userRef.get();
    if (snapshot.exists) {
      setState(() {
        userData = snapshot.data() as Map<String, dynamic>;
        selectedVoice = userData?['voiceChoice'] ?? '딸';
      });
    }
  }

  void _updateVoice(String? value) {
    if (value != null) {
      setState(() {
        selectedVoice = value;
      });
      userRef.update({'voiceChoice': value});
    }
  }

  String _getGenderFromRRN(String? rrn) {
    if (rrn == null || !rrn.contains('-')) return '-';
    final back = rrn.split('-')[1];
    if (back.isEmpty) return '-';
    final firstDigit = int.tryParse(back[0]);
    if (firstDigit == null) return '-';
    return (firstDigit % 2 == 0) ? '여' : '남';
  }

  String _getBirthFromRRN(String? rrn) {
    if (rrn == null || !rrn.contains('-')) return '-';
    final front = rrn.split('-')[0];
    final back = rrn.split('-')[1];
    if (front.length != 6 || back.isEmpty) return '-';
    final yearPrefix = (back[0] == '1' || back[0] == '2' || back[0] == '5' || back[0] == '6') ? '19' : '20';
    final year = '$yearPrefix${front.substring(0, 2)}';
    final month = front.substring(2, 4);
    final day = front.substring(4, 6);
    return '$year.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final guardianData = userData?['guardian'] as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xCC1ea698),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내 정보', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _infoTile('이름', userData?['name']),
            _infoTile('성별', _getGenderFromRRN(userData?['rrn'])),
            _infoTile('생년월일', _getBirthFromRRN(userData?['rrn'])),
            _infoTile('전화번호', userData?['phone']),
            const Divider(height: 32, color: Colors.grey), // 실선 추가

            const Text('보호자 정보', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _infoTile('이름', guardianData?['name']),
            _infoTile('전화번호', guardianData?['phone']),
            _infoTile('관계', guardianData?['relation']),
            const Divider(height: 32, color: Colors.grey), // 실선 추가

            const Text('음성 선택', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedVoice,
              items: ['딸', '남편', '손녀'].map((v) {
                return DropdownMenuItem(value: v, child: Text(v));
              }).toList(),
              onChanged: _updateVoice,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const Spacer(), // 남은 공간 차지해서 로그아웃 버튼을 아래로 내림

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                await Future.delayed(const Duration(milliseconds: 100));
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Center(
                child: Text('로그아웃', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 20)),
      trailing: Text(value ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  String _makeEmail(String userId) => '$userId@remember.com';

  // 회원가입
  Future<User?> createUserWithEmailAndPassword(
      String userId, String password) async {
    try {
      final email = _makeEmail(userId);
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      // 역할 저장
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'role': 'user',
        'createdAt': DateTime.now(),
      });

      return cred.user;
    } on FirebaseAuthException catch (e) {
      print('회원가입 오류: ${e.code} - ${e.message}');
      return null;
    }
  }

  // 로그인
  Future<User?> loginUserWithIdAndPassword(
      String userId, String password) async {
    try {
      final email = _makeEmail(userId);
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      print('로그인 오류: ${e.code} - ${e.message}');
    }
    return null;
  }

  // 역할 조회
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'];
      } else {
        return null;
      }
    } catch (e) {
      print('역할 조회 오류: $e');
      return null;
    }
  }

  Future<void> signout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('로그아웃 오류: $e');
    }
  }

  User? get currentUser => _auth.currentUser;
}

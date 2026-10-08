import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseFirestore.instance;

  static Future<void> login(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  /// สมัครใหม่ได้เป็น 'Operator' เท่านั้น (เปลี่ยนเป็น Admin ได้ที่ Firestore)
  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    await _db.collection('users').doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'name': name.trim(),
      'email': email.trim(),
      'role': 'Operator',
    });
  }

  static Future<void> signOut() => _auth.signOut();

  static String message(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'email-already-in-use':
        return 'อีเมลนี้สมัครไว้แล้ว ให้เข้าสู่ระบบแทน';
      case 'weak-password':
        return 'รหัสผ่านสั้นเกินไป ใช้อย่างน้อย 6 ตัวอักษร';
      case 'network-request-failed':
        return 'ไม่มีอินเทอร์เน็ต ตรวจสอบการเชื่อมต่อแล้วลองใหม่';
      case 'operation-not-allowed':
        return 'ยังไม่ได้เปิด Email/Password ใน Firebase Authentication';
      default:
        return 'เข้าสู่ระบบไม่สำเร็จ (${e.code})';
    }
  }
}

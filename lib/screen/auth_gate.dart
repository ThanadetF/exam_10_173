import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/app_user.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import 'home_screen.dart';
import 'login_screen.dart';

/// ตัวตัดสินว่าจะแสดงหน้าไหน: ยังไม่ล็อกอิน -> Login, ล็อกอินแล้ว -> อ่าน role จาก Firestore
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading(text: 'กำลังเริ่มระบบ');
        }
        final user = authSnap.data;
        if (user == null) return const LoginScreen();

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return _Loading(
                  text: 'อ่านข้อมูลผู้ใช้ไม่สำเร็จ: ${snap.error}',
                  showLogout: true);
            }
            if (!snap.hasData || !snap.data!.exists) {
              return const _Loading(
                  text: 'กำลังโหลดสิทธิ์ของผู้ใช้', showLogout: true);
            }
            return HomeScreen(user: AppUser.fromDoc(snap.data!));
          },
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  final String text;
  final bool showLogout;
  const _Loading({required this.text, this.showLogout = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandLogo(size: 72),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.steel)),
              if (showLogout)
                TextButton(
                    onPressed: AuthController.signOut,
                    child: const Text('Sign Out')),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../model/app_user.dart';
import '../theme/app_theme.dart';

/// มุมขวา AppBar: ป้ายสิทธิ์ (Admin/Operator) + ปุ่ม Sign Out
class ProfileMenu extends StatelessWidget {
  final AppUser user;
  const ProfileMenu({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final c = user.isAdmin ? AppColors.warn : AppColors.signal;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: user.email,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.withAlpha(150)),
            ),
            child: Text(user.roleLabel,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: c)),
          ),
        ),
        IconButton(
          tooltip: 'Sign Out',
          icon: const Icon(Icons.logout),
          onPressed: AuthController.signOut,
        ),
      ],
    );
  }
}

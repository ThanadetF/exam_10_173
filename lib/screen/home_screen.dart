import 'package:flutter/material.dart';
import '../model/app_user.dart';
import '../theme/app_theme.dart';
import 'display.dart';
import 'formscreen.dart';

class HomeScreen extends StatelessWidget {
  final AppUser user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(
          children: [
            FormScreen(user: user),
            DisplayScreen(user: user),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: const SafeArea(
            top: false,
            child: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.edit_note), text: 'บันทึกผลวินิจฉัย'),
                Tab(
                    icon: Icon(Icons.warning_amber_rounded),
                    text: 'รายการเฝ้าระวัง'),
              ],
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.steel,
              indicatorColor: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

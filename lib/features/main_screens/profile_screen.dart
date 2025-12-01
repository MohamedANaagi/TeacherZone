import 'package:flutter/material.dart';
import '../../../core/styling/app_color.dart';

import 'main_widgets/primary_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(title: 'الملف الشخصي'),
      backgroundColor: AppColors.secondaryColor,
      body: const Center(
        child: Text('بيانات الطالب / الإعدادات'),
      ),
    );
  }
}

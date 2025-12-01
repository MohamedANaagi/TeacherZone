import 'package:flutter/material.dart';
import '../../../core/styling/app_color.dart';

import 'main_widgets/primary_app_bar.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PrimaryAppBar(title: 'الكورسات'),
      backgroundColor: AppColors.secondaryColor,
      body: const Center(
        child: Text('هنا هتظهر قائمة الكورسات للطالب'),
      ),
    );
  }
}

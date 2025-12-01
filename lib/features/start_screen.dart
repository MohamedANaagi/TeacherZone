import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/styling/app_color.dart';
import '../../../core/styling/app_styles.dart';




class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();

    // بعد 3 ثواني روح لصفحة الكود
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      context.go('/OnBoardingScreen');

    }
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // كله mainColor
      body: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Text(
            'TeacherZone',
            style: AppStyles.mainTextStyle.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 36,
            ),
          ),
        ),
      ),
    );
  }
}

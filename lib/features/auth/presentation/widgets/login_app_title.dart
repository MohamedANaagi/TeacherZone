import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

/// Widget لعرض عنوان التطبيق مع تأثيرات animation
/// يعرض اسم التطبيق "TeacherZone" مع تأثيرات fade و slide
class LoginAppTitle extends StatelessWidget {
  /// Animation للتأثير fade (الشفافية)
  final Animation<double> fadeAnimation;

  /// Animation للتأثير slide (الانزلاق)
  final Animation<Offset> slideAnimation;

  const LoginAppTitle({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: Text(
            'TeacherZone',
            textAlign: TextAlign.center,
            style: AppStyles.mainTextStyle.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: AppColors.secondaryColor.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

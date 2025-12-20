import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';

/// Widget لعرض شعار التطبيق مع تأثيرات بصرية
/// يعرض أيقونة التطبيق داخل دائرة مزخرفة مع shadow
class LoginAppLogo extends StatelessWidget {
  /// Animation للتأثير fade (الشفافية)
  final Animation<double> fadeAnimation;

  /// Animation للتأثير scale (التكبير/التصغير)
  final Animation<double> scaleAnimation;

  const LoginAppLogo({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: scaleAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryColor.withOpacity(0.2),
              border: Border.all(color: AppColors.secondaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.school,
              size: 50,
              color: AppColors.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

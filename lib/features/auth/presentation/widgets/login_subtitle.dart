import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

/// Widget لعرض النص التوضيحي أسفل عنوان التطبيق
/// يعرض رسالة ترحيبية مع تأثيرات animation
class LoginSubtitle extends StatelessWidget {
  /// Animation للتأثير fade (الشفافية)
  final Animation<double> fadeAnimation;

  /// Animation للتأثير slide (الانزلاق)
  final Animation<Offset> slideAnimation;

  const LoginSubtitle({
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
            'أدخل بياناتك للدخول',
            textAlign: TextAlign.center,
            style: AppStyles.subTextStyle.copyWith(
              fontSize: 16,
              color: AppColors.secondaryColor.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}

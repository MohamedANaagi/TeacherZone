import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

/// Widget لزر تسجيل الدخول مع تأثيرات animation و loading state
/// يعرض زر الدخول مع إمكانية عرض حالة التحميل
class LoginButton extends StatelessWidget {
  /// Callback يتم استدعاؤها عند الضغط على الزر
  final VoidCallback? onPressed;

  /// حالة التحميل - إذا كانت true يعرض CircularProgressIndicator
  final bool isLoading;

  /// Animation للتأثير fade (الشفافية)
  final Animation<double> fadeAnimation;

  /// Animation Controller للتأثير slide
  final AnimationController slideController;

  /// Animation Controller للتأثير fade
  final AnimationController fadeController;

  /// Animation للتأثير scale (التكبير/التصغير)
  final Animation<double> scaleAnimation;

  const LoginButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.fadeAnimation,
    required this.slideController,
    required this.fadeController,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: slideController,
                curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
              ),
            ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: fadeController,
              curve: const Interval(0.6, 1.0),
            ),
          ),
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? _buildLoadingIndicator()
                    : _buildButtonContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// بناء مؤشر التحميل عندما يكون الزر في حالة loading
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
      ),
    );
  }

  /// بناء محتوى الزر (النص والأيقونة) عندما لا يكون في حالة loading
  Widget _buildButtonContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'دخول',
          style: AppStyles.subTextStyle.copyWith(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),

        ),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ],
    );
  }
}


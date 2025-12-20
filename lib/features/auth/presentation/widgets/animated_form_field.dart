import 'package:flutter/material.dart';

/// Widget wrapper لإضافة تأثيرات animation على حقل من حقول النموذج
/// يستخدم لتطبيق تأثيرات fade و slide على حقول الإدخال بشكل متدرج
class AnimatedFormField extends StatelessWidget {
  /// Widget الحقل الذي سيتم تطبيق التأثيرات عليه
  final Widget child;

  /// Animation Controller للتأثير slide
  final AnimationController slideController;

  /// Animation Controller للتأثير fade
  final AnimationController fadeController;

  /// Interval للتأثير slide (من 0.0 إلى 1.0)
  final double slideIntervalStart;
  final double slideIntervalEnd;

  /// Interval للتأثير fade (من 0.0 إلى 1.0)
  final double fadeIntervalStart;
  final double fadeIntervalEnd;

  /// بداية الانزلاق (offset)
  final Offset slideBegin;

  const AnimatedFormField({
    super.key,
    required this.child,
    required this.slideController,
    required this.fadeController,
    this.slideIntervalStart = 0.3,
    this.slideIntervalEnd = 1.0,
    this.fadeIntervalStart = 0.3,
    this.fadeIntervalEnd = 1.0,
    this.slideBegin = const Offset(0, 0.2),
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SlideTransition(
        position: Tween<Offset>(begin: slideBegin, end: Offset.zero).animate(
          CurvedAnimation(
            parent: slideController,
            curve: Interval(
              slideIntervalStart,
              slideIntervalEnd,
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: fadeController,
              curve: Interval(fadeIntervalStart, fadeIntervalEnd),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

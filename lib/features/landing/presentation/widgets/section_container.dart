import 'package:flutter/material.dart';

/// Container wrapper للـ sections مع gradient وتنسيق متسق
class SectionContainer extends StatelessWidget {
  final Widget child;
  final bool isMobile;
  final List<Color>? gradientColors;
  final EdgeInsetsGeometry? padding;

  const SectionContainer({
    super.key,
    required this.child,
    required this.isMobile,
    this.gradientColors,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 40 : 80,
          ),
      decoration: gradientColors != null
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors!,
              ),
            )
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: child,
      ),
    );
  }
}


import 'package:flutter/material.dart';

/// Widget wrapper لإضافة animations متسقة على widgets
class AnimatedWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginOpacity;
  final double endOpacity;
  final Offset? translateOffset;
  final double? beginScale;
  final double? endScale;
  final int delay;

  const AnimatedWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.curve = Curves.easeOut,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.translateOffset,
    this.beginScale,
    this.endScale,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(
        milliseconds: duration.inMilliseconds + delay,
      ),
      curve: curve,
      builder: (context, value, child) {
        Widget animatedChild = this.child;

        // Apply opacity
        if (beginOpacity != endOpacity) {
          final opacity = (beginOpacity + ((endOpacity - beginOpacity) * value))
              .clamp(0.0, 1.0);
          animatedChild = Opacity(opacity: opacity, child: animatedChild);
        }

        // Apply translation
        if (translateOffset != null) {
          final offset = Offset(
            translateOffset!.dx * (1 - value),
            translateOffset!.dy * (1 - value),
          );
          animatedChild = Transform.translate(
            offset: offset,
            child: animatedChild,
          );
        }

        // Apply scale
        if (beginScale != null && endScale != null) {
          final scale = beginScale! + ((endScale! - beginScale!) * value);
          animatedChild = Transform.scale(
            scale: scale,
            child: animatedChild,
          );
        }

        return animatedChild;
      },
      child: child,
    );
  }
}


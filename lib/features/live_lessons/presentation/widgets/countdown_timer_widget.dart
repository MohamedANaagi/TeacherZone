import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

/// Widget لعرض العد التنازلي للدرس المباشر
/// يعرض العد التنازلي حتى وقت بدء الدرس (targetTime)
class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetTime; // وقت بدء الدرس
  final VoidCallback? onTimerFinished; // يتم استدعاؤه عندما يبدأ الدرس
  final VoidCallback? onTimerStarted; // يتم استدعاؤه عندما يبدأ الدرس

  const CountdownTimerWidget({
    super.key,
    required this.targetTime,
    this.onTimerFinished,
    this.onTimerStarted,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateRemainingTime() {
    final now = DateTime.now();
    final difference = widget.targetTime.difference(now);

    if (difference.isNegative || difference.inSeconds <= 0) {
      // الدرس بدأ
      if (!_isFinished) {
        setState(() {
          _remainingTime = Duration.zero;
          _isFinished = true;
        });
        widget.onTimerFinished?.call();
        widget.onTimerStarted?.call(); // إشعار أن الدرس بدأ
      }
    } else {
      // الدرس لم يبدأ بعد
      final wasFinished = _isFinished;
      setState(() {
        _remainingTime = difference;
        _isFinished = false;
      });
      // إذا كان في حالة "بدأ" ثم عاد للعد التنازلي (يجب ألا يحدث لكن للسلامة)
      if (wasFinished && !_isFinished) {
        // إعادة تشغيل التايمر
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateRemainingTime();
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (_isFinished) {
      return 'بدأ الدرس';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '${days} يوم ${hours} ساعة ${minutes} دقيقة';
    } else if (hours > 0) {
      return '${hours} ساعة ${minutes} دقيقة ${seconds} ثانية';
    } else if (minutes > 0) {
      return '${minutes} دقيقة ${seconds} ثانية';
    } else {
      return '${seconds} ثانية';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStarted = widget.targetTime.isBefore(DateTime.now()) || 
                     widget.targetTime.isAtSameMomentAs(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isStarted
              ? [
                  AppColors.successColor,
                  AppColors.successColor.withOpacity(0.8),
                ]
              : [
                  AppColors.primaryColor,
                  AppColors.primaryLight,
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isStarted ? AppColors.successColor : AppColors.primaryColor)
                .withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isStarted ? Icons.play_circle_filled : Icons.access_time,
            color: AppColors.secondaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(_remainingTime),
            style: AppStyles.subHeadingStyle.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}


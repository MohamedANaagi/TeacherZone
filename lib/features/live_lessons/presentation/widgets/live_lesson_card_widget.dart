import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../domain/entities/live_lesson.dart';
import 'countdown_timer_widget.dart';

class LiveLessonCardWidget extends StatefulWidget {
  final LiveLesson liveLesson;
  final VoidCallback? onTap;

  const LiveLessonCardWidget({
    super.key,
    required this.liveLesson,
    this.onTap,
  });

  @override
  State<LiveLessonCardWidget> createState() => _LiveLessonCardWidgetState();
}

class _LiveLessonCardWidgetState extends State<LiveLessonCardWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // تهيئة Animation للنبض
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    // تشغيل Animation بشكل متكرر
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _openMeetingLink(BuildContext context, String link) async {
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }


  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date الساعة $time';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hasStarted = widget.liveLesson.isStarted(now); // الدرس بدأ
    final isEnded = widget.liveLesson.isEnded(now); // الدرس انتهى
    final isLive = widget.liveLesson.isLive(now); // الدرس جاري (بدأ ولم ينته بعد)
    final canOpenLink = hasStarted && !isEnded; // يمكن فتح الرابط فقط بعد بدء الدرس وقبل انتهائه

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(20),
            border: isLive
                ? Border.all(
                    color: AppColors.successColor.withOpacity(_pulseAnimation.value),
                    width: 2 + (2 * _pulseAnimation.value),
                  )
                : isEnded
                    ? Border.all(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        width: 1,
                      )
                    : null,
            boxShadow: isLive
                ? [
                    BoxShadow(
                      color: AppColors.successColor.withOpacity(_pulseAnimation.value * 0.5),
                      blurRadius: 15 + (10 * _pulseAnimation.value),
                      spreadRadius: 2 * _pulseAnimation.value,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: AppColors.shadowColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        );
      },
      child: _buildCardContent(isEnded, isLive, canOpenLink, hasStarted),
    );
  }

  Widget _buildCardContent(bool isEnded, bool isLive, bool canOpenLink, bool hasStarted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Badge للدرس الجاري حالياً مع تأثير النبض
          if (isLive)
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.successColor.withOpacity(_pulseAnimation.value),
                        AppColors.successColor.withOpacity(_pulseAnimation.value * 0.8),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.successColor.withOpacity(_pulseAnimation.value * 0.6),
                        blurRadius: 15 * _pulseAnimation.value,
                        spreadRadius: 2 * _pulseAnimation.value,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.live_tv,
                        color: AppColors.secondaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'درس مباشر الآن',
                        style: AppStyles.subHeadingStyle.copyWith(
                          color: AppColors.secondaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else if (isEnded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
              decoration: BoxDecoration(
                color: AppColors.textSecondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.secondaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'انتهى الدرس',
                    style: AppStyles.subHeadingStyle.copyWith(
                      color: AppColors.secondaryColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // العد التنازلي (حتى وقت بدء الدرس)
          Padding(
            padding: const EdgeInsets.all(16),
            child: CountdownTimerWidget(
              targetTime: widget.liveLesson.scheduledTime,
            ),
          ),
          const Divider(height: 1),
          // معلومات الدرس
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.liveLesson.title,
                  style: AppStyles.subHeadingStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.liveLesson.description,
                  style: AppStyles.textSecondaryStyle.copyWith(
                    fontSize: 14,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _formatDateTime(widget.liveLesson.scheduledTime),
                        style: AppStyles.textSecondaryStyle.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.timer,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                        'المدة: ${widget.liveLesson.durationMinutes} دقيقة',
                      style: AppStyles.textSecondaryStyle.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // زر فتح الرابط
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canOpenLink
                    ? () => _openMeetingLink(context, widget.liveLesson.meetingLink)
                    : null, // تعطيل الزر قبل بدء الدرس أو بعد انتهائه
                icon: Icon(
                  isEnded
                      ? Icons.block
                      : hasStarted && isLive
                          ? Icons.video_call
                          : Icons.access_time,
                  color: AppColors.secondaryColor,
                ),
                label: Text(
                  isEnded
                      ? 'انتهى الدرس'
                      : hasStarted && isLive
                          ? 'انضم للدرس الآن'
                          : !hasStarted
                              ? 'انتظر حتى يبدأ الدرس'
                              : 'فتح رابط الدرس',
                  style: AppStyles.subTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnded
                      ? AppColors.textSecondary
                      : hasStarted && isLive
                          ? AppColors.successColor
                          : AppColors.textSecondary.withOpacity(0.5), // لون رمادي قبل بدء الدرس
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        ],
      );
  }
}


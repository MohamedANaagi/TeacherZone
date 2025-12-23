import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';

class ExamCardWidget extends StatelessWidget {
  final Map<String, dynamic> exam;
  final VoidCallback? onTap;

  const ExamCardWidget({super.key, required this.exam, this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(exam['color'] as int);
    final isCompleted = exam['isCompleted'] as bool;
    final score = exam['score'] as int?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.successColor.withOpacity(0.3)
              : AppColors.borderColor,
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              onTap ??
              () {
                context.push(
                  '${AppRouters.examQuizScreen}/${exam['id']}',
                  extra: exam,
                );
              },
          borderRadius: BorderRadius.circular(20),
          child: ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ExamCardHeader(exam: exam, color: color),
                _ExamCardContent(
                exam: exam,
                color: color,
                isCompleted: isCompleted,
                score: score,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExamCardHeader extends StatelessWidget {
  final Map<String, dynamic> exam;
  final Color color;

  const _ExamCardHeader({required this.exam, required this.color});

  @override
  Widget build(BuildContext context) {
    final isCompleted = exam['isCompleted'] as bool;

    return Container(
      padding: const EdgeInsets.all(16), // تقليل padding من 20 إلى 16
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10, // تقليل من 12 إلى 10
                  vertical: 5, // تقليل من 6 إلى 5
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exam['subject'] as String,
                  style: AppStyles.subTextStyle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10, // تقليل من 12 إلى 10
                    vertical: 5, // تقليل من 6 إلى 5
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.secondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'مكتمل',
                        style: AppStyles.subTextStyle.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10), // تقليل من 12 إلى 10
          Text(
            exam['title'] as String,
            style: AppStyles.subTextStyle.copyWith(
              fontSize: 18, // تقليل من 20 إلى 18
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ExamCardContent extends StatelessWidget {
  final Map<String, dynamic> exam;
  final Color color;
  final bool isCompleted;
  final int? score;

  const _ExamCardContent({
    required this.exam,
    required this.color,
    required this.isCompleted,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12), // تقليل padding من 16 إلى 12
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam['description'] as String,
            style: AppStyles.textSecondaryStyle.copyWith(
              fontSize: 13, // تقليل من 14 إلى 13
              height: 1.3, // تقليل من 1.4 إلى 1.3
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12), // تقليل من 16 إلى 12
          Row(
            children: [
              Expanded(
                child: _InfoItemWidget(
                  icon: Icons.help_outline,
                  label: 'الأسئلة',
                  value: '${exam['questionsCount']}',
                  color: color,
                ),
              ),
            ],
          ),
          if (isCompleted && score != null) ...[
            const SizedBox(height: 12), // تقليل من 16 إلى 12
            _ScoreWidget(score: score!),
          ],
          const SizedBox(height: 10), // تقليل من 12 إلى 10
          _StartButton(exam: exam, color: color, isCompleted: isCompleted),
        ],
      ),
    );
  }
}

class _InfoItemWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoItemWidget({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.subHeadingStyle.copyWith(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.textSecondaryStyle.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ScoreWidget extends StatelessWidget {
  final int score;

  const _ScoreWidget({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.successColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.emoji_events,
                color: AppColors.successColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'النتيجة',
                style: AppStyles.subHeadingStyle.copyWith(fontSize: 16),
              ),
            ],
          ),
          Text(
            '$score%',
            style: AppStyles.subHeadingStyle.copyWith(
              fontSize: 24,
              color: AppColors.successColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final Map<String, dynamic> exam;
  final Color color;
  final bool isCompleted;

  const _StartButton({
    required this.exam,
    required this.color,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Navigation handled by parent
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.refresh : Icons.play_arrow,
              color: AppColors.secondaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              isCompleted ? 'إعادة المحاولة' : 'بدء الاختبار',
              style: AppStyles.subTextStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

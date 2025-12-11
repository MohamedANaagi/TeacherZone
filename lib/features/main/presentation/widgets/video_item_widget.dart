import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class VideoItemWidget extends StatelessWidget {
  final Map<String, dynamic> video;
  final Color courseColor;
  final VoidCallback? onTap;

  const VideoItemWidget({
    super.key,
    required this.video,
    required this.courseColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isWatched = video['isWatched'] as bool;
    final order = video['order'] as int;
    final hasQuiz = video['hasQuiz'] as bool? ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWatched
              ? AppColors.successColor.withOpacity(0.3)
              : AppColors.borderColor,
          width: isWatched ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _VideoOrderNumber(order: order, color: courseColor),
                const SizedBox(width: 16),
                Expanded(
                  child: _VideoContent(
                    video: video,
                    isWatched: isWatched,
                    hasQuiz: hasQuiz,
                  ),
                ),
                const SizedBox(width: 12),
                _PlayButton(color: courseColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoOrderNumber extends StatelessWidget {
  final int order;
  final Color color;

  const _VideoOrderNumber({required this.order, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          '$order',
          style: AppStyles.subHeadingStyle.copyWith(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _VideoContent extends StatelessWidget {
  final Map<String, dynamic> video;
  final bool isWatched;
  final bool hasQuiz;

  const _VideoContent({
    required this.video,
    required this.isWatched,
    required this.hasQuiz,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                video['title'] as String,
                style: AppStyles.subHeadingStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isWatched)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.successColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 14,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              video['duration'] as String,
              style: AppStyles.textSecondaryStyle.copyWith(fontSize: 12),
            ),
            if (isWatched) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'تم المشاهدة',
                  style: AppStyles.textSecondaryStyle.copyWith(
                    fontSize: 10,
                    color: AppColors.successColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (hasQuiz) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.quiz, size: 12, color: AppColors.infoColor),
                    const SizedBox(width: 4),
                    Text(
                      'نموذج',
                      style: AppStyles.textSecondaryStyle.copyWith(
                        fontSize: 10,
                        color: AppColors.infoColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final Color color;

  const _PlayButton({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.play_arrow, color: color, size: 24),
    );
  }
}

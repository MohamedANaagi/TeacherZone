import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class VideoItemWidget extends StatefulWidget {
  final Map<String, dynamic> video;
  final Color courseColor;
  final VoidCallback? onTap;
  final String courseId;
  final Function(String, String)? onWatchedChanged;

  const VideoItemWidget({
    super.key,
    required this.video,
    required this.courseColor,
    this.onTap,
    required this.courseId,
    this.onWatchedChanged,
  });

  @override
  State<VideoItemWidget> createState() => _VideoItemWidgetState();
}

class _VideoItemWidgetState extends State<VideoItemWidget>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isWatched = widget.video['isWatched'] as bool;
    final order = widget.video['order'] as int;
    final hasQuiz = widget.video['hasQuiz'] as bool? ?? false;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isPressed
                ? AppColors.successColor
                : isWatched
                    ? AppColors.successColor.withOpacity(0.5)
                    : AppColors.borderColor,
            width: _isPressed ? 3 : (isWatched ? 2 : 1),
          ),
          boxShadow: [
            BoxShadow(
              color: _isPressed
                  ? AppColors.successColor.withOpacity(0.3)
                  : AppColors.shadowColor,
              blurRadius: _isPressed ? 12 : 8,
              offset: Offset(0, _isPressed ? 4 : 2),
              spreadRadius: _isPressed ? 1 : 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  _CheckboxWidget(
                    isWatched: isWatched,
                    onChanged: () {
                      if (widget.onWatchedChanged != null) {
                        widget.onWatchedChanged!(
                          widget.courseId,
                          widget.video['id'] as String,
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _VideoOrderNumber(order: order, color: widget.courseColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _VideoContent(
                      video: widget.video,
                      isWatched: isWatched,
                      hasQuiz: hasQuiz,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _PlayButton(color: widget.courseColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckboxWidget extends StatelessWidget {
  final bool isWatched;
  final VoidCallback? onChanged;

  const _CheckboxWidget({
    required this.isWatched,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isWatched
                ? AppColors.successColor
                : AppColors.borderColor,
            width: 2,
          ),
          color: isWatched
              ? AppColors.successColor
              : Colors.transparent,
        ),
        child: isWatched
            ? const Icon(
                Icons.check,
                size: 16,
                color: AppColors.secondaryColor,
              )
            : null,
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
        Text(
          video['title'] as String,
          style: AppStyles.subHeadingStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
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

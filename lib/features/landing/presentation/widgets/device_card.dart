import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'animated_wrapper.dart';

/// بطاقة جهاز قابلة لإعادة الاستخدام بتصميم راقي ومتناسق
class DeviceCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const DeviceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedWrapper(
      duration: const Duration(milliseconds: 800),
      translateOffset: const Offset(0, 30),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isHovered
                  ? [
                      widget.color.withOpacity(0.15),
                      widget.color.withOpacity(0.08),
                      widget.color.withOpacity(0.12),
                    ]
                  : [
                      widget.color.withOpacity(0.08),
                      widget.color.withOpacity(0.04),
                      widget.color.withOpacity(0.06),
                    ],
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.4)
                  : widget.color.withOpacity(0.25),
              width: _isHovered ? 2.5 : 1.5,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 25,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: widget.color.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(height: 24),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildDescription(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.color,
            widget.color.withOpacity(0.8),
            widget.color.withOpacity(0.6),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: _isHovered ? 4 : 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: widget.color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        widget.icon,
        size: _isHovered ? 44 : 42,
        color: AppColors.secondaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: AppStyles.subHeadingStyle.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: widget.color,
        letterSpacing: 0.5,
      ),
      child: Text(widget.title, textAlign: TextAlign.center),
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.description,
      style: AppStyles.textSecondaryStyle.copyWith(
        fontSize: 15,
        height: 1.6,
        color: AppColors.textSecondary,
        letterSpacing: 0.2,
      ),
      textAlign: TextAlign.center,
    );
  }
}

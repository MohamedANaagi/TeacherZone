import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../user/presentation/cubit/user_state.dart';

class UserCardWidget extends StatelessWidget {
  final UserState state;

  const UserCardWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryColor, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // صورة المستخدم
            _UserAvatar(imagePath: state.imagePath),
            const SizedBox(width: 16),
            Expanded(
              child: _UserInfo(
                name: state.name,
                phone: state.phone,
                remainingDays: state.remainingDays,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final String? imagePath;

  const _UserAvatar({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondaryColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imagePath != null
            ? Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _DefaultAvatar();
                },
              )
            : _DefaultAvatar(),
      ),
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.secondaryColor.withValues(alpha: 0.2),
      child: const Icon(
        Icons.person,
        size: 35,
        color: AppColors.secondaryColor,
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  final String? name;
  final String? phone;
  final int remainingDays;

  const _UserInfo({
    required this.name,
    required this.phone,
    required this.remainingDays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً بك مجدداً!',
          style: AppStyles.subTextStyle.copyWith(
            color: AppColors.secondaryColor.withValues(alpha: 0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name ?? 'المستخدم',
          style: AppStyles.mainTextStyle.copyWith(
            color: AppColors.secondaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (phone != null) ...[
          const SizedBox(height: 4),
          Text(
            phone!,
            style: AppStyles.subTextStyle.copyWith(
              color: AppColors.secondaryColor.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
        if (remainingDays > 0) ...[
          const SizedBox(height: 8),
          _SubscriptionBadge(remainingDays: remainingDays),
        ],
      ],
    );
  }
}

class _SubscriptionBadge extends StatelessWidget {
  final int remainingDays;

  const _SubscriptionBadge({required this.remainingDays});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 14,
            color: AppColors.secondaryColor,
          ),
          const SizedBox(width: 6),
          Text(
            '$remainingDays يوم متبقي',
            style: AppStyles.subTextStyle.copyWith(
              color: AppColors.secondaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

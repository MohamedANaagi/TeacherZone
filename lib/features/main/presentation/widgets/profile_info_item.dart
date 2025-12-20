import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

/// Widget لعرض عنصر من معلومات الملف الشخصي
/// يعرض أيقونة، عنوان، وقيمة
class ProfileInfoItem extends StatelessWidget {
  /// أيقونة العنصر
  final IconData icon;

  /// عنوان العنصر (مثل "الاسم" أو "البريد الإلكتروني")
  final String label;

  /// قيمة العنصر (مثل اسم المستخدم أو البريد)
  final String? value;

  /// اللون المستخدم للأيقونة والقيمة
  final Color color;

  const ProfileInfoItem({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.color = AppColors.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value ?? 'غير متوفر';
    final hasValue = value != null;

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.grey12MediumStyle.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                displayValue,
                style: hasValue
                    ? AppStyles.mainTextStyle.copyWith(
                        fontSize: 18,
                        color: AppColors.textPrimary,
                      )
                    : AppStyles.mainTextStyle.copyWith(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

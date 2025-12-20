import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';

/// Helper class لعرض رسائل الخطأ في SnackBar
/// يوفر طريقة موحدة لعرض رسائل الخطأ بشكل جميل ومتسق
class ErrorSnackBarHelper {
  /// يعرض رسالة خطأ في SnackBar
  ///
  /// [context] - BuildContext الحالي
  /// [message] - نص رسالة الخطأ المراد عرضها
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

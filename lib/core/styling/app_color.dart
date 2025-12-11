import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية - نظام ألوان متناسق
  static const Color primaryColor = Color(0xFF6366F1); // Indigo - لون أساسي جميل
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo Dark
  static const Color primaryLight = Color(0xFF818CF8); // Indigo Light
  
  static const Color secondaryColor = Color(0xFFFFFFFF); // أبيض
  static const Color secondaryDark = Color(0xFFF8FAFC); // رمادي فاتح جداً
  
  // ألوان النص
  static const Color textPrimary = Color(0xFF1E293B); // رمادي داكن للنصوص
  static const Color textSecondary = Color(0xFF64748B); // رمادي متوسط
  static const Color textLight = Color(0xFF94A3B8); // رمادي فاتح
  
  // ألوان إضافية
  static const Color accentColor = Color(0xFF8B5CF6); // بنفسجي - للتأكيد
  static const Color successColor = Color(0xFF10B981); // أخضر - للنجاح
  static const Color warningColor = Color(0xFFF59E0B); // برتقالي - للتحذير
  static const Color errorColor = Color(0xFFEF4444); // أحمر - للأخطاء
  static const Color infoColor = Color(0xFF3B82F6); // أزرق - للمعلومات
  
  // ألوان الخلفية
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFFF1F5F9);
  
  // ألوان الحدود
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFF1F5F9);
  
  // ألوان الظلال
  static const Color shadowColor = Color(0x1A000000);
  
  // ألوان قديمة (للتوافق مع الكود القديم)
  @Deprecated('Use textPrimary instead')
  static const Color blackColor = textPrimary;
  
  @Deprecated('Use textSecondary instead')
  static const Color greyColor = textSecondary;
}

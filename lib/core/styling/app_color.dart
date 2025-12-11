import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية - نظام ألوان داكن
  static const Color primaryColor = Color(0xFF1E40AF); // أزرق داكن
  static const Color primaryDark = Color(0xFF1E3A8A); // أزرق أغمق
  static const Color primaryLight = Color(0xFF3B82F6); // أزرق متوسط

  static const Color secondaryColor = Color(0xFFFFFFFF); // أبيض
  static const Color secondaryDark = Color(0xFFF1F5F9); // رمادي فاتح جداً
  // ألوان النص
  static const Color textPrimary = Color(0xFF0F172A); // أسود تقريباً للنصوص
  static const Color textSecondary = Color(0xFF475569); // رمادي داكن
  static const Color textLight = Color(0xFF64748B); // رمادي متوسط

  // ألوان إضافية
  static const Color accentColor = Color(0xFF6D28D9); // بنفسجي داكن
  static const Color successColor = Color(0xFF059669); // أخضر داكن
  static const Color warningColor = Color(0xFFD97706); // برتقالي داكن
  static const Color errorColor = Color(0xFFDC2626); // أحمر داكن
  static const Color infoColor = Color(0xFF2563EB); // أزرق داكن

  // ألوان الخلفية
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF1F5F9);
  static const Color backgroundDark = Color(0xFFE2E8F0);

  // ألوان الحدود
  static const Color borderColor = Color(0xFFCBD5E1);
  static const Color borderLight = Color(0xFFE2E8F0);

  // ألوان الظلال
  static const Color shadowColor = Color(0x33000000);

  // ألوان الكورسات
  static const Color courseColor = Color(0xFF1E40AF); // أزرق للكورسات
  static const Color courseColorDark = Color(0xFF1E3A8A); // أزرق داكن
  static const Color courseColorLight = Color(0xFF3B82F6); // أزرق فاتح

  // ألوان الاختبارات
  static const Color examColor = Color(0xFF1E40AF); // بنفسجي للاختبارات
  static const Color examColorDark = Color(0xFF1E3A8A); // بنفسجي داكن
  static const Color examColorLight = Color(0xFF3B82F6); // بنفسجي فاتح

  // ألوان قديمة (للتوافق مع الكود القديم)
  @Deprecated('Use textPrimary instead')
  static const Color blackColor = textPrimary;

  @Deprecated('Use textSecondary instead')
  static const Color greyColor = textSecondary;
}

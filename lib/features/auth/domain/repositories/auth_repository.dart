import '../entities/user.dart';

/// Repository Interface - Abstract Class
/// يعرف العمليات المتاحة للتعامل مع المصادقة
abstract class AuthRepository {
  /// تسجيل الدخول باستخدام الكود
  Future<User> login({
    required String code,
    required String name,
    required String phone,
  });

  /// تسجيل الخروج
  Future<void> logout();

  /// الحصول على المستخدم الحالي
  Future<User?> getCurrentUser();

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn();
}

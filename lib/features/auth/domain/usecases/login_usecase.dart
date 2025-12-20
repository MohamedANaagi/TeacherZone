import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../../../../core/errors/exceptions.dart';

/// Use Case: Login
/// يحتوي على منطق تسجيل الدخول
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// تنفيذ تسجيل الدخول
  ///
  /// [code] الكود الذي أدخله المستخدم
  /// يتم جلب الاسم ورقم الهاتف المرتبطين بهذا الكود من Firestore
  ///
  /// Returns [User] إذا نجح تسجيل الدخول
  /// Throws [ValidationException] إذا كانت البيانات غير صحيحة
  /// Throws [AuthException] إذا فشل تسجيل الدخول
  Future<User> call({required String code}) async {
    // التحقق من صحة البيانات
    if (code.isEmpty) {
      throw ValidationException('الكود لا يمكن أن يكون فارغاً');
    }

    return await repository.login(code: code);
  }
}

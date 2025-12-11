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
  /// [name] اسم المستخدم
  /// [email] بريد المستخدم الإلكتروني
  ///
  /// Returns [User] إذا نجح تسجيل الدخول
  /// Throws [ValidationException] إذا كانت البيانات غير صحيحة
  /// Throws [AuthException] إذا فشل تسجيل الدخول
  Future<User> call({
    required String code,
    required String name,
    required String email,
  }) async {
    // التحقق من صحة البيانات
    if (code.isEmpty) {
      throw ValidationException('الكود لا يمكن أن يكون فارغاً');
    }

    if (name.isEmpty) {
      throw ValidationException('الاسم لا يمكن أن يكون فارغاً');
    }

    if (email.isEmpty) {
      throw ValidationException('البريد الإلكتروني لا يمكن أن يكون فارغاً');
    }

    // التحقق من صحة البريد الإلكتروني
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw ValidationException('البريد الإلكتروني غير صحيح');
    }

    return await repository.login(code: code, name: name, email: email);
  }
}

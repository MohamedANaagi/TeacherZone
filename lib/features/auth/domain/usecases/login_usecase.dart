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
  /// [phone] رقم هاتف المستخدم
  ///
  /// Returns [User] إذا نجح تسجيل الدخول
  /// Throws [ValidationException] إذا كانت البيانات غير صحيحة
  /// Throws [AuthException] إذا فشل تسجيل الدخول
  Future<User> call({
    required String code,
    required String name,
    required String phone,
  }) async {
    // التحقق من صحة البيانات
    if (code.isEmpty) {
      throw ValidationException('الكود لا يمكن أن يكون فارغاً');
    }

    if (name.isEmpty) {
      throw ValidationException('الاسم لا يمكن أن يكون فارغاً');
    }

    if (phone.isEmpty) {
      throw ValidationException('رقم الهاتف لا يمكن أن يكون فارغاً');
    }

    // التحقق من صحة رقم الهاتف (أرقام فقط، ويفضل أن يكون 10 أرقام أو أكثر)
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    final cleanPhone = phone.replaceAll(
      RegExp(r'[^\d]'),
      '',
    ); // إزالة جميع الأحرف غير الرقمية
    if (!phoneRegex.hasMatch(cleanPhone)) {
      throw ValidationException(
        'رقم الهاتف غير صحيح. يجب أن يحتوي على 10-15 رقم',
      );
    }

    return await repository.login(code: code, name: name, phone: cleanPhone);
  }
}

import 'package:class_code/features/admin/domain/repositories/admin_repository.dart';

import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';

/// Remote Data Source Interface
/// يعرف العمليات للتعامل مع API
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول باستخدام الكود
  Future<UserModel> login({
    required String code,
    required String name,
    required String phone,
  });

  /// تسجيل الخروج
  Future<void> logout();

  /// الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser();

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn();
}

/// Remote Data Source Implementation
/// يقوم بالتحقق من صحة الكود من Firestore قبل تسجيل الدخول
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final AdminRepository adminRepository;

  AuthRemoteDataSourceImpl({required this.adminRepository});

  /// تسجيل الدخول باستخدام الكود
  ///
  /// الخطوات:
  /// 1. التحقق من صحة الكود من Firestore عبر AdminRepository
  /// 2. إذا كان الكود صحيحاً، إنشاء UserModel مع بيانات المستخدم
  /// 3. حساب تاريخ انتهاء الاشتراك (30 يوم من الآن)
  /// 4. إرجاع UserModel
  ///
  /// يرمي AuthException إذا كان الكود غير صحيح
  @override
  Future<UserModel> login({
    required String code,
    required String name,
    required String phone,
  }) async {
    try {
      // التحقق من صحة الكود من Firestore
      final isValidCode = await adminRepository.validateCode(code);

      if (!isValidCode) {
        throw AuthException('الكود المدخل غير صحيح أو غير موجود');
      }

      // حساب تاريخ انتهاء الاشتراك (30 يوم من الآن)
      final subscriptionEndDate = DateTime.now().add(const Duration(days: 30));

      // إنشاء UserModel مع معرف فريد
      return UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        phone: phone,
        code: code,
        subscriptionEndDate: subscriptionEndDate,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw AuthException('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    // TODO: تنفيذ تسجيل الخروج
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: جلب المستخدم من Local Storage
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    // TODO: التحقق من حالة تسجيل الدخول
    return false;
  }
}

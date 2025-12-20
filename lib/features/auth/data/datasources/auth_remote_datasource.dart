import 'package:class_code/features/admin/domain/repositories/admin_repository.dart';

import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';

/// Remote Data Source Interface
/// يعرف العمليات للتعامل مع API
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول باستخدام الكود
  /// يتم جلب الاسم ورقم الهاتف المرتبطين بالكود من Firestore
  Future<UserModel> login({required String code});

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
  /// 1. جلب بيانات الكود من Firestore عبر AdminRepository.getCodeByCode()
  /// 2. إذا كان الكود موجوداً، استخراج الاسم ورقم الهاتف المرتبطين به
  /// 3. إنشاء UserModel مع بيانات المستخدم من الكود
  /// 4. حساب تاريخ انتهاء الاشتراك (30 يوم من الآن)
  /// 5. إرجاع UserModel
  ///
  /// يرمي AuthException إذا كان الكود غير صحيح
  @override
  Future<UserModel> login({required String code}) async {
    try {
      // جلب بيانات الكود من Firestore
      final codeModel = await adminRepository.getCodeByCode(code);

      if (codeModel == null) {
        throw AuthException('الكود المدخل غير صحيح أو غير موجود');
      }

      // حساب تاريخ انتهاء الاشتراك (30 يوم من الآن)
      final subscriptionEndDate = DateTime.now().add(const Duration(days: 30));

      // إنشاء UserModel مع معرف فريد وبيانات المستخدم من الكود
      return UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: codeModel.name,
        phone: codeModel.phone,
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

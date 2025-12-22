import 'package:class_code/features/admin/domain/repositories/admin_repository.dart';

import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/image_storage_service.dart';
import '../../../../core/services/video_progress_service.dart';
import 'package:flutter/foundation.dart';

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

      // التحقق من انتهاء الاشتراك وحذف الكود تلقائياً إذا انتهى
      if (codeModel.subscriptionEndDate != null) {
        final now = DateTime.now();
        if (now.isAfter(codeModel.subscriptionEndDate!)) {
          // حذف جميع بيانات الكود (الصورة، حالات المشاهدة)
          try {
            await ImageStorageService.deleteProfileImage(code: code);
            await VideoProgressService.clearVideoProgressForCode(code: code);
            debugPrint('تم حذف بيانات الكود المنتهي: $code');
          } catch (e) {
            debugPrint('خطأ في حذف بيانات الكود المنتهي $code: $e');
          }
          
          // حذف الكود من Firestore
          try {
            await adminRepository.deleteCode(codeModel.id);
          } catch (e) {
            // تجاهل أخطاء الحذف، لكن نرمي خطأ تسجيل الدخول
          }
          throw AuthException('انتهت صلاحية الاشتراك لهذا الكود');
        }
      }

      // استخدام subscriptionEndDate من CodeModel إذا كان موجوداً، وإلا استخدام 30 يوم افتراضي
      final subscriptionEndDate = codeModel.subscriptionEndDate ?? 
          DateTime.now().add(const Duration(days: 30));

      // إنشاء UserModel مع معرف فريد وبيانات المستخدم من الكود
      // ملاحظة: رابط الصورة سيتم جلبه من UserCubit عند الحاجة
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

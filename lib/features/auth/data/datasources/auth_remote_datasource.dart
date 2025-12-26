import 'package:class_code/features/admin/domain/repositories/admin_repository.dart';
import 'package:class_code/features/admin/data/models/code_model.dart';

import '../models/user_model.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/video_progress_service.dart';
import '../../../../core/services/device_service.dart';
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
  /// 2. التحقق من الجهاز - إذا كان الكود مستخدم على جهاز آخر، منع الدخول
  /// 3. إذا كان الكود موجوداً، استخراج الاسم ورقم الهاتف المرتبطين به
  /// 4. حفظ معرف الجهاز في الكود (إذا لم يكن محفوظاً)
  /// 5. إنشاء UserModel مع بيانات المستخدم من الكود
  /// 6. حساب تاريخ انتهاء الاشتراك (30 يوم من الآن)
  /// 7. إرجاع UserModel
  ///
  /// يرمي AuthException إذا كان الكود غير صحيح أو مستخدم على جهاز آخر
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
          // حذف بيانات تقدم الفيديوهات (الصور الآن على Bunny Storage وليس محلياً)
          try {
            await VideoProgressService.clearVideoProgressForCode(code: code);
            debugPrint('تم حذف بيانات تقدم الفيديوهات للكود المنتهي: $code');
          } catch (e) {
            debugPrint('خطأ في حذف بيانات تقدم الفيديوهات للكود المنتهي $code: $e');
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

      // الحصول على معرف الجهاز الحالي
      final currentDeviceId = await DeviceService.getDeviceId();

      // التحقق من الجهاز
      // إذا كان الكود مرتبط بجهاز آخر، منع الدخول
      if (codeModel.deviceId != null && codeModel.deviceId != currentDeviceId) {
        throw AuthException(
          'هذا الكود مستخدم بالفعل على جهاز آخر. لا يمكن استخدام الكود على أكثر من جهاز',
        );
      }

      // إذا لم يكن الكود مرتبط بجهاز، نربطه بالجهاز الحالي
      if (codeModel.deviceId == null) {
        // تحديث الكود بربطه بالجهاز الحالي
        final updatedCodeModel = CodeModel(
          id: codeModel.id,
          code: codeModel.code,
          name: codeModel.name,
          phone: codeModel.phone,
          description: codeModel.description,
          profileImageUrl: codeModel.profileImageUrl,
          createdAt: codeModel.createdAt,
          subscriptionEndDate: codeModel.subscriptionEndDate,
          deviceId: currentDeviceId,
          adminCode: codeModel.adminCode, // الحفاظ على adminCode
        );

        // حفظ التحديث في Firestore
        await adminRepository.addCode(updatedCodeModel);
        debugPrint('✅ تم ربط الكود بالجهاز: $currentDeviceId');
      }

      // استخدام subscriptionEndDate من CodeModel إذا كان موجوداً، وإلا استخدام 30 يوم افتراضي
      final subscriptionEndDate =
          codeModel.subscriptionEndDate ??
          DateTime.now().add(const Duration(days: 30));

      // مزامنة تقدم الفيديوهات من Firestore (للمزامنة بين الأجهزة)
      try {
        await VideoProgressService.syncProgressFromFirestore(
          code: code,
          adminCode: codeModel.adminCode, // تصفية الكورسات حسب adminCode
        );
        debugPrint('✅ تمت مزامنة تقدم الفيديوهات من Firestore للكود: $code');
      } catch (e) {
        // لا نمنع تسجيل الدخول إذا فشلت المزامنة
        debugPrint('تحذير: فشلت مزامنة تقدم الفيديوهات: $e');
      }

      // إنشاء UserModel مع معرف فريد وبيانات المستخدم من الكود
      // ملاحظة: رابط الصورة سيتم جلبه من UserCubit عند الحاجة
      // ملاحظة: adminCode سيتم جلبه وحفظه في UserCubit منفصلاً في login_screen
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
    try {
      // جلب الكود الحالي من UserCubit أو من SharedPreferences
      // لكن بما أن logout لا يستقبل code، سنحتاج إلى تمريره من الخارج
      // أو يمكننا جلب الكود من Firestore بناءً على deviceId
      // لكن الأفضل هو تمرير code من الخارج
      debugPrint(
        '⚠️ logout تم استدعاؤه بدون code - سيتم استدعاؤه مع code من profile_screen',
      );
    } catch (e) {
      debugPrint('❌ خطأ في تسجيل الخروج: $e');
      // لا نرمي exception هنا لأن تسجيل الخروج يجب أن ينجح حتى لو فشل تحديث deviceId
    }
  }

  /// تسجيل الخروج مع إزالة deviceId من الكود
  /// يتم استدعاؤه من profile_screen أو admin_main_screen
  Future<void> logoutWithCode(String code) async {
    try {
      // جلب بيانات الكود من Firestore
      final codeModel = await adminRepository.getCodeByCode(code);

      if (codeModel != null) {
        // الحصول على معرف الجهاز الحالي
        final currentDeviceId = await DeviceService.getDeviceId();

        // التحقق من أن الكود مرتبط بالجهاز الحالي
        if (codeModel.deviceId == currentDeviceId) {
          // إزالة deviceId من الكود (السماح باستخدامه على جهاز آخر)
          final updatedCodeModel = CodeModel(
            id: codeModel.id,
            code: codeModel.code,
            name: codeModel.name,
            phone: codeModel.phone,
            description: codeModel.description,
            profileImageUrl: codeModel.profileImageUrl,
            createdAt: codeModel.createdAt,
            subscriptionEndDate: codeModel.subscriptionEndDate,
            deviceId: null, // إزالة ربط الجهاز
            adminCode: codeModel.adminCode, // الحفاظ على adminCode
          );

          // حفظ التحديث في Firestore
          await adminRepository.addCode(updatedCodeModel);
          debugPrint('✅ تم إزالة ربط الجهاز من الكود: $code');
        } else {
          debugPrint(
            '⚠️ الكود غير مرتبط بالجهاز الحالي - لا حاجة لإزالة deviceId',
          );
        }
      }

      // إعادة تعيين معرف الويب إذا كان على الويب
      await DeviceService.resetWebDeviceId();
    } catch (e) {
      debugPrint('❌ خطأ في إزالة ربط الجهاز من الكود: $e');
      // لا نرمي exception هنا لأن تسجيل الخروج يجب أن ينجح حتى لو فشل تحديث deviceId
    }
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

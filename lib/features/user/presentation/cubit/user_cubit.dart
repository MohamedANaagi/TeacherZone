import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/image_storage_service.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState()) {
    // لا نستدعي loadUserData هنا لتجنب deadlock على iOS
    // سيتم استدعاؤها في splash screen
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUser({
    String? name,
    String? phone,
    String? imagePath,
    String? code,
    String? adminCode,
    String? adminName,
    String? adminPhone,
    String? adminDescription,
    String? adminImageUrl,
    DateTime? subscriptionEndDate,
    bool? isLoggedIn,
  }) async {
    final newState = state.copyWith(
      name: name,
      phone: phone,
      imagePath: imagePath,
      code: code,
      adminCode: adminCode,
      adminName: adminName,
      adminPhone: adminPhone,
      adminDescription: adminDescription,
      adminImageUrl: adminImageUrl,
      subscriptionEndDate: subscriptionEndDate,
      isLoggedIn: isLoggedIn,
    );

    debugPrint('تحديث بيانات المستخدم - isLoggedIn: ${newState.isLoggedIn}');
    emit(newState);
    await _saveToPrefs(newState);
    debugPrint('تم حفظ البيانات - isLoggedIn: ${newState.isLoggedIn}');
  }

  /// حفظ البيانات في SharedPreferences
  Future<void> _saveToPrefs(UserState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // حفظ أو مسح الاسم
      if (state.name != null) {
        await prefs.setString('user_name', state.name!);
      } else {
        await prefs.remove('user_name');
      }

      // حفظ أو مسح رقم الهاتف
      if (state.phone != null) {
        await prefs.setString('user_phone', state.phone!);
      } else {
        await prefs.remove('user_phone');
      }

      // حفظ أو مسح مسار الصورة (مسار محلي في الجهاز)
      if (state.imagePath != null) {
        await prefs.setString('user_image_path', state.imagePath!);
      } else {
        await prefs.remove('user_image_path');
      }

      // حفظ أو مسح الكود
      if (state.code != null) {
        await prefs.setString('user_code', state.code!);
      } else {
        await prefs.remove('user_code');
      }

      // حفظ أو مسح كود الأدمن
      if (state.adminCode != null) {
        await prefs.setString('admin_code', state.adminCode!);
      } else {
        await prefs.remove('admin_code');
      }

      // حفظ أو مسح اسم الأدمن
      if (state.adminName != null) {
        await prefs.setString('admin_name', state.adminName!);
      } else {
        await prefs.remove('admin_name');
      }

      // حفظ أو مسح رقم هاتف الأدمن
      if (state.adminPhone != null) {
        await prefs.setString('admin_phone', state.adminPhone!);
      } else {
        await prefs.remove('admin_phone');
      }

      // حفظ أو مسح وصف الأدمن
      if (state.adminDescription != null) {
        await prefs.setString('admin_description', state.adminDescription!);
      } else {
        await prefs.remove('admin_description');
      }

      // حفظ أو مسح صورة الأدمن
      if (state.adminImageUrl != null) {
        await prefs.setString('admin_image_url', state.adminImageUrl!);
      } else {
        await prefs.remove('admin_image_url');
      }

      // حفظ أو مسح تاريخ انتهاء الاشتراك
      if (state.subscriptionEndDate != null) {
        await prefs.setString(
          'subscription_end_date',
          state.subscriptionEndDate!.toIso8601String(),
        );
      } else {
        await prefs.remove('subscription_end_date');
      }

      // حفظ حالة تسجيل الدخول
      await prefs.setBool('is_logged_in', state.isLoggedIn);
      debugPrint('تم حفظ isLoggedIn في SharedPreferences: ${state.isLoggedIn}');

      debugPrint('تم حفظ بيانات المستخدم بنجاح');
    } catch (e) {
      debugPrint('خطأ في حفظ بيانات المستخدم: $e');
    }
  }

  /// تحميل البيانات من SharedPreferences
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      final phone = prefs.getString('user_phone');
      final code = prefs.getString('user_code');
      final adminCode = prefs.getString('admin_code');
      final adminName = prefs.getString('admin_name');
      final adminPhone = prefs.getString('admin_phone');
      final adminDescription = prefs.getString('admin_description');
      final adminImageUrl = prefs.getString('admin_image_url');
      final subscriptionDateString = prefs.getString('subscription_end_date');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      debugPrint('تحميل بيانات المستخدم - isLoggedIn: $isLoggedIn');

      // محاولة تحميل الصورة المحفوظة بناءً على الكود
      String? imagePath;
      if (code != null && code.isNotEmpty) {
        imagePath = await ImageStorageService.getProfileImagePath(code: code);
        // إذا لم توجد صورة محفوظة، استخدم المسار من SharedPreferences (للتوافق مع البيانات القديمة)
        imagePath ??= prefs.getString('user_image_path');
      } else {
        imagePath = prefs.getString('user_image_path');
      }

      DateTime? subscriptionEndDate;
      if (subscriptionDateString != null) {
        try {
          subscriptionEndDate = DateTime.parse(subscriptionDateString);
        } catch (e) {
          debugPrint('خطأ في تحليل تاريخ الاشتراك: $e');
        }
      }

      emit(
        UserState(
          name: name,
          phone: phone,
          imagePath: imagePath,
          code: code,
          adminCode: adminCode,
          adminName: adminName,
          adminPhone: adminPhone,
          adminDescription: adminDescription,
          adminImageUrl: adminImageUrl,
          subscriptionEndDate: subscriptionEndDate,
          isLoggedIn: isLoggedIn,
        ),
      );
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  /// مسح بيانات المستخدم
  /// ملاحظة: لا نحذف الصورة أو حالات المشاهدة لأن المستخدم قد يعود بنفس الكود
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // حذف بيانات المستخدم فقط (وليس حالات المشاهدة أو الصور)
      await prefs.remove('user_name');
      await prefs.remove('user_phone');
      await prefs.remove('user_image_path');
      await prefs.remove('user_code');
      await prefs.remove('admin_code');
      await prefs.remove('admin_name');
      await prefs.remove('admin_phone');
      await prefs.remove('admin_description');
      await prefs.remove('subscription_end_date');
      await prefs.setBool('is_logged_in', false);
      
      // ملاحظة: لا نحذف الصورة المحلية - تبقى محفوظة بناءً على الكود
      // ملاحظة: لا نحذف حالات المشاهدة - تبقى محفوظة بناءً على الكود
      // حتى لو سجل المستخدم خروج، الصورة وحالات المشاهدة تبقى للكود

      emit(const UserState(isLoggedIn: false));
    } catch (e) {
      debugPrint('خطأ في مسح بيانات المستخدم: $e');
      // حتى لو فشل الحفظ، نمسح البيانات من الذاكرة
      emit(const UserState(isLoggedIn: false));
    }
  }
}

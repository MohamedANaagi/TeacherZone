import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(const UserState()) {
    loadUserData();
  }

  /// تحديث بيانات المستخدم
  Future<void> updateUser({
    String? name,
    String? email,
    String? imagePath,
    DateTime? subscriptionEndDate,
    bool? isLoggedIn,
  }) async {
    final newState = state.copyWith(
      name: name,
      email: email,
      imagePath: imagePath,
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

      // حفظ أو مسح الإيميل
      if (state.email != null) {
        await prefs.setString('user_email', state.email!);
      } else {
        await prefs.remove('user_email');
      }

      // حفظ أو مسح مسار الصورة
      if (state.imagePath != null) {
        await prefs.setString('user_image_path', state.imagePath!);
      } else {
        await prefs.remove('user_image_path');
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
      final email = prefs.getString('user_email');
      final imagePath = prefs.getString('user_image_path');
      final subscriptionDateString = prefs.getString('subscription_end_date');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      debugPrint('تحميل بيانات المستخدم - isLoggedIn: $isLoggedIn');

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
          email: email,
          imagePath: imagePath,
          subscriptionEndDate: subscriptionEndDate,
          isLoggedIn: isLoggedIn,
        ),
      );
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  /// مسح بيانات المستخدم
  Future<void> clearUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      emit(const UserState(isLoggedIn: false));
    } catch (e) {
      debugPrint('خطأ في مسح بيانات المستخدم: $e');
      // حتى لو فشل الحفظ، نمسح البيانات من الذاكرة
      emit(const UserState(isLoggedIn: false));
    }
  }
}

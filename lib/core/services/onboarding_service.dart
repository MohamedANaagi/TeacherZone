import 'package:shared_preferences/shared_preferences.dart';

/// Service لإدارة حالة عرض الـ Onboarding
class OnboardingService {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// التحقق من إذا كان تم عرض الـ Onboarding من قبل
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// حفظ حالة إكمال الـ Onboarding
  static Future<void> setOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingCompletedKey, true);
    } catch (e) {
      // Ignore errors
    }
  }

  /// إعادة تعيين حالة الـ Onboarding (للتطوير/الاختبار)
  static Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingCompletedKey);
    } catch (e) {
      // Ignore errors
    }
  }
}

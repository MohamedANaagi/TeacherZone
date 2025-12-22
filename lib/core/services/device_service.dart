import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

/// Service للحصول على معرف الجهاز الفريد
/// يستخدم لربط الكود بجهاز واحد فقط
class DeviceService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static String? _cachedDeviceId;
  static const String _webDeviceIdKey = 'web_device_id';

  /// الحصول على معرف الجهاز الفريد
  /// 
  /// على iOS: يستخدم identifierForVendor
  /// على Android: يستخدم androidId
  /// على الويب: يستخدم معرف محفوظ في localStorage
  /// 
  /// Returns: معرف الجهاز الفريد كـ String
  static Future<String> getDeviceId() async {
    // إرجاع القيمة المخزنة مؤقتاً إذا كانت موجودة
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      String deviceId;

      if (kIsWeb) {
        // للويب: استخدام معرف محفوظ في localStorage
        final prefs = await SharedPreferences.getInstance();
        final savedDeviceId = prefs.getString(_webDeviceIdKey);
        
        if (savedDeviceId == null || savedDeviceId.isEmpty) {
          // إنشاء معرف فريد جديد للويب
          deviceId = 'web-${DateTime.now().millisecondsSinceEpoch}-${_generateRandomString(8)}';
          await prefs.setString(_webDeviceIdKey, deviceId);
          debugPrint('✅ تم إنشاء معرف جديد للويب: $deviceId');
        } else {
          deviceId = savedDeviceId;
          debugPrint('✅ استخدام معرف الويب الموجود: $deviceId');
        }
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // identifierForVendor يعطي معرف فريد لكل تطبيق على الجهاز
        // إذا تم حذف التطبيق وإعادة تثبيته، سيتغير المعرف
        deviceId = iosInfo.identifierForVendor ?? 'ios-${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // androidId يعطي معرف فريد للجهاز (لا يتغير حتى بعد إعادة تثبيت التطبيق)
        deviceId = androidInfo.id;
      } else {
        // للمنصات الأخرى، نستخدم معرف مؤقت
        deviceId = 'unknown-${DateTime.now().millisecondsSinceEpoch}';
      }

      // حفظ المعرف مؤقتاً
      _cachedDeviceId = deviceId;
      debugPrint('✅ معرف الجهاز: $deviceId');
      return deviceId;
    } catch (e) {
      debugPrint('❌ خطأ في الحصول على معرف الجهاز: $e');
      // في حالة الخطأ، نعيد معرف مؤقت
      final fallbackId = 'fallback-${DateTime.now().millisecondsSinceEpoch}';
      _cachedDeviceId = fallbackId;
      return fallbackId;
    }
  }

  /// توليد سلسلة عشوائية (للاستخدام في معرف الويب)
  static String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      buffer.write(chars[(random + i) % chars.length]);
    }
    return buffer.toString();
  }

  /// إعادة تعيين المعرف المخزن مؤقتاً (للتطوير/الاختبار)
  static void resetCache() {
    _cachedDeviceId = null;
  }

  /// إعادة تعيين معرف الويب (للاستخدام عند تسجيل الخروج)
  static Future<void> resetWebDeviceId() async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_webDeviceIdKey);
        _cachedDeviceId = null;
        debugPrint('✅ تم إعادة تعيين معرف الويب');
      } catch (e) {
        debugPrint('❌ خطأ في إعادة تعيين معرف الويب: $e');
      }
    }
  }
}


import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// خدمة لحفظ وتحميل حالة مشاهدة الفيديوهات
/// تُحفظ بناءً على الكود والكورس والفيديو
class VideoProgressService {
  /// الحصول على مفتاح الحفظ بناءً على الكود والكورس والفيديو
  static String _getKey(String code, String courseId, String videoId) {
    return 'video_watched_${code}_${courseId}_$videoId';
  }

  /// حفظ حالة مشاهدة الفيديو
  ///
  /// [code] كود المستخدم
  /// [courseId] معرف الكورس
  /// [videoId] معرف الفيديو
  /// [isWatched] حالة المشاهدة
  static Future<void> saveVideoWatchedStatus({
    required String code,
    required String courseId,
    required String videoId,
    required bool isWatched,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(code, courseId, videoId);
      
      if (isWatched) {
        await prefs.setBool(key, true);
        debugPrint('تم حفظ حالة المشاهدة: $code/$courseId/$videoId');
      } else {
        await prefs.remove(key);
        debugPrint('تم حذف حالة المشاهدة: $code/$courseId/$videoId');
      }
    } catch (e) {
      debugPrint('خطأ في حفظ حالة المشاهدة: $e');
    }
  }

  /// جلب حالة مشاهدة الفيديو
  ///
  /// [code] كود المستخدم
  /// [courseId] معرف الكورس
  /// [videoId] معرف الفيديو
  /// Returns true إذا كان الفيديو مشاهد، false إذا لم يكن
  static Future<bool> getVideoWatchedStatus({
    required String code,
    required String courseId,
    required String videoId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(code, courseId, videoId);
      return prefs.getBool(key) ?? false;
    } catch (e) {
      debugPrint('خطأ في جلب حالة المشاهدة: $e');
      return false;
    }
  }

  /// جلب جميع الفيديوهات المشاهدة لكورس معين
  ///
  /// [code] كود المستخدم
  /// [courseId] معرف الكورس
  /// Returns Set من معرفات الفيديوهات المشاهدة
  static Future<Set<String>> getWatchedVideosForCourse({
    required String code,
    required String courseId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'video_watched_${code}_${courseId}_';
      
      final allKeys = prefs.getKeys();
      final watchedVideos = <String>{};
      
      for (final key in allKeys) {
        if (key.startsWith(prefix) && prefs.getBool(key) == true) {
          // استخراج videoId من المفتاح
          final videoId = key.substring(prefix.length);
          watchedVideos.add(videoId);
        }
      }
      
      return watchedVideos;
    } catch (e) {
      debugPrint('خطأ في جلب الفيديوهات المشاهدة: $e');
      return {};
    }
  }

  /// حذف جميع حالات المشاهدة لكود معين (عند تسجيل الخروج)
  /// ملاحظة: لا نحذف الحالات لأن المستخدم قد يعود بنفس الكود
  /// يمكن استخدام هذه الدالة فقط عند حذف الكود نهائياً
  static Future<void> clearVideoProgressForCode({required String code}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'video_watched_${code}_';
      
      final allKeys = prefs.getKeys();
      final keysToRemove = allKeys.where((key) => key.startsWith(prefix)).toList();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      debugPrint('تم حذف ${keysToRemove.length} حالة مشاهدة للكود: $code');
    } catch (e) {
      debugPrint('خطأ في حذف حالات المشاهدة: $e');
    }
  }
}


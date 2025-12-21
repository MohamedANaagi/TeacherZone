import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// خدمة لرفع وإدارة صور البروفايل في Firebase Storage
class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// رفع صورة البروفايل إلى Firebase Storage وربطها بالكود في Firestore
  ///
  /// [imagePath] مسار الصورة المحلية
  /// [code] كود المستخدم المرتبط بالصورة
  /// Returns رابط الصورة في Firebase Storage
  static Future<String> uploadProfileImage({
    required String imagePath,
    required String code,
  }) async {
    try {
      debugPrint('بدء رفع الصورة - الكود: $code, المسار: $imagePath');
      
      // التحقق من وجود الملف
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('الصورة المختارة غير موجودة في المسار: $imagePath');
      }

      // التحقق من حجم الملف
      final fileSize = await file.length();
      debugPrint('حجم الملف: $fileSize bytes');
      if (fileSize == 0) {
        throw Exception('الملف فارغ');
      }

      // الحصول على امتداد الملف الأصلي
      final fileExtension = path.extension(imagePath).toLowerCase();
      // إذا لم يكن هناك امتداد، استخدم .jpg كافتراضي
      final extension = fileExtension.isNotEmpty ? fileExtension : '.jpg';
      // تحويل امتدادات HEIC و HEIF إلى jpg
      final finalExtension = (extension == '.heic' || extension == '.heif') ? '.jpg' : extension;
      
      debugPrint('امتداد الملف الأصلي: $fileExtension');
      debugPrint('امتداد الملف النهائي: $finalExtension');

      // إنشاء مرجع للملف في Firebase Storage
      // المسار: profile_images/{code}{extension}
      final fileName = '$code$finalExtension';
      final ref = _storage.ref().child('profile_images').child(fileName);
      debugPrint('مسار Firebase Storage: profile_images/$fileName');

      // رفع الصورة مع معالجة أفضل للأخطاء
      try {
        debugPrint('بدء رفع الملف إلى Firebase Storage...');
        final uploadTask = ref.putFile(
          file,
        SettableMetadata(
          contentType: finalExtension == '.png' 
              ? 'image/png' 
              : finalExtension == '.gif'
                  ? 'image/gif'
                  : 'image/jpeg',
          customMetadata: {
            'code': code,
            'uploadedAt': DateTime.now().toIso8601String(),
            'originalExtension': fileExtension,
          },
        ),
        );

        // مراقبة تقدم الرفع
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
          debugPrint('تقدم الرفع: ${progress.toStringAsFixed(1)}%');
        });

        // انتظار اكتمال الرفع مع معالجة الأخطاء
        debugPrint('انتظار اكتمال الرفع...');
        final snapshot = await uploadTask;
        debugPrint('حالة الرفع: ${snapshot.state}');
        
        // التحقق من حالة الرفع
        if (snapshot.state == TaskState.success) {
          debugPrint('الرفع نجح! جاري الحصول على رابط التحميل...');
          // الحصول على رابط التحميل
          final downloadUrl = await snapshot.ref.getDownloadURL();
          debugPrint('رابط التحميل: $downloadUrl');

          // تحديث رابط الصورة في Firestore
          try {
            debugPrint('تحديث رابط الصورة في Firestore...');
            await _updateProfileImageUrlInFirestore(code: code, imageUrl: downloadUrl);
            debugPrint('تم تحديث Firestore بنجاح');
          } catch (firestoreError) {
            // حتى لو فشل تحديث Firestore، نعيد رابط الصورة
            // لأن الصورة رُفعت بنجاح
            debugPrint('تحذير: فشل تحديث Firestore لكن الصورة رُفعت بنجاح: $firestoreError');
          }

          return downloadUrl;
        } else {
          throw Exception('فشل رفع الصورة: حالة الرفع ${snapshot.state}');
        }
      } on FirebaseException catch (e) {
        // معالجة أخطاء Firebase بشكل خاص
        debugPrint('خطأ Firebase: ${e.code} - ${e.message}');
        debugPrint('Stack trace: ${e.stackTrace}');
        
        String errorMessage = 'فشل رفع الصورة إلى Firebase Storage';
        switch (e.code) {
          case 'permission-denied':
            errorMessage = 'لا توجد صلاحيات لرفع الصورة.\n'
                'تحقق من:\n'
                '1. قواعد Firebase Storage (Storage > Rules)\n'
                '2. تأكد من الضغط على Publish بعد التحديث\n'
                '3. انتظر 30 ثانية بعد التحديث';
            break;
          case 'unauthorized':
          case 'unauthenticated':
            errorMessage = 'غير مصرح لك برفع الصورة.\n'
                'يجب تحديث قواعد Firebase Storage:\n'
                '1. افتح Firebase Console > Storage > Rules\n'
                '2. استخدم القواعد من ملف storage.rules\n'
                '3. اضغط Publish\n'
                '4. انتظر 30 ثانية';
            break;
          case 'canceled':
            errorMessage = 'تم إلغاء رفع الصورة';
            break;
          case 'unknown':
            errorMessage = 'حدث خطأ غير معروف: ${e.message}';
            break;
          default:
            errorMessage = 'خطأ في Firebase Storage:\n'
                'الكود: ${e.code}\n'
                'الرسالة: ${e.message ?? "لا توجد رسالة"}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      // إعادة رمي الخطأ مع معلومات إضافية
      if (e is Exception) {
        rethrow;
      }
      throw Exception('فشل رفع الصورة: ${e.toString()}');
    }
  }

  /// تحديث رابط صورة البروفايل في Firestore
  static Future<void> _updateProfileImageUrlInFirestore({
    required String code,
    required String imageUrl,
  }) async {
    try {
      // البحث عن الكود في Firestore
      final codesRef = _firestore.collection('codes');
      final querySnapshot = await codesRef.where('code', isEqualTo: code).get();

      if (querySnapshot.docs.isNotEmpty) {
        // تحديث رابط الصورة في المستند
        final docId = querySnapshot.docs.first.id;
        await codesRef.doc(docId).update({
          'profileImageUrl': imageUrl,
        });
      } else {
        throw Exception('الكود غير موجود في Firestore');
      }
    } catch (e) {
      throw Exception('فشل تحديث رابط الصورة في Firestore: ${e.toString()}');
    }
  }

  /// حذف صورة البروفايل من Firebase Storage
  static Future<void> deleteProfileImage({required String code}) async {
    try {
      // محاولة حذف الصورة بامتدادات مختلفة
      final extensions = ['.jpg', '.jpeg', '.png', '.heic', '.heif'];
      for (final ext in extensions) {
        try {
          final ref = _storage.ref().child('profile_images').child('$code$ext');
          await ref.delete();
          break; // إذا نجح الحذف، توقف
        } catch (e) {
          // تجاهل الأخطاء واستمر في المحاولة
          continue;
        }
      }

      // حذف رابط الصورة من Firestore
      final codesRef = _firestore.collection('codes');
      final querySnapshot = await codesRef.where('code', isEqualTo: code).get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await codesRef.doc(docId).update({
          'profileImageUrl': FieldValue.delete(),
        });
      }
    } catch (e) {
      // تجاهل الأخطاء عند الحذف
    }
  }

  /// الحصول على رابط صورة البروفايل من Firestore
  static Future<String?> getProfileImageUrl({required String code}) async {
    try {
      final codesRef = _firestore.collection('codes');
      final querySnapshot = await codesRef.where('code', isEqualTo: code).get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return data['profileImageUrl'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}


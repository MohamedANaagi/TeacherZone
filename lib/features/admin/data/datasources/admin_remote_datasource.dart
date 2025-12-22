import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/code_model.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';

abstract class AdminRemoteDataSource {
  // Admin Codes
  Future<String?> getAdminCodeByUserCode(String userCode);
  Future<bool> validateAdminCode(String adminCode);
  Future<String?> getAdminCodeByCode(String code); // جلب adminCode مباشرة من adminCodes collection

  // Codes
  Future<void> addCode(CodeModel code);
  Future<List<CodeModel>> getCodes({String? adminCode});
  Future<void> deleteCode(String codeId);
  Future<bool> validateCode(String code);
  Future<CodeModel?> getCodeByCode(String code);

  // Courses
  Future<void> addCourse(CourseModel course);
  Future<List<CourseModel>> getCourses({String? adminCode});
  Future<void> deleteCourse(String courseId);
  Future<void> updateCourse(CourseModel course);

  // Videos
  Future<void> addVideo(VideoModel video);
  Future<List<VideoModel>> getVideosByCourseId(String courseId, {String? adminCode});
  Future<void> deleteVideo(String videoId);
  Future<void> updateVideoCountForCourse(String courseId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  // ==================== Admin Codes ====================

  @override
  Future<String?> getAdminCodeByUserCode(String userCode) async {
    try {
      // جلب كود المستخدم من Firestore
      final codeModel = await getCodeByCode(userCode);
      if (codeModel == null) {
        return null;
      }

      // جلب adminCode من collection adminCodes
      final adminCodeSnapshot = await firestore
          .collection('adminCodes')
          .where('adminCode', isEqualTo: codeModel.adminCode)
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (adminCodeSnapshot.docs.isEmpty) {
        return null;
      }

      final adminCodeDoc = adminCodeSnapshot.docs.first;
      final adminCodeData = adminCodeDoc.data();
      return adminCodeData['adminCode'] as String?;
    } catch (e) {
      throw ServerException('فشل جلب كود الأدمن: ${e.toString()}');
    }
  }

  @override
  Future<bool> validateAdminCode(String adminCode) async {
    try {
      final snapshot = await firestore
          .collection('adminCodes')
          .where('adminCode', isEqualTo: adminCode.trim())
          .limit(1)
          .get(const GetOptions(source: Source.server));

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException('فشل التحقق من كود الأدمن: ${e.toString()}');
    }
  }

  @override
  Future<String?> getAdminCodeByCode(String code) async {
    try {
      // البحث مباشرة في collection adminCodes
      final snapshot = await firestore
          .collection('adminCodes')
          .where('adminCode', isEqualTo: code.trim())
          .limit(1)
          .get(const GetOptions(source: Source.server));

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final adminCodeDoc = snapshot.docs.first;
      final adminCodeData = adminCodeDoc.data();
      return adminCodeData['adminCode'] as String?;
    } catch (e) {
      throw ServerException('فشل جلب كود الأدمن: ${e.toString()}');
    }
  }

  // ==================== Codes ====================

  @override
  Future<void> addCode(CodeModel code) async {
    try {
      await firestore.collection('codes').doc(code.id).set(code.toFirestore());
    } catch (e) {
      throw ServerException('فشل إضافة الكود: ${e.toString()}');
    }
  }

  @override
  Future<List<CodeModel>> getCodes({String? adminCode}) async {
    try {
      // استخدام Source.server للحصول على البيانات من السيرفر مباشرة (بدون cache)
      Query query = firestore.collection('codes');
      
      // تصفية حسب adminCode إذا تم تمريره
      if (adminCode != null && adminCode.isNotEmpty) {
        query = query.where('adminCode', isEqualTo: adminCode);
      }
      
      final snapshot = await query.get(const GetOptions(source: Source.server));

      final codes = snapshot.docs
          .map((doc) => CodeModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // ترتيب محلي حسب التاريخ (الأحدث أولاً)
      codes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return codes;
    } catch (e) {
      throw ServerException('فشل جلب الأكواد: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCode(String codeId) async {
    try {
      await firestore.collection('codes').doc(codeId).delete();
    } catch (e) {
      throw ServerException('فشل حذف الكود: ${e.toString()}');
    }
  }

  @override
  Future<bool> validateCode(String code) async {
    try {
      // البحث عن الكود في Firestore
      final snapshot = await firestore
          .collection('codes')
          .where('code', isEqualTo: code.trim())
          .limit(1)
          .get(const GetOptions(source: Source.server));

      // إذا وجد الكود، يعيد true
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException('فشل التحقق من الكود: ${e.toString()}');
    }
  }

  @override
  Future<CodeModel?> getCodeByCode(String code) async {
    try {
      // البحث عن الكود في Firestore
      final snapshot = await firestore
          .collection('codes')
          .where('code', isEqualTo: code.trim())
          .limit(1)
          .get(const GetOptions(source: Source.server));

      // إذا وجد الكود، إرجاع CodeModel
      if (snapshot.docs.isEmpty) {
        return null;
      }

      final doc = snapshot.docs.first;
      return CodeModel.fromFirestore(doc.id, doc.data());
    } catch (e) {
      throw ServerException('فشل جلب بيانات الكود: ${e.toString()}');
    }
  }

  // ==================== Courses ====================

  @override
  Future<void> addCourse(CourseModel course) async {
    try {
      await firestore
          .collection('courses')
          .doc(course.id)
          .set(course.toFirestore());
    } catch (e) {
      throw ServerException('فشل إضافة الكورس: ${e.toString()}');
    }
  }

  @override
  Future<List<CourseModel>> getCourses({String? adminCode}) async {
    try {
      Query query = firestore.collection('courses');
      
      // تصفية حسب adminCode إذا تم تمريره
      if (adminCode != null && adminCode.isNotEmpty) {
        query = query.where('adminCode', isEqualTo: adminCode);
      }
      
      final snapshot = await query.get();

      final courses = snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // ترتيب محلي حسب التاريخ (الأحدث أولاً)
      courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return courses;
    } catch (e) {
      throw ServerException('فشل جلب الكورسات: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    try {
      // حذف الكورس
      await firestore.collection('courses').doc(courseId).delete();

      // حذف جميع الفيديوهات المرتبطة بالكورس
      final videosSnapshot = await firestore
          .collection('videos')
          .where('courseId', isEqualTo: courseId)
          .get();

      final batch = firestore.batch();
      for (var doc in videosSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw ServerException('فشل حذف الكورس: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    try {
      await firestore
          .collection('courses')
          .doc(course.id)
          .update(course.toFirestore());
    } catch (e) {
      throw ServerException('فشل تحديث الكورس: ${e.toString()}');
    }
  }

  // ==================== Videos ====================

  @override
  Future<void> addVideo(VideoModel video) async {
    try {
      await firestore
          .collection('videos')
          .doc(video.id)
          .set(video.toFirestore());

      // تحديث عدد الدروس في الكورس
      await updateVideoCountForCourse(video.courseId);
    } catch (e) {
      throw ServerException('فشل إضافة الفيديو: ${e.toString()}');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCourseId(String courseId, {String? adminCode}) async {
    try {
      Query query = firestore
          .collection('videos')
          .where('courseId', isEqualTo: courseId);
      
      // تصفية حسب adminCode إذا تم تمريره
      if (adminCode != null && adminCode.isNotEmpty) {
        query = query.where('adminCode', isEqualTo: adminCode);
      }
      
      final snapshot = await query.get();

      final videos = snapshot.docs
          .map((doc) => VideoModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // ترتيب محلي حسب التاريخ (الأقدم أولاً)
      videos.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return videos;
    } catch (e) {
      throw ServerException('فشل جلب الفيديوهات: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    try {
      // جلب معلومات الفيديو لمعرفة الكورس المرتبط
      final videoDoc = await firestore.collection('videos').doc(videoId).get();
      if (!videoDoc.exists) {
        throw ServerException('الفيديو غير موجود');
      }

      final courseId = videoDoc.data()?['courseId'] as String?;

      // حذف الفيديو
      await firestore.collection('videos').doc(videoId).delete();

      // تحديث عدد الدروس في الكورس
      if (courseId != null) {
        await updateVideoCountForCourse(courseId);
      }
    } catch (e) {
      throw ServerException('فشل حذف الفيديو: ${e.toString()}');
    }
  }

  @override
  Future<void> updateVideoCountForCourse(String courseId) async {
    try {
      final videosCount = await firestore
          .collection('videos')
          .where('courseId', isEqualTo: courseId)
          .count()
          .get();

      await firestore.collection('courses').doc(courseId).update({
        'lessonsCount': videosCount.count,
      });
    } catch (e) {
      // لا نرمي exception هنا لأنها عملية مساعدة
      // يمكن أن تفشل إذا كان الكورس غير موجود، وهذا مقبول
    }
  }
}

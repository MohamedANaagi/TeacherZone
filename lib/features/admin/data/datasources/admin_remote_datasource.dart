import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/code_model.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';

abstract class AdminRemoteDataSource {
  // Codes
  Future<void> addCode(CodeModel code);
  Future<List<CodeModel>> getCodes();
  Future<void> deleteCode(String codeId);

  // Courses
  Future<void> addCourse(CourseModel course);
  Future<List<CourseModel>> getCourses();
  Future<void> deleteCourse(String courseId);
  Future<void> updateCourse(CourseModel course);

  // Videos
  Future<void> addVideo(VideoModel video);
  Future<List<VideoModel>> getVideosByCourseId(String courseId);
  Future<void> deleteVideo(String videoId);
  Future<void> updateVideoCountForCourse(String courseId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final FirebaseFirestore firestore;

  AdminRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

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
  Future<List<CodeModel>> getCodes() async {
    try {
      // استخدام Source.server للحصول على البيانات من السيرفر مباشرة (بدون cache)
      final snapshot = await firestore
          .collection('codes')
          .get(const GetOptions(source: Source.server));

      final codes = snapshot.docs
          .map((doc) => CodeModel.fromFirestore(doc.id, doc.data()))
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
  Future<List<CourseModel>> getCourses() async {
    try {
      final snapshot = await firestore.collection('courses').get();

      final courses = snapshot.docs
          .map((doc) => CourseModel.fromFirestore(doc.id, doc.data()))
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
  Future<List<VideoModel>> getVideosByCourseId(String courseId) async {
    try {
      final snapshot = await firestore
          .collection('videos')
          .where('courseId', isEqualTo: courseId)
          .get();

      final videos = snapshot.docs
          .map((doc) => VideoModel.fromFirestore(doc.id, doc.data()))
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

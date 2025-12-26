import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/live_lesson_model.dart';

abstract class LiveLessonRemoteDataSource {
  Future<void> addLiveLesson(LiveLessonModel liveLesson);
  Future<List<LiveLessonModel>> getLiveLessons({String? adminCode});
  Future<void> deleteLiveLesson(String liveLessonId);
}

class LiveLessonRemoteDataSourceImpl implements LiveLessonRemoteDataSource {
  final FirebaseFirestore firestore;

  LiveLessonRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> addLiveLesson(LiveLessonModel liveLesson) async {
    try {
      await firestore
          .collection('liveLessons')
          .doc(liveLesson.id)
          .set(liveLesson.toFirestore());
    } catch (e) {
      throw ServerException('فشل إضافة الدرس المباشر: ${e.toString()}');
    }
  }

  @override
  Future<List<LiveLessonModel>> getLiveLessons({String? adminCode}) async {
    try {
      Query query = firestore.collection('liveLessons');

      // تصفية حسب adminCode إذا تم تمريره
      if (adminCode != null && adminCode.isNotEmpty) {
        query = query.where('adminCode', isEqualTo: adminCode);
      }

      final snapshot = await query.get();

      final liveLessons = snapshot.docs
          .map((doc) => LiveLessonModel.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      // ترتيب حسب الوقت المحدد (الأقرب أولاً)
      liveLessons.sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

      return liveLessons;
    } catch (e) {
      throw ServerException('فشل جلب الدروس المباشرة: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteLiveLesson(String liveLessonId) async {
    try {
      await firestore.collection('liveLessons').doc(liveLessonId).delete();
    } catch (e) {
      throw ServerException('فشل حذف الدرس المباشر: ${e.toString()}');
    }
  }
}


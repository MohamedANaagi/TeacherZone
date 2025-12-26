import '../../../../core/errors/exceptions.dart';
import '../datasources/live_lesson_remote_datasource.dart';
import '../models/live_lesson_model.dart';
import '../../domain/entities/live_lesson.dart';
import '../../domain/repositories/live_lesson_repository.dart';

class LiveLessonRepositoryImpl implements LiveLessonRepository {
  final LiveLessonRemoteDataSource remoteDataSource;

  LiveLessonRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addLiveLesson(LiveLesson liveLesson) async {
    try {
      final liveLessonModel = LiveLessonModel(
        id: liveLesson.id,
        title: liveLesson.title,
        description: liveLesson.description,
        meetingLink: liveLesson.meetingLink,
        scheduledTime: liveLesson.scheduledTime,
        durationMinutes: liveLesson.durationMinutes,
        createdAt: liveLesson.createdAt,
        adminCode: liveLesson.adminCode,
      );
      await remoteDataSource.addLiveLesson(liveLessonModel);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء إضافة الدرس المباشر');
    }
  }

  @override
  Future<List<LiveLesson>> getLiveLessons({String? adminCode}) async {
    try {
      final liveLessonModels =
          await remoteDataSource.getLiveLessons(adminCode: adminCode);
      return liveLessonModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب الدروس المباشرة');
    }
  }

  @override
  Future<void> deleteLiveLesson(String liveLessonId) async {
    try {
      await remoteDataSource.deleteLiveLesson(liveLessonId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء حذف الدرس المباشر');
    }
  }
}


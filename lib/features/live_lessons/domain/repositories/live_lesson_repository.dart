import '../entities/live_lesson.dart';

abstract class LiveLessonRepository {
  Future<void> addLiveLesson(LiveLesson liveLesson);
  Future<List<LiveLesson>> getLiveLessons({String? adminCode});
  Future<void> deleteLiveLesson(String liveLessonId);
}


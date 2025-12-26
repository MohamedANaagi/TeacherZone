import '../entities/live_lesson.dart';
import '../repositories/live_lesson_repository.dart';

class GetLiveLessonsUseCase {
  final LiveLessonRepository repository;

  GetLiveLessonsUseCase(this.repository);

  Future<List<LiveLesson>> call({String? adminCode}) async {
    return await repository.getLiveLessons(adminCode: adminCode);
  }
}


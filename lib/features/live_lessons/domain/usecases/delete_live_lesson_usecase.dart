import '../repositories/live_lesson_repository.dart';

class DeleteLiveLessonUseCase {
  final LiveLessonRepository repository;

  DeleteLiveLessonUseCase(this.repository);

  Future<void> call(String liveLessonId) async {
    if (liveLessonId.trim().isEmpty) {
      throw ArgumentError('معرف الدرس المباشر مطلوب');
    }
    await repository.deleteLiveLesson(liveLessonId.trim());
  }
}


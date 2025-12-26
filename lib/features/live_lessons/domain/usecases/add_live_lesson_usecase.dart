import '../../../../core/errors/exceptions.dart';
import '../entities/live_lesson.dart';
import '../repositories/live_lesson_repository.dart';

class AddLiveLessonUseCase {
  final LiveLessonRepository repository;

  AddLiveLessonUseCase(this.repository);

  Future<void> call({
    required String title,
    required String description,
    required String meetingLink,
    required DateTime scheduledTime,
    required int durationMinutes,
    required String adminCode,
  }) async {
    // Validation
    if (title.trim().isEmpty) {
      throw ValidationException('عنوان الدرس المباشر مطلوب');
    }
    if (description.trim().isEmpty) {
      throw ValidationException('وصف الدرس المباشر مطلوب');
    }
    if (meetingLink.trim().isEmpty) {
      throw ValidationException('رابط الدرس المباشر مطلوب');
    }
    if (!meetingLink.trim().startsWith('http://') &&
        !meetingLink.trim().startsWith('https://')) {
      throw ValidationException('الرابط يجب أن يكون رابطاً صحيحاً');
    }
    if (adminCode.trim().isEmpty) {
      throw ValidationException('كود الأدمن مطلوب');
    }
    if (scheduledTime.isBefore(DateTime.now())) {
      throw ValidationException('وقت الدرس يجب أن يكون في المستقبل');
    }
    if (durationMinutes <= 0 || durationMinutes > 1440) {
      throw ValidationException('مدة الدرس يجب أن تكون بين 1 دقيقة و 24 ساعة');
    }

    final liveLesson = LiveLesson(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      meetingLink: meetingLink.trim(),
      scheduledTime: scheduledTime,
      durationMinutes: durationMinutes,
      createdAt: DateTime.now(),
      adminCode: adminCode.trim(),
    );

    await repository.addLiveLesson(liveLesson);
  }
}


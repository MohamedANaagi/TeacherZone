import '../../../../core/errors/exceptions.dart';
import '../../data/models/video_model.dart';
import '../repositories/admin_repository.dart';

class AddVideoUseCase {
  final AdminRepository repository;

  AddVideoUseCase(this.repository);

  Future<void> call({
    required String courseId,
    required String title,
    required String url,
    String? description,
    String duration = '00:00',
    required String adminCode, // كود الأدمن المرتبط بهذا الفيديو
  }) async {
    // Validation
    if (courseId.trim().isEmpty) {
      throw ValidationException('معرف الكورس مطلوب');
    }
    if (title.trim().isEmpty) {
      throw ValidationException('عنوان الفيديو مطلوب');
    }
    if (url.trim().isEmpty) {
      throw ValidationException('رابط الفيديو مطلوب');
    }
    if (adminCode.trim().isEmpty) {
      throw ValidationException('كود الأدمن مطلوب');
    }

    final videoModel = VideoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      courseId: courseId.trim(),
      title: title.trim(),
      url: url.trim(),
      description: description?.trim(),
      duration: duration,
      createdAt: DateTime.now(),
      adminCode: adminCode.trim(),
    );

    await repository.addVideo(videoModel);
  }
}

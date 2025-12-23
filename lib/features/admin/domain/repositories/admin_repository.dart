import '../../data/models/code_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/video_model.dart';

abstract class AdminRepository {
  // Admin Codes
  Future<String?> getAdminCodeByUserCode(String userCode);
  Future<bool> validateAdminCode(String adminCode);
  Future<String?> getAdminCodeByCode(String code); // جلب adminCode مباشرة من adminCodes collection

  // Codes
  Future<void> addCode(CodeModel code);
  Future<List<CodeModel>> getCodes({String? adminCode});
  Future<void> deleteCode(String codeId);
  Future<void> updateCode(CodeModel code);
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

  // Video Progress
  Future<void> saveVideoProgress({
    required String code,
    required String courseId,
    required String videoId,
    required bool isWatched,
  });
  Future<Set<String>> getWatchedVideosForCourse({
    required String code,
    required String courseId,
  });
  Future<void> clearVideoProgressForCode({required String code});
}

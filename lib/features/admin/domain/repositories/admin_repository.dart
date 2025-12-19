import '../../data/models/code_model.dart';
import '../../data/models/course_model.dart';
import '../../data/models/video_model.dart';

abstract class AdminRepository {
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
}

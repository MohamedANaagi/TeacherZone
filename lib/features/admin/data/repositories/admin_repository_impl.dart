import '../../../../core/errors/exceptions.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/code_model.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addCode(CodeModel code) async {
    try {
      await remoteDataSource.addCode(code);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء إضافة الكود');
    }
  }

  @override
  Future<List<CodeModel>> getCodes() async {
    try {
      return await remoteDataSource.getCodes();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب الأكواد');
    }
  }

  @override
  Future<void> deleteCode(String codeId) async {
    try {
      await remoteDataSource.deleteCode(codeId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء حذف الكود');
    }
  }

  @override
  Future<void> addCourse(CourseModel course) async {
    try {
      await remoteDataSource.addCourse(course);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء إضافة الكورس');
    }
  }

  @override
  Future<List<CourseModel>> getCourses() async {
    try {
      return await remoteDataSource.getCourses();
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب الكورسات');
    }
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    try {
      await remoteDataSource.deleteCourse(courseId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء حذف الكورس');
    }
  }

  @override
  Future<void> updateCourse(CourseModel course) async {
    try {
      await remoteDataSource.updateCourse(course);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء تحديث الكورس');
    }
  }

  @override
  Future<void> addVideo(VideoModel video) async {
    try {
      await remoteDataSource.addVideo(video);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء إضافة الفيديو');
    }
  }

  @override
  Future<List<VideoModel>> getVideosByCourseId(String courseId) async {
    try {
      return await remoteDataSource.getVideosByCourseId(courseId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب الفيديوهات');
    }
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    try {
      await remoteDataSource.deleteVideo(videoId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء حذف الفيديو');
    }
  }
}

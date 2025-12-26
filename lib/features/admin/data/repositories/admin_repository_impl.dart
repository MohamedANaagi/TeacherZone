import '../../../../core/errors/exceptions.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/code_model.dart';
import '../models/course_model.dart';
import '../models/video_model.dart';
import '../models/admin_code_model.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl({required this.remoteDataSource});

  // ==================== Admin Codes ====================

  @override
  Future<String?> getAdminCodeByUserCode(String userCode) async {
    try {
      return await remoteDataSource.getAdminCodeByUserCode(userCode);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب كود الأدمن');
    }
  }

  @override
  Future<bool> validateAdminCode(String adminCode) async {
    try {
      return await remoteDataSource.validateAdminCode(adminCode);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء التحقق من كود الأدمن');
    }
  }

  @override
  Future<String?> getAdminCodeByCode(String code) async {
    try {
      return await remoteDataSource.getAdminCodeByCode(code);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب كود الأدمن');
    }
  }

  @override
  Future<AdminCodeModel?> getAdminCodeModelByCode(String code) async {
    try {
      return await remoteDataSource.getAdminCodeModelByCode(code);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب بيانات الأدمن');
    }
  }

  @override
  Future<void> updateAdminCodeImageUrl(String adminCode, String imageUrl) async {
    try {
      await remoteDataSource.updateAdminCodeImageUrl(adminCode, imageUrl);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء تحديث صورة الأدمن');
    }
  }

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
  Future<List<CodeModel>> getCodes({String? adminCode}) async {
    try {
      return await remoteDataSource.getCodes(adminCode: adminCode);
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
  Future<void> updateCode(CodeModel code) async {
    try {
      await remoteDataSource.updateCode(code);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء تحديث الكود');
    }
  }

  @override
  Future<void> updateCodeImageUrl(String code, String imageUrl) async {
    try {
      await remoteDataSource.updateCodeImageUrl(code, imageUrl);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء تحديث صورة الطالب');
    }
  }

  @override
  Future<bool> validateCode(String code) async {
    try {
      return await remoteDataSource.validateCode(code);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء التحقق من الكود');
    }
  }

  @override
  Future<CodeModel?> getCodeByCode(String code) async {
    try {
      return await remoteDataSource.getCodeByCode(code);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب بيانات الكود');
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
  Future<List<CourseModel>> getCourses({String? adminCode}) async {
    try {
      return await remoteDataSource.getCourses(adminCode: adminCode);
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
  Future<List<VideoModel>> getVideosByCourseId(String courseId, {String? adminCode}) async {
    try {
      return await remoteDataSource.getVideosByCourseId(courseId, adminCode: adminCode);
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

  // ==================== Video Progress ====================

  @override
  Future<void> saveVideoProgress({
    required String code,
    required String courseId,
    required String videoId,
    required bool isWatched,
  }) async {
    try {
      await remoteDataSource.saveVideoProgress(
        code: code,
        courseId: courseId,
        videoId: videoId,
        isWatched: isWatched,
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء حفظ تقدم الفيديو');
    }
  }

  @override
  Future<Set<String>> getWatchedVideosForCourse({
    required String code,
    required String courseId,
  }) async {
    try {
      return await remoteDataSource.getWatchedVideosForCourse(
        code: code,
        courseId: courseId,
      );
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء جلب تقدم الفيديوهات');
    }
  }

  @override
  Future<void> clearVideoProgressForCode({required String code}) async {
    try {
      await remoteDataSource.clearVideoProgressForCode(code: code);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('حدث خطأ أثناء حذف تقدم الفيديوهات');
    }
  }
}

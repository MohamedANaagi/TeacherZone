import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/add_code_usecase.dart';
import '../../features/admin/domain/usecases/update_code_usecase.dart';
import '../../features/admin/domain/usecases/add_course_usecase.dart';
import '../../features/admin/domain/usecases/edit_course_usecase.dart';
import '../../features/admin/domain/usecases/add_video_usecase.dart';
import '../../features/tests/data/datasources/test_remote_datasource.dart';
import '../../features/tests/data/repositories/test_repository_impl.dart';
import '../../features/tests/domain/repositories/test_repository.dart';
import '../../features/tests/domain/usecases/add_test_usecase.dart';
import '../../features/tests/domain/usecases/add_question_usecase.dart';
import '../../features/tests/domain/usecases/submit_test_usecase.dart';

/// Dependency Injection Container
/// إدارة التبعيات في التطبيق
class InjectionContainer {
  // Data Sources
  static AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl(adminRepository: adminRepository);

  static AdminRemoteDataSource get adminRemoteDataSource =>
      AdminRemoteDataSourceImpl();

  static TestRemoteDataSource get testRemoteDataSource =>
      TestRemoteDataSourceImpl();

  // Repositories
  static AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  static AdminRepository get adminRepository =>
      AdminRepositoryImpl(remoteDataSource: adminRemoteDataSource);

  static TestRepository get testRepository =>
      TestRepositoryImpl(remoteDataSource: testRemoteDataSource);

  // Use Cases
  static LoginUseCase get loginUseCase => LoginUseCase(authRepository);

  // Admin Use Cases
  static AddCodeUseCase get addCodeUseCase => AddCodeUseCase(adminRepository);

  static UpdateCodeUseCase get updateCodeUseCase =>
      UpdateCodeUseCase(adminRepository);

  static AddCourseUseCase get addCourseUseCase =>
      AddCourseUseCase(adminRepository);

  static EditCourseUseCase get editCourseUseCase =>
      EditCourseUseCase(adminRepository);

  static AddVideoUseCase get addVideoUseCase =>
      AddVideoUseCase(adminRepository);

  // Test Use Cases
  static AddTestUseCase get addTestUseCase => AddTestUseCase(testRepository);

  static AddQuestionUseCase get addQuestionUseCase =>
      AddQuestionUseCase(testRepository);

  static SubmitTestUseCase get submitTestUseCase =>
      SubmitTestUseCase(testRepository);

  // Admin Repository (for direct access if needed)
  static AdminRepository get adminRepo => adminRepository;

  // Test Repository (for direct access if needed)
  static TestRepository get testRepo => testRepository;
}

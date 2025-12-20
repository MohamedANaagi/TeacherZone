import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository_impl.dart';
import '../../features/admin/domain/repositories/admin_repository.dart';
import '../../features/admin/domain/usecases/add_code_usecase.dart';
import '../../features/admin/domain/usecases/add_course_usecase.dart';
import '../../features/admin/domain/usecases/add_video_usecase.dart';

/// Dependency Injection Container
/// إدارة التبعيات في التطبيق
class InjectionContainer {
  // Data Sources
  static AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl(adminRepository: adminRepository);

  static AdminRemoteDataSource get adminRemoteDataSource =>
      AdminRemoteDataSourceImpl();

  // Repositories
  static AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  static AdminRepository get adminRepository =>
      AdminRepositoryImpl(remoteDataSource: adminRemoteDataSource);

  // Use Cases
  static LoginUseCase get loginUseCase => LoginUseCase(authRepository);

  // Admin Use Cases
  static AddCodeUseCase get addCodeUseCase => AddCodeUseCase(adminRepository);

  static AddCourseUseCase get addCourseUseCase =>
      AddCourseUseCase(adminRepository);

  static AddVideoUseCase get addVideoUseCase =>
      AddVideoUseCase(adminRepository);

  // Admin Repository (for direct access if needed)
  static AdminRepository get adminRepo => adminRepository;
}

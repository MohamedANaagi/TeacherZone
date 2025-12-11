import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';

/// Dependency Injection Container
/// إدارة التبعيات في التطبيق
class InjectionContainer {
  // Data Sources
  static AuthRemoteDataSource get authRemoteDataSource =>
      AuthRemoteDataSourceImpl();

  // Repositories
  static AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);

  // Use Cases
  static LoginUseCase get loginUseCase => LoginUseCase(authRepository);
}

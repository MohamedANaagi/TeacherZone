import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../core/errors/exceptions.dart';

/// Repository Implementation
/// يربط بين Domain Layer و Data Layer
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login({
    required String code,
    required String name,
    required String phone,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        code: code,
        name: name,
        phone: phone,
      );
      return userModel.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException('فشل تسجيل الدخول: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException('فشل تسجيل الخروج: ${e.toString()}');
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel?.toEntity();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AuthException('فشل جلب بيانات المستخدم: ${e.toString()}');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await remoteDataSource.isLoggedIn();
    } catch (e) {
      return false;
    }
  }
}

/// Custom Exceptions for the app
/// استثناءات مخصصة للتطبيق

/// Base Exception Class
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Authentication Exceptions
class AuthException extends AppException {
  AuthException(super.message, [super.code]);
}

/// Server/Network Exceptions
class ServerException extends AppException {
  ServerException(super.message, [super.code]);
}

/// Cache/Local Storage Exceptions
class CacheException extends AppException {
  CacheException(super.message, [super.code]);
}

/// Validation Exceptions
class ValidationException extends AppException {
  ValidationException(super.message, [super.code]);
}

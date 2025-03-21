class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final Map<String, List<String>> errors;

  ValidationException(this.errors);

  @override
  String toString() => 'ValidationException: $errors';
}

class StorageException implements Exception {
  final String message;

  StorageException(this.message);

  @override
  String toString() => 'StorageException: $message';
}

class RateLimitException implements Exception {
  final String message;

  RateLimitException(this.message);

  @override
  String toString() => 'RateLimitException: $message';
}

class AccountLockedException implements Exception {
  final String message;

  AccountLockedException(this.message);

  @override
  String toString() => 'AccountLockedException: $message';
}

class SessionExpiredException implements Exception {
  final String message;

  SessionExpiredException([
    this.message = 'Your session has expired. Please login again.',
  ]);

  @override
  String toString() => 'SessionExpiredException: $message';
}

class AuthCancelledException implements Exception {
  final String message;

  AuthCancelledException([this.message = 'Authentication was cancelled']);

  @override
  String toString() => 'AuthCancelledException: $message';
}

// lib/core/errors/app_exceptions.dart
// Domain exception hierarchy for RakshaSetu system

abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.code, super.details});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.details});
}

class OfflineQueueException extends AppException {
  const OfflineQueueException(super.message, {super.code, super.details});
}

class FirewallViolationException extends AppException {
  const FirewallViolationException(super.message, {super.code, super.details});
}

class CrisisProtocolException extends AppException {
  const CrisisProtocolException(super.message, {super.code, super.details});
}

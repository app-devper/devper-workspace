sealed class AppException implements Exception {
  final String message;
  final String code;

  const AppException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => "$runtimeType[$code]: $message";
}

final class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code = "INVALID",
  });
}

final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = "UNAUTHORIZED",
  });
}

final class ForbiddenException extends AppException {
  const ForbiddenException({
    required super.message,
    super.code = "FORBIDDEN",
  });
}

final class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = "NOT_FOUND",
  });
}

final class ConflictException extends AppException {
  final Map<String, dynamic>? payload;

  const ConflictException({
    required super.message,
    super.code = "CONFLICT",
    this.payload,
  });
}

final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code = "SERVER_ERROR",
  });
}

final class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code = "NETWORK_ERROR",
  });
}

final class UnknownHttpException extends AppException {
  final int statusCode;

  const UnknownHttpException({
    required super.message,
    required super.code,
    required this.statusCode,
  });
}

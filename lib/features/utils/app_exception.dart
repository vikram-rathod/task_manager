abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

// ─────────────────────────────────────────────────────────────────────────────
// API / Network
// ─────────────────────────────────────────────────────────────────────────────

/// The server returned a non-true status or an unexpected response shape.
class ApiException extends AppException {
  const ApiException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'ApiException: $message';
}

/// No internet / socket / timeout — Dio-level failures.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error. Please check your connection.',
    super.code,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// The server returned HTTP 401 — session expired or invalid token.
class UnauthorisedException extends AppException {
  const UnauthorisedException({
    super.message = 'Session expired. Please log in again.',
  });

  @override
  String toString() => 'UnauthorisedException: $message';
}

/// The server returned HTTP 403 — user lacks permission.
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'You do not have permission to perform this action.',
  });

  @override
  String toString() => 'ForbiddenException: $message';
}

/// The server returned HTTP 404.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// The server returned HTTP 5xx.
class ServerException extends AppException {
  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.code,
  });

  @override
  String toString() => 'ServerException: $message';
}

// ─────────────────────────────────────────────────────────────────────────────
// Data / Parsing
// ─────────────────────────────────────────────────────────────────────────────

/// JSON parsing or type-casting failed (e.g. String is not Map).
class ParseException extends AppException {
  const ParseException({
    super.message = 'Failed to parse server response.',
    super.code,
  });

  @override
  String toString() => 'ParseException: $message';
}

/// A required field was missing or empty in the response.
class MissingDataException extends AppException {
  const MissingDataException({
    super.message = 'Required data is missing from the response.',
  });

  @override
  String toString() => 'MissingDataException: $message';
}

class AppExceptionMapper {
  AppExceptionMapper._();

  static AppException from(Object error) {
    if (error is AppException) return error;

    final msg = error.toString();

    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Network is unreachable')) {
      return const NetworkException();
    }

    if (msg.contains('TimeoutException') ||
        msg.contains('Connection timeout')) {
      return const NetworkException(
        message: 'Request timed out. Please check your connection.',
      );
    }

    if (msg.contains('FormatException') ||
        msg.contains('type \'String\' is not a subtype') ||
        msg.contains('is not a subtype of type \'Map')) {
      return const ParseException();
    }

    return ApiException(message: msg);
  }
}
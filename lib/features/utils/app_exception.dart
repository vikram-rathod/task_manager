import 'package:dio/dio.dart';

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

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkException(
            message: 'Request timed out. Please check your connection.',
          );
        case DioExceptionType.connectionError:
          return const NetworkException();
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final serverMsg = _extractServerMessage(error.response);
          if (statusCode == 401) return const UnauthorisedException();
          if (statusCode == 403) return const ForbiddenException();
          if (statusCode == 404) return const NotFoundException();
          if (statusCode != null && statusCode >= 500) {
            return ServerException(message: serverMsg ?? 'A server error occurred.');
          }
          return ApiException(message: serverMsg ?? 'Unexpected error (HTTP $statusCode).');
        case DioExceptionType.cancel:
          return const ApiException(message: 'Request was cancelled.');
        default:
          return ApiException(message: error.message ?? 'Unknown network error.');
      }
    }

    //  Dart core errors
    if (error is FormatException) return const ParseException();

    final msg = error.toString();
    if (msg.contains('SocketException') || msg.contains('Network is unreachable')) {
      return const NetworkException();
    }

    return ApiException(message: msg);
  }

  /// Tries to extract a human-readable message from the server response body.
  static String? _extractServerMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map) {
        return data['message'] as String? ??
            data['error'] as String? ??
            data['msg'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
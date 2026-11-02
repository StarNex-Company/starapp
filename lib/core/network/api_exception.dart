import 'package:dio/dio.dart';

/// Every failure the API layer can surface. Repositories throw these (never
/// a raw [DioException]), so screens can show [message] and branch on the
/// type, e.g. send the user to sign in on [UnauthorizedException].
sealed class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  /// Safe to show to the user.
  final String message;
  final int? statusCode;

  /// Maps a Dio failure, reading the server's `message` and `errors` fields
  /// when the response body has them.
  factory ApiException.fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const RequestCancelledException();
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        break;
    }

    final status = error.response?.statusCode;
    final body = error.response?.data;
    final serverMessage = body is Map ? body['message'] as String? : null;

    return switch (status) {
      401 => UnauthorizedException(serverMessage),
      403 => ForbiddenException(serverMessage),
      404 => NotFoundException(serverMessage),
      400 || 409 || 422 => ValidationException(
        serverMessage ?? 'Please check the details and try again.',
        statusCode: status,
        fieldErrors: _fieldErrors(body),
      ),
      final int code when code >= 500 => ServerException(statusCode: code),
      _ => UnknownApiException(statusCode: status),
    };
  }

  /// `{"errors": {"email": ["Already taken"]}}` or `{"errors": {"email":
  /// "Already taken"}}` → `{"email": "Already taken"}`.
  static Map<String, String> _fieldErrors(Object? body) {
    final errors = body is Map ? body['errors'] : null;
    if (errors is! Map) return const {};
    return {
      for (final MapEntry(:key, :value) in errors.entries)
        '$key': value is List && value.isNotEmpty ? '${value.first}' : '$value',
    };
  }

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

/// No connection, or the server took too long.
class NetworkException extends ApiException {
  const NetworkException()
    : super('No connection. Check your internet and try again.');
}

class RequestCancelledException extends ApiException {
  const RequestCancelledException() : super('Request cancelled.');
}

/// The session is missing or expired; the user has to sign in again.
class UnauthorizedException extends ApiException {
  const UnauthorizedException([String? message])
    : super(
        message ?? 'Your session has ended. Please sign in again.',
        statusCode: 401,
      );
}

class ForbiddenException extends ApiException {
  const ForbiddenException([String? message])
    : super(message ?? "You don't have access to this.", statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException([String? message])
    : super(message ?? "We couldn't find that.", statusCode: 404);
}

/// The request was rejected; [fieldErrors] maps form fields to messages.
class ValidationException extends ApiException {
  const ValidationException(
    super.message, {
    super.statusCode,
    this.fieldErrors = const {},
  });

  final Map<String, String> fieldErrors;
}

class ServerException extends ApiException {
  const ServerException({super.statusCode})
    : super('Something went wrong on our side. Please try again.');
}

class UnknownApiException extends ApiException {
  const UnknownApiException({super.statusCode})
    : super('Something went wrong. Please try again.');
}

/// What to tell the user about any caught error: the API's message, or a
/// generic line for anything else.
String describeError(Object error) => error is ApiException
    ? error.message
    : 'Something went wrong. Please try again.';

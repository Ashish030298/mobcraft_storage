/// Base exception class for all Mobcraft Storage errors.
///
/// This exception contains a human-readable [message], an error [code]
/// for programmatic handling, and an optional HTTP [statusCode].
class MobcraftException implements Exception {
  /// Creates a new [MobcraftException].
  const MobcraftException({
    required this.message,
    required this.code,
    this.statusCode,
  });

  /// A human-readable error message.
  final String message;

  /// A machine-readable error code.
  final String code;

  /// The HTTP status code, if applicable.
  final int? statusCode;

  @override
  String toString() => 'MobcraftException: $message (code: $code)';
}

/// Thrown when authentication fails.
///
/// This typically occurs when the API key is invalid, expired, or missing.
class AuthenticationException extends MobcraftException {
  /// Creates a new [AuthenticationException].
  const AuthenticationException({
    super.message = 'Authentication failed. Please check your API key.',
    super.code = 'AUTHENTICATION_ERROR',
    super.statusCode = 401,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Thrown when the storage quota is exceeded.
///
/// This occurs when uploading a file that would exceed the user's
/// storage limit based on their current tier.
class QuotaExceededException extends MobcraftException {
  /// Creates a new [QuotaExceededException].
  const QuotaExceededException({
    super.message = 'Storage quota exceeded. Please upgrade your plan or delete some files.',
    super.code = 'QUOTA_EXCEEDED',
    super.statusCode = 413,
  });

  @override
  String toString() => 'QuotaExceededException: $message';
}

/// Thrown when a requested file is not found.
///
/// This occurs when trying to access, download, or delete a file
/// that doesn't exist or has been deleted.
class FileNotFoundException extends MobcraftException {
  /// Creates a new [FileNotFoundException].
  const FileNotFoundException({
    super.message = 'The requested file was not found.',
    super.code = 'FILE_NOT_FOUND',
    super.statusCode = 404,
  });

  @override
  String toString() => 'FileNotFoundException: $message';
}

/// Thrown when a network error occurs.
///
/// This includes connection timeouts, DNS failures, and other
/// network-related issues.
class NetworkException extends MobcraftException {
  /// Creates a new [NetworkException].
  const NetworkException({
    super.message = 'A network error occurred. Please check your internet connection.',
    super.code = 'NETWORK_ERROR',
    super.statusCode,
  });

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when the file size exceeds the allowed limit.
///
/// Each tier has a maximum file size limit. This exception is thrown
/// when attempting to upload a file larger than allowed.
class FileSizeLimitException extends MobcraftException {
  /// Creates a new [FileSizeLimitException].
  const FileSizeLimitException({
    super.message = 'File size exceeds the maximum allowed limit for your tier.',
    super.code = 'FILE_SIZE_LIMIT',
    super.statusCode = 413,
  });

  @override
  String toString() => 'FileSizeLimitException: $message';
}

/// Thrown when the server returns an unexpected error.
///
/// This is a catch-all for server errors that don't fit into
/// other exception categories.
class ServerException extends MobcraftException {
  /// Creates a new [ServerException].
  const ServerException({
    super.message = 'An unexpected server error occurred.',
    super.code = 'SERVER_ERROR',
    super.statusCode = 500,
  });

  @override
  String toString() => 'ServerException: $message';
}

/// Thrown when the request is malformed or invalid.
///
/// This occurs when required parameters are missing or invalid.
class BadRequestException extends MobcraftException {
  /// Creates a new [BadRequestException].
  const BadRequestException({
    super.message = 'The request was invalid.',
    super.code = 'BAD_REQUEST',
    super.statusCode = 400,
  });

  @override
  String toString() => 'BadRequestException: $message';
}

/// Thrown when the rate limit is exceeded.
///
/// This occurs when too many requests are made in a short period.
class RateLimitException extends MobcraftException {
  /// Creates a new [RateLimitException].
  const RateLimitException({
    super.message = 'Rate limit exceeded. Please try again later.',
    super.code = 'RATE_LIMIT',
    super.statusCode = 429,
  });

  @override
  String toString() => 'RateLimitException: $message';
}

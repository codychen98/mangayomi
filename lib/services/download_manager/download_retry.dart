import 'dart:async';

import 'package:mangayomi/utils/log/logger.dart';

const kDefaultDownloadRetries = 3;
const kMaxRateLimitRetries = 12;
const kMaxBackoffSeconds = 60;

/// HTTP status codes that indicate temporary server overload / throttling.
bool isRateLimitStatusCode(int statusCode) =>
    statusCode == 429 || statusCode == 503;

/// Whether [error] represents server throttling (429/503), including wrapped
/// pool/M3U8 exceptions from nested downloads.
bool isRateLimitDownloadError(Object error) {
  if (error is DownloadRateLimitException) return true;
  final message = error.toString();
  return message.contains('status 429') ||
      message.contains('status 503') ||
      message.contains('DownloadRateLimitException');
}

int? parseRetryAfterSeconds(Map<String, String> headers) {
  final value = headers['retry-after'] ?? headers['Retry-After'];
  if (value == null) return null;
  return int.tryParse(value.trim());
}

Duration rateLimitRetryDelay(int attempt, {int? retryAfterSeconds}) {
  if (retryAfterSeconds != null && retryAfterSeconds > 0) {
    return Duration(
      seconds: retryAfterSeconds.clamp(1, kMaxBackoffSeconds),
    );
  }
  final seconds =
      (2 * (1 << (attempt - 1).clamp(0, 5))).clamp(2, kMaxBackoffSeconds);
  return Duration(seconds: seconds);
}

/// Retries [operation]. Rate-limit errors get extended retries with
/// exponential backoff and optional `Retry-After` honouring.
Future<T> withDownloadRetry<T>(
  Future<T> Function() operation, {
  int maxRetries = kDefaultDownloadRetries,
  int maxRateLimitRetries = kMaxRateLimitRetries,
}) async {
  var attempts = 0;
  var rateLimitAttempts = 0;

  while (true) {
    try {
      attempts++;
      return await operation();
    } on DownloadRateLimitException catch (e) {
      rateLimitAttempts++;
      if (rateLimitAttempts >= maxRateLimitRetries) {
        throw DownloadRateLimitException(
          'Rate limit retries exhausted after $maxRateLimitRetries attempts',
          e.statusCode,
          retryAfterSeconds: e.retryAfterSeconds,
          cause: e,
        );
      }
      final delay = rateLimitRetryDelay(
        rateLimitAttempts,
        retryAfterSeconds: e.retryAfterSeconds,
      );
      AppLogger.log(
        '[DOWNLOAD_RETRY] kind=rate_limit attempt=$rateLimitAttempts/'
        '$maxRateLimitRetries status=${e.statusCode} '
        'delay=${delay.inSeconds}s error=$e',
        logLevel: LogLevel.warning,
      );
      await Future.delayed(delay);
      attempts--;
    } catch (e) {
      if (isRateLimitDownloadError(e)) {
        rateLimitAttempts++;
        if (rateLimitAttempts >= maxRateLimitRetries) rethrow;
        final delay = rateLimitRetryDelay(rateLimitAttempts);
        AppLogger.log(
          '[DOWNLOAD_RETRY] kind=rate_limit_wrapped attempt=$rateLimitAttempts/'
          '$maxRateLimitRetries delay=${delay.inSeconds}s error=$e',
          logLevel: LogLevel.warning,
        );
        await Future.delayed(delay);
        attempts--;
        continue;
      }
      if (attempts >= maxRetries) rethrow;
      AppLogger.log(
        '[DOWNLOAD_RETRY] kind=transient attempt=$attempts/$maxRetries error=$e',
        logLevel: LogLevel.warning,
      );
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }
}

class DownloadRateLimitException implements Exception {
  final String message;
  final int statusCode;
  final int? retryAfterSeconds;
  final Object? cause;

  DownloadRateLimitException(
    this.message,
    this.statusCode, {
    this.retryAfterSeconds,
    this.cause,
  });

  @override
  String toString() =>
      'DownloadRateLimitException: $message (status $statusCode)'
      '${retryAfterSeconds != null ? ', retryAfter=${retryAfterSeconds}s' : ''}'
      '${cause != null ? ' ($cause)' : ''}';
}

import 'package:flutter/foundation.dart';

/// Logging severity levels.
enum LogLevel { debug, info, warn, error }

/// Structured application logger.
///
/// Formats output as `[LEVEL] [HH:mm:ss] [TAG] message` and supports
/// custom sinks for future file writing.
class AppLogger {
  static final AppLogger instance = AppLogger._();
  AppLogger._();

  /// Optional listener hook for file logging or crash reporting.
  void Function(LogLevel level, String tag, String message, Object? error, StackTrace? stackTrace)? onLog;

  String _timestamp() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _log(LogLevel level, String tag, String message, [Object? error, StackTrace? stackTrace]) {
    final levelStr = level.name.toUpperCase().padRight(5);
    final formatted = '[$levelStr] [${_timestamp()}] [$tag] $message';

    if (kDebugMode) {
      debugPrint(formatted);
      if (error != null) {
        debugPrint('  Exception: $error');
      }
      if (stackTrace != null) {
        debugPrint('  StackTrace: $stackTrace');
      }
    }

    onLog?.call(level, tag, message, error, stackTrace);
  }

  /// Logs a debug message.
  void debug(String tag, String message) => _log(LogLevel.debug, tag, message);

  /// Logs an informational message.
  void info(String tag, String message) => _log(LogLevel.info, tag, message);

  /// Logs a warning message.
  void warn(String tag, String message) => _log(LogLevel.warn, tag, message);

  /// Logs an error message with optional exception and stack trace.
  void error(String tag, String message, [Object? error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, tag, message, error, stackTrace);
}

import 'package:flutter/foundation.dart';

enum LogLevel {
  debug(0),
  info(1),
  warn(2),
  error(3);

  final int priority;

  const LogLevel(this.priority);
}

class Logger {
  static LogLevel level = kDebugMode ? LogLevel.debug : LogLevel.warn;

  static void debug(Type context, String message) => _log(LogLevel.debug, context, message);
  static void info(Type context, String message) => _log(LogLevel.info, context, message);
  static void warn(Type context, String message) => _log(LogLevel.warn, context, message);
  static void warnException(Type context, Exception exception) => _log(LogLevel.warn, context, exception.toString());
  static void error(Type context, String message) => _log(LogLevel.error, context, message);
  static void exception(Type context, Exception exception) => _log(LogLevel.error, context, exception.toString());

  static void _log(LogLevel level, Type context, String message) {
    if (level.priority < Logger.level.priority) return;
    final now = DateTime.now();
    final timestamp = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    final tag = level.name.toUpperCase();

    // ignore: avoid_print
    print('[$tag $timestamp] $context: $message');
  }
}

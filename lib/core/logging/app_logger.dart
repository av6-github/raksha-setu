// lib/core/logging/app_logger.dart
// Privacy-preserving structured logger for RakshaSetu system

import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static const List<String> _sensitiveKeys = [
    'password',
    'token',
    'secret',
    'key',
    'authorization',
    'phq9',
    'gad7',
    'clinical',
    'stress_score',
    'voice_note'
  ];

  static void debug(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.debug, message, data);
  }

  static void info(String message, {Map<String, dynamic>? data}) {
    _log(LogLevel.info, message, data);
  }

  static void warning(String message, {Map<String, dynamic>? data, Object? error}) {
    _log(LogLevel.warning, message, data, error);
  }

  static void error(String message, {Map<String, dynamic>? data, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, data, error, stackTrace);
  }

  static void _log(
    LogLevel level,
    String message,
    Map<String, dynamic>? data, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final sanitizedData = _sanitize(data);
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [${level.name.toUpperCase()}] $message'
        '${sanitizedData.isNotEmpty ? ' | data: $sanitizedData' : ''}'
        '${error != null ? ' | error: $error' : ''}';

    if (kDebugMode) {
      debugPrint(logMessage);
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }
  }

  static Map<String, dynamic> _sanitize(Map<String, dynamic>? input) {
    if (input == null) return {};
    final cleaned = <String, dynamic>{};
    for (final entry in input.entries) {
      final keyLower = entry.key.toLowerCase();
      final isSensitive = _sensitiveKeys.any((s) => keyLower.contains(s));
      cleaned[entry.key] = isSensitive ? '[REDACTED]' : entry.value;
    }
    return cleaned;
  }
}

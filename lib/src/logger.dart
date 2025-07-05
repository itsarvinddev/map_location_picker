import 'package:flutter/foundation.dart';

class MyLogger {
  final String tag;

  MyLogger(this.tag);

  void _log(String level, String message, {Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();

    buffer.write("[$timestamp][$tag][$level]: $message");

    if (error != null) {
      buffer.write(" | Error: $error");
    }
    if (stackTrace != null) {
      buffer.write("\nStackTrace: $stackTrace");
    }

    if (kDebugMode) {
      print(buffer.toString());
    }
  }

  void t(String message, {Object? error, StackTrace? stackTrace}) =>
      _log('TRACE', message, error: error, stackTrace: stackTrace);

  void d(String message, {Object? error, StackTrace? stackTrace}) =>
      _log('DEBUG', message, error: error, stackTrace: stackTrace);

  void i(String message, {Object? error, StackTrace? stackTrace}) =>
      _log('INFO', message, error: error, stackTrace: stackTrace);

  void w(String message, {Object? error, StackTrace? stackTrace}) =>
      _log('WARN', message, error: error, stackTrace: stackTrace);

  void e(String message, {Object? error, StackTrace? stackTrace}) =>
      _log('ERROR', message, error: error, stackTrace: stackTrace);

  void f(String message, {Object? error, StackTrace? stackTrace}) =>
      _log('FATAL', message, error: error, stackTrace: stackTrace);
}
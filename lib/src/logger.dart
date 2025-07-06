import 'package:flutter/foundation.dart';

final mapLogger = MyLogger('Map Location Picker');

class MyLogger {
  final String tag;

  MyLogger(this.tag);

  void _log(String level, Object? message,
      {Object? error, StackTrace? stackTrace}) {
    final buffer = StringBuffer();

    buffer.write("[$tag][$level]: $message");

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

  void t(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log('TRACE', message, error: error, stackTrace: stackTrace);

  void d(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log('DEBUG', message, error: error, stackTrace: stackTrace);

  void i(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log('INFO', message, error: error, stackTrace: stackTrace);

  void w(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log('WARN', message, error: error, stackTrace: stackTrace);

  void e(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log('ERROR', message, error: error, stackTrace: stackTrace);

  void f(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _log('FATAL', message, error: error, stackTrace: stackTrace);
}

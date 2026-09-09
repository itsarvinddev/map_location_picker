import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

// -------------------
// --- FORMATTERS ---
// -------------------

/// Abstract class for formatting log messages.
abstract class LogFormatter {
  String format(
    String tag,
    String level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  });
}

/// Formats logs in a distinct block with separators.
class BlockPrettyFormatter implements LogFormatter {
  static const _separator =
      '--------------------------------------------------------------------------------';

  @override
  String format(
    String tag,
    String level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final time =
        '${now.hour}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    // Header
    buffer.writeln('[$tag] [$time]');

    // Message Block
    buffer.writeln(_separator);
    String messageBody;
    if (message is Map || message is List) {
      messageBody = JsonEncoder.withIndent('  ').convert(message);
    } else if (message is String) {
      try {
        messageBody = JsonEncoder.withIndent('  ').convert(jsonDecode(message));
      } catch (e) {
        messageBody = message; // Not a JSON string
      }
    } else {
      messageBody = message.toString();
    }

    // Indent the message body
    for (var line in messageBody.split('\n')) {
      buffer.writeln('  $line');
    }
    buffer.writeln(_separator);

    // Error Block
    if (error != null) {
      buffer.writeln('  Error: $error');
      buffer.writeln(_separator);
    }

    // StackTrace Block
    if (stackTrace != null) {
      buffer.writeln('  StackTrace:');
      for (var line in stackTrace.toString().split('\n')) {
        buffer.writeln('  $line');
      }
      buffer.writeln(_separator);
    }

    return buffer.toString();
  }
}

// ----------------
// --- LOGGER ---
// ----------------

/// Severity levels, ordered.
///
/// Set [MapLocationPickerLogger.level] to drop everything below a threshold,
/// or to [MapPickerLogLevel.off] to silence the package entirely.
enum MapPickerLogLevel {
  /// Everything.
  trace(700),

  /// Debug and above.
  debug(800),

  /// Info and above.
  info(900),

  /// Warnings and above.
  warn(1000),

  /// Errors and above.
  error(1100),

  /// Fatal only.
  fatal(1200),

  /// Nothing at all.
  off(10000);

  const MapPickerLogLevel(this.value);

  /// The numeric severity, matching `dart:developer` conventions.
  final int value;
}

/// The package's logger.
///
/// The single instance is [mapLogger]. It writes through `dart:developer` and
/// is a no-op in release builds unless [emitInRelease] is set.
///
/// ```dart
/// // Quieten the package.
/// mapLogger.level = MapPickerLogLevel.off;
///
/// // Or forward everything into your own crash reporter.
/// mapLogger.onLog = (level, message, error, stack) =>
///     Sentry.captureMessage('[' + level.name + '] ' + message.toString());
/// ```
class MapLocationPickerLogger {
  /// A label prefixed to every line.
  final String tag;

  final LogFormatter _formatter;

  /// The minimum level that is emitted. Defaults to
  /// [MapPickerLogLevel.trace] in debug builds.
  MapPickerLogLevel level = MapPickerLogLevel.trace;

  /// Whether to log in release builds. Off by default.
  bool emitInRelease = false;

  /// Receives every record that passes [level], before formatting.
  ///
  /// Set this to route the package's diagnostics into your own logging or
  /// crash-reporting stack.
  void Function(
    MapPickerLogLevel level,
    Object? message,
    Object? error,
    StackTrace? stackTrace,
  )?
  onLog;

  // Map string levels to integer levels for the developer log.
  static const _levelMap = {
    'TRACE': 700,
    'DEBUG': 800,
    'INFO': 900,
    'WARN': 1000,
    'ERROR': 1100,
    'FATAL': 1200,
  };

  /// Creates a logger.
  /// Defaults to [BlockPrettyFormatter] for clear, separated logging.
  MapLocationPickerLogger(this.tag, {LogFormatter? formatter})
    : _formatter = formatter ?? BlockPrettyFormatter();

  /// Pass error/stackTrace to the formatter to ensure they are included inside the separator blocks.
  void _log(
    String level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final resolved = MapPickerLogLevel.values.firstWhere(
      (l) => l.value == (_levelMap[level] ?? 900),
      orElse: () => MapPickerLogLevel.info,
    );
    if (resolved.value < this.level.value) return;

    onLog?.call(resolved, message, error, stackTrace);

    if (kDebugMode || emitInRelease) {
      // The formatter now handles the entire visual layout,
      // including error and stacktrace.
      final formattedMessage = _formatter.format(
        tag,
        level,
        message,
        error: error,
        stackTrace: stackTrace,
      );

      // We use developer.log to prevent truncation but no longer pass
      // the error/stackTrace arguments here, as they are already in the string.
      developer.log(
        formattedMessage,
        name: level,
        level: _levelMap[level] ?? 900,
      );
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

final mapLogger = MapLocationPickerLogger('Map Location Picker');

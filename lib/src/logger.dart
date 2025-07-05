import 'package:logger/logger.dart';

/// Logger for the app.
Logger mapLogger = Logger(
  /// Logger level.
  printer: PrettyPrinter(),
  level: Level.trace,
);

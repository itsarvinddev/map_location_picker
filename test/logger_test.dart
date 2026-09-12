// Pins the logger's two-sink contract:
//   * [MapLocationPickerLogger.onLog] is gated ONLY by `level`, so it keeps
//     delivering records in profile and release builds (crash reporting must
//     not require turning console output on).
//   * `emitInRelease` gates ONLY the `dart:developer` console copy, and it
//     gates it in every non-debug mode, profile included.
//
// `flutter test` always runs with kDebugMode == true, so the behavioural tests
// below cannot by themselves tell the two gates apart. Two things cover that:
//   * the source/doc contract group, which fails in an ordinary CI run if the
//     `onLog?.call` is ever moved inside the `kDebugMode || emitInRelease`
//     guard, or if the docs go back to claiming the logger is wholly silent
//     outside debug builds;
//   * an explicit release run:
//       flutter test --dart-define=dart.vm.product=true test/logger_test.dart
//     which makes kReleaseMode true and exercises the real release path.
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/src/logger.dart';

class SpyFormatter implements LogFormatter {
  int calls = 0;

  @override
  String format(
    String tag,
    String level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    calls++;
    return '$tag/$level/$message';
  }
}

void main() {
  group('behaviour', () {
    test(
      'onLog is a level-gated sink; emitInRelease only gates the console',
      () {
        final fmt = SpyFormatter();
        final log = MapLocationPickerLogger('t', formatter: fmt);
        final seen = <String>[];
        log.onLog = (l, m, e, s) => seen.add('${l.name}:$m');
        log.emitInRelease = false;

        log.e('boom');

        // onLog always fires once the level allows it - this is what makes it
        // usable as a crash-reporting sink in production.
        expect(seen, [
          'error:boom',
        ], reason: 'onLog must fire even in release with emitInRelease=false');

        // Console formatting/emission is the thing emitInRelease gates.
        expect(
          fmt.calls,
          kDebugMode ? 1 : 0,
          reason: 'developer.log path must be silent outside debug by default',
        );
      },
    );

    test('emitInRelease=true turns the console back on', () {
      final fmt = SpyFormatter();
      final log = MapLocationPickerLogger('t', formatter: fmt)
        ..emitInRelease = true;
      log.e('boom');
      expect(fmt.calls, 1);
    });

    test('level gates both sinks', () {
      final fmt = SpyFormatter();
      final log = MapLocationPickerLogger('t', formatter: fmt);
      final seen = <String>[];
      log.onLog = (l, m, e, s) => seen.add(l.name);
      log.level = MapPickerLogLevel.off;
      log.e('dropped');
      expect(seen, isEmpty);
      expect(fmt.calls, 0);
    });
  });

  // These run in an ordinary `flutter test` (and therefore in CI), where the
  // behavioural tests above cannot distinguish the two gates.
  group('source and doc contract', () {
    final src = File('lib/src/logger.dart').readAsStringSync();

    test('onLog stays outside the console-only build-mode guard', () {
      final guard = src.indexOf('if (kDebugMode || emitInRelease)');
      final call = src.indexOf('onLog?.call(');
      expect(guard, greaterThan(-1), reason: 'console guard not found');
      expect(call, greaterThan(-1), reason: 'onLog dispatch not found');
      expect(
        call,
        lessThan(guard),
        reason:
            'onLog must not be gated by kDebugMode || emitInRelease; '
            'doing so would kill crash reporting in release builds',
      );
    });

    test('docs do not claim the whole logger is silent outside debug', () {
      expect(
        src.contains('is a no-op in release builds'),
        isFalse,
        reason: 'onLog fires in release; the blanket no-op claim is false',
      );
      expect(
        src.contains('/// Whether to log in release builds.'),
        isFalse,
        reason: 'emitInRelease gates only the dart:developer console copy',
      );
    });

    test('level docs do not tie its default to debug builds', () {
      expect(
        src.contains('[MapPickerLogLevel.trace] in debug builds'),
        isFalse,
        reason: 'level defaults to trace in every build mode',
      );
    });
  });
}

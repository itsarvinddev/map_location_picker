import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The JS-interop web implementation (`lib/src/autocomplete/`) was deleted: the
/// package now has ONE REST transport on every platform, and
/// `places.googleapis.com` answers CORS preflights. Any surviving prose that
/// claims the REST endpoint is CORS-blocked on web, or that a Maps JavaScript
/// API implementation of *search* is selected there, is now false.
void main() {
  group('docs do not describe the deleted JS-interop web path', () {
    final sources =
        [
          ...Directory('lib').listSync(recursive: true),
          ...Directory('test').listSync(recursive: true),
          ...Directory('example/lib').listSync(recursive: true),
          File('README.md'),
          File('CHANGELOG.md'),
          File('MIGRATION_GUIDE.md'),
          File('CONTRIBUTING.md'),
          File('example/web/index.html'),
        ].whereType<File>().where(
          (f) =>
              // A listed doc may legitimately be renamed or removed later; the
              // guard should then go quiet, not crash with PathNotFoundException.
              f.existsSync() &&
              // This file quotes the banned phrases in order to look for them.
              !f.path.endsWith('doc_accuracy_test.dart') &&
              (f.path.endsWith('.dart') ||
                  f.path.endsWith('.md') ||
                  f.path.endsWith('.html')),
        );

    test('nothing claims the Places REST endpoint is blocked by CORS', () {
      final offenders = <String>[];
      for (final file in sources) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          // Join with the next line: the claim is often split by wrapping.
          final window =
              '${lines[i]} ${i + 1 < lines.length ? lines[i + 1] : ''}';
          if (RegExp(
            r'(REST\s+endpoint|REST\s+API)[^.]{0,80}blocked\s+by\s+CORS',
            caseSensitive: false,
          ).hasMatch(window)) {
            offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });

    test('nothing claims a Maps JavaScript API implementation is used for '
        'search on web', () {
      final offenders = <String>[];
      for (final file in sources) {
        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final window =
              '${lines[i]} ${i + 1 < lines.length ? lines[i + 1] : ''}';
          if (RegExp(
            r'web\s+implementation\s*\(\s*Maps\s+JavaScript\s+API\s*\)',
            caseSensitive: false,
          ).hasMatch(window)) {
            offenders.add('${file.path}:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
      expect(offenders, isEmpty, reason: offenders.join('\n'));
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';

void main() {
  group('googleStaticMapWithMarker', () {
    test('builds a well-formed static map url', () {
      final url = googleStaticMapWithMarker(
        12.5,
        -77.25,
        16,
        width: 640,
        height: 480,
        apiKey: 'KEY',
      );
      expect(url, contains('center=12.5,-77.25'));
      expect(url, contains('zoom=16'));
      expect(url, contains('size=640x480'));
      expect(url, contains('key=KEY'));
    });
  });

  group('MapLocationPickerConfig', () {
    test('copyWith preserves unset fields', () {
      const config = MapLocationPickerConfig(apiKey: 'a', initialZoom: 9);
      final next = config.copyWith(apiKey: 'b');
      expect(next.apiKey, 'b');
      expect(next.initialZoom, 9);
    });
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';

/// A geocoding client that returns canned results after a controllable delay,
/// so response ordering can be exercised deterministically.
class _FakeGeoCoding extends GeoCodingConfig {
  _FakeGeoCoding() : super(apiKey: 'test');

  /// Completers keyed by the order calls arrive in.
  final List<Completer<(GeocodingResult?, List<GeocodingResult>)>> pending = [];

  @override
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position,
  ) {
    final completer = Completer<(GeocodingResult?, List<GeocodingResult>)>();
    pending.add(completer);
    return completer.future;
  }

  void complete(int index, String address) {
    final result = GeocodingResult(formattedAddress: address);
    pending[index].complete((result, [result]));
  }
}

GeocodingResult _result(String address) =>
    GeocodingResult(formattedAddress: address);

void main() {
  group('MapLocationPickerController', () {
    test('starts at the configured position and map type', () {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          initialPosition: LatLng(1, 2),
          initialMapType: MapType.satellite,
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.position, const LatLng(1, 2));
      expect(controller.mapType, MapType.satellite);
      expect(controller.isLoading, isFalse);
      expect(controller.lastError, isNull);
      expect(controller.lastPositionChangeReason, PositionChangeReason.initial);
    });

    test('setMapType notifies and reports the change once', () {
      var changes = 0;
      var notifications = 0;
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(
          apiKey: 'k',
          onMapTypeChanged: (_) => changes++,
        ),
      );
      addTearDown(controller.dispose);
      controller.addListener(() => notifications++);

      controller.setMapType(MapType.terrain);
      expect(controller.mapType, MapType.terrain);
      expect(changes, 1);
      expect(notifications, 1);

      // Setting the same value again is a no-op.
      controller.setMapType(MapType.terrain);
      expect(changes, 1);
      expect(notifications, 1);
    });

    test('moveTo reports the marker position and the reason', () async {
      final moved = <LatLng>[];
      final geo = _FakeGeoCoding();
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(
          apiKey: 'k',
          onMainMarkerPositionChanged: moved.add,
        ),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      unawaited(
        controller.moveTo(
          const LatLng(10, 20),
          reason: PositionChangeReason.mapTap,
          animate: false,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(moved, [const LatLng(10, 20)]);
      expect(controller.position, const LatLng(10, 20));
      expect(controller.lastPositionChangeReason, PositionChangeReason.mapTap);
      expect(controller.isLoading, isTrue);

      geo.complete(0, 'somewhere');
      await Future<void>.delayed(Duration.zero);
      expect(controller.address, 'somewhere');
      expect(controller.isLoading, isFalse);
    });

    test('moving to the same position does not re-report it', () async {
      final moved = <LatLng>[];
      final geo = _FakeGeoCoding();
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(
          apiKey: 'k',
          onMainMarkerPositionChanged: moved.add,
        ),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      unawaited(controller.moveTo(const LatLng(5, 5), animate: false));
      unawaited(controller.moveTo(const LatLng(5, 5), animate: false));
      await Future<void>.delayed(Duration.zero);

      expect(moved.length, 1);
    });

    test('a slow earlier lookup cannot overwrite a newer one', () async {
      final geo = _FakeGeoCoding();
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'k'),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      // Two taps in quick succession.
      unawaited(controller.refreshAddress());
      unawaited(controller.refreshAddress());
      await Future<void>.delayed(Duration.zero);
      expect(geo.pending.length, 2);

      // The newer request lands first.
      geo.complete(1, 'newer');
      await Future<void>.delayed(Duration.zero);
      expect(controller.address, 'newer');

      // The older, slower response arrives afterwards and must be discarded.
      geo.complete(0, 'older');
      await Future<void>.delayed(Duration.zero);
      expect(
        controller.address,
        'newer',
        reason: 'a stale response must never overwrite a newer one',
      );
    });

    test('a response arriving after dispose does not throw', () async {
      final geo = _FakeGeoCoding();
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'k'),
        geoCodingConfig: geo,
      );

      unawaited(controller.refreshAddress());
      await Future<void>.delayed(Duration.zero);

      controller.dispose();

      // Previously this wrote a disposed ValueNotifier and threw
      // "A ValueNotifier<...> was used after being disposed".
      geo.complete(0, 'too late');
      await Future<void>.delayed(Duration.zero);
      expect(controller.address, isNot('too late'));
    });

    test('selectResult updates the address without moving the pin', () {
      final selected = <GeocodingResult>[];
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(
          apiKey: 'k',
          initialPosition: const LatLng(1, 1),
          onAddressSelected: selected.add,
        ),
      );
      addTearDown(controller.dispose);

      controller.selectResult(_result('a nearby place'));

      expect(controller.address, 'a nearby place');
      expect(controller.position, const LatLng(1, 1));
      expect(selected.length, 1);
    });

    test('confirm forwards the current result to onNext', () {
      GeocodingResult? confirmed;
      var calls = 0;
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(
          apiKey: 'k',
          onNext: (r) {
            confirmed = r;
            calls++;
          },
        ),
      );
      addTearDown(controller.dispose);

      controller.selectResult(_result('picked'));
      controller.confirm();

      expect(calls, 1, reason: 'confirm must fire onNext exactly once');
      expect(confirmed?.formattedAddress, 'picked');
    });

    test('an empty lookup falls back to noAddressFoundText', () async {
      final geo = _FakeGeoCoding();
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          noAddressFoundText: 'nothing here',
        ),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      unawaited(controller.refreshAddress());
      await Future<void>.delayed(Duration.zero);
      geo.pending[0].complete((null, const <GeocodingResult>[]));
      await Future<void>.delayed(Duration.zero);

      expect(controller.address, 'nothing here');
      expect(controller.result, isNull);
    });

    test('mapController times out instead of hanging forever', () async {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'k'),
      );
      addTearDown(controller.dispose);

      expect(controller.isMapReady, isFalse);
      await expectLater(
        controller.mapController.timeout(const Duration(milliseconds: 50)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}

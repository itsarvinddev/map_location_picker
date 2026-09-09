import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A scriptable [GeolocatorPlatform].
class _FakeGeolocator extends GeolocatorPlatform
    with MockPlatformInterfaceMixin {
  _FakeGeolocator({
    this.serviceEnabled = true,
    this.initialPermission = LocationPermission.whileInUse,
    this.permissionAfterRequest,
    this.position,
    this.lastKnown,
    this.currentPositionDelay,
  });

  bool serviceEnabled;
  LocationPermission initialPermission;
  LocationPermission? permissionAfterRequest;
  Position? position;
  Position? lastKnown;
  Duration? currentPositionDelay;

  int requestPermissionCalls = 0;
  int getCurrentPositionCalls = 0;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => initialPermission;

  @override
  Future<LocationPermission> requestPermission() async {
    requestPermissionCalls++;
    return permissionAfterRequest ?? initialPermission;
  }

  @override
  Future<Position?> getLastKnownPosition({
    bool forceLocationManager = false,
  }) async => lastKnown;

  @override
  Future<Position> getCurrentPosition({
    LocationSettings? locationSettings,
  }) async {
    getCurrentPositionCalls++;
    if (currentPositionDelay != null) {
      await Future<void>.delayed(currentPositionDelay!);
    }
    final result = position;
    if (result == null) throw Exception('no fix');
    return result;
  }
}

Position _position(double lat, double lng) => Position(
  latitude: lat,
  longitude: lng,
  timestamp: DateTime.fromMillisecondsSinceEpoch(0),
  accuracy: 1,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

/// Geocoding client that never resolves, so these tests only exercise the
/// location flow.
class _StubGeoCoding extends GeoCodingConfig {
  _StubGeoCoding() : super(apiKey: 'test');

  @override
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position,
  ) async => (null, const <GeocodingResult>[]);
}

void main() {
  late List<MapLocationPickerException> errors;

  MapLocationPickerController build() {
    errors = [];
    return MapLocationPickerController(
      config: MapLocationPickerConfig(
        apiKey: 'k',
        initialPosition: const LatLng(1, 1),
        onError: errors.add,
      ),
      geoCodingConfig: _StubGeoCoding(),
    );
  }

  group('goToCurrentLocation permission handling', () {
    test('moves the pin once permission is granted on request', () async {
      // The regression: the old guard read
      //   `p != whileInUse || p != always`
      // which no enum value can fail, so the very first grant returned early
      // and the button appeared to do nothing.
      final fake = _FakeGeolocator(
        initialPermission: LocationPermission.denied,
        permissionAfterRequest: LocationPermission.whileInUse,
        position: _position(51.5, -0.12),
      );
      GeolocatorPlatform.instance = fake;

      final controller = build();
      addTearDown(controller.dispose);

      await controller.goToCurrentLocation();

      expect(fake.requestPermissionCalls, 1);
      expect(fake.getCurrentPositionCalls, 1);
      expect(controller.position, const LatLng(51.5, -0.12));
      expect(errors, isEmpty);
    });

    test('works when permission was already granted', () async {
      final fake = _FakeGeolocator(
        initialPermission: LocationPermission.always,
        position: _position(10, 20),
      );
      GeolocatorPlatform.instance = fake;

      final controller = build();
      addTearDown(controller.dispose);

      await controller.goToCurrentLocation();

      expect(fake.requestPermissionCalls, 0);
      expect(controller.position, const LatLng(10, 20));
    });

    test('reports a denied permission instead of returning silently', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(
        initialPermission: LocationPermission.denied,
        permissionAfterRequest: LocationPermission.denied,
      );

      final controller = build();
      addTearDown(controller.dispose);

      await controller.goToCurrentLocation();

      expect(errors.single.kind, MapPickerErrorKind.locationPermissionDenied);
      expect(controller.isLoading, isFalse);
    });

    test('distinguishes deniedForever, which needs system settings', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(
        initialPermission: LocationPermission.deniedForever,
      );

      final controller = build();
      addTearDown(controller.dispose);

      await controller.goToCurrentLocation();

      expect(
        errors.single.kind,
        MapPickerErrorKind.locationPermissionDeniedForever,
      );
    });

    test('reports location services being switched off', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(serviceEnabled: false);

      final controller = build();
      addTearDown(controller.dispose);

      await controller.goToCurrentLocation();

      expect(errors.single.kind, MapPickerErrorKind.locationServiceDisabled);
      expect(controller.isLoading, isFalse);
    });

    test('clears the loading flag even when the lookup throws', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(
        initialPermission: LocationPermission.whileInUse,
        position: null, // getCurrentPosition throws
      );

      final controller = build();
      addTearDown(controller.dispose);

      await controller.goToCurrentLocation();

      expect(controller.isLoading, isFalse);
      expect(errors, isNotEmpty);
    });
  });

  group('startWithCurrentLocation', () {
    test('centres on the device position when it resolves', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(
        initialPermission: LocationPermission.whileInUse,
        position: _position(48.85, 2.35),
      );

      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          initialPosition: LatLng(1, 1),
          startWithCurrentLocation: true,
        ),
        geoCodingConfig: _StubGeoCoding(),
      );
      addTearDown(controller.dispose);

      await controller.initialise();

      expect(controller.position, const LatLng(48.85, 2.35));
      expect(
        controller.lastPositionChangeReason,
        PositionChangeReason.currentLocation,
      );
    });

    test('falls back to initialPosition without nagging on refusal', () async {
      GeolocatorPlatform.instance = _FakeGeolocator(
        initialPermission: LocationPermission.denied,
        permissionAfterRequest: LocationPermission.denied,
      );

      final errs = <MapLocationPickerException>[];
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(
          apiKey: 'k',
          initialPosition: const LatLng(1, 1),
          startWithCurrentLocation: true,
          onError: errs.add,
        ),
        geoCodingConfig: _StubGeoCoding(),
      );
      addTearDown(controller.dispose);

      await controller.initialise();

      expect(controller.position, const LatLng(1, 1));
      expect(
        errs.where((e) => e.kind.name.startsWith('location')),
        isEmpty,
        reason: 'opening the picker should not raise a permission error',
      );
    });

    test(
      'falls back to the last known position when the fix times out',
      () async {
        GeolocatorPlatform.instance = _FakeGeolocator(
          initialPermission: LocationPermission.whileInUse,
          currentPositionDelay: const Duration(seconds: 5),
          position: _position(0, 0),
          lastKnown: _position(35.68, 139.69),
        );

        final controller = MapLocationPickerController(
          config: const MapLocationPickerConfig(
            apiKey: 'k',
            initialPosition: LatLng(1, 1),
            startWithCurrentLocation: true,
            locationTimeout: Duration(milliseconds: 20),
          ),
          geoCodingConfig: _StubGeoCoding(),
        );
        addTearDown(controller.dispose);

        await controller.initialise();

        expect(controller.position, const LatLng(35.68, 139.69));
      },
    );
  });
}

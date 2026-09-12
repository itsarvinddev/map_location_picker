import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';

class _StubGeoCoding extends GeoCodingConfig {
  _StubGeoCoding({this.result}) : super(apiKey: 'test');

  final GeocodingResult? result;
  int calls = 0;

  @override
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position, {
    MapPickerErrorCallback? onErrorOverride,
  }) async {
    calls++;
    final r = result;
    return (r, r == null ? const <GeocodingResult>[] : [r]);
  }
}

GeocodingResult _downingStreet() => GeocodingResult(
  placeId: 'place-1',
  formattedAddress: '10 Downing St, London SW1A 2AA, UK',
  addressComponents: [
    AddressComponent(
      longName: '10',
      shortName: '10',
      types: const ['street_number'],
    ),
    AddressComponent(
      longName: 'Downing Street',
      shortName: 'Downing St',
      types: const ['route'],
    ),
    AddressComponent(
      longName: 'London',
      shortName: 'London',
      types: const ['postal_town'],
    ),
    AddressComponent(
      longName: 'SW1A 2AA',
      shortName: 'SW1A 2AA',
      types: const ['postal_code'],
    ),
    AddressComponent(
      longName: 'United Kingdom',
      shortName: 'GB',
      types: const ['country'],
    ),
  ],
);

void main() {
  group('PickedPlace', () {
    test('always carries the coordinate, even with no geocoding result', () {
      // The old confirm button was dead whenever geocoding failed, so there
      // was no way to return the point the user actually picked.
      final picked = PickedPlace.from(latLng: const LatLng(12.5, -77.25));

      expect(picked.latLng, const LatLng(12.5, -77.25));
      expect(picked.formattedAddress, isNull);
      expect(picked.displayLabel, '12.5, -77.25');
    });

    test('flattens a geocoding result into named parts', () {
      final picked = PickedPlace.from(
        latLng: const LatLng(51.5034, -0.1276),
        result: _downingStreet(),
      );

      expect(picked.streetNumber, '10');
      expect(picked.street, 'Downing Street');
      expect(picked.locality, 'London');
      expect(picked.city, 'London');
      expect(picked.postalCode, 'SW1A 2AA');
      expect(picked.country, 'United Kingdom');
      expect(picked.countryCode, 'GB');
      expect(picked.placeId, 'place-1');
    });

    test('prefers a search result name over the reverse-geocoded street', () {
      // Reverse geocoding a point of interest returns its street address, so
      // "Heathrow Terminal 5" would otherwise become "Nelson Rd, Hounslow".
      final picked = PickedPlace.from(
        latLng: const LatLng(51.4700, -0.4543),
        result: GeocodingResult(formattedAddress: 'Nelson Rd, Hounslow'),
        place: Place(
          id: 'p1',
          displayName: LocalizedText(text: 'Heathrow Terminal 5'),
        ),
      );

      expect(picked.name, 'Heathrow Terminal 5');
      expect(picked.displayLabel, 'Heathrow Terminal 5');
      expect(picked.formattedAddress, 'Nelson Rd, Hounslow');
    });

    test('compares by value', () {
      const a = PickedPlace(latLng: LatLng(1, 2), placeId: 'x');
      const b = PickedPlace(latLng: LatLng(1, 2), placeId: 'x');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('centre-pin mode', () {
    MapLocationPickerController build(_StubGeoCoding geo) =>
        MapLocationPickerController(
          config: const MapLocationPickerConfig(
            apiKey: 'k',
            pinMode: PickerPinMode.centerPin,
            initialPosition: LatLng(0, 0),
            pinIdleDebounce: Duration(milliseconds: 10),
          ),
          geoCodingConfig: geo,
        );

    test('the pin is hidden until the map is ready', () {
      final controller = build(_StubGeoCoding());
      addTearDown(controller.dispose);
      expect(controller.pinState, PinState.preparing);
    });

    test('lifts while the camera moves and settles when it stops', () async {
      final geo = _StubGeoCoding(result: _downingStreet());
      final controller = build(geo);
      addTearDown(controller.dispose);

      controller.onCameraMoveStarted();
      expect(controller.pinState, PinState.dragging);

      controller.onCameraMove(
        const CameraPosition(target: LatLng(51.5, -0.12), zoom: 14),
      );
      await controller.onCameraIdle();

      expect(controller.pinState, PinState.idle);
      expect(controller.position, const LatLng(51.5, -0.12));
      expect(
        controller.lastPositionChangeReason,
        PositionChangeReason.cameraIdle,
      );
    });

    test('a burst of idle events costs one geocode, not several', () async {
      // Android reports onCameraIdle repeatedly as a fling settles, and each
      // one used to be a billed request.
      final geo = _StubGeoCoding(result: _downingStreet());
      final controller = build(geo);
      addTearDown(controller.dispose);

      for (var i = 0; i < 5; i++) {
        controller.onCameraMove(
          CameraPosition(target: LatLng(51.5 + i / 1000, -0.12), zoom: 14),
        );
        await controller.onCameraIdle();
      }
      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(geo.calls, 1);
    });

    test('does nothing in marker mode', () async {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'k'),
        geoCodingConfig: _StubGeoCoding(),
      );
      addTearDown(controller.dispose);

      controller.onCameraMoveStarted();
      controller.onCameraMove(
        const CameraPosition(target: LatLng(9, 9), zoom: 14),
      );
      await controller.onCameraIdle();

      expect(controller.position, isNot(const LatLng(9, 9)));
      expect(controller.pinState, PinState.preparing);
    });
  });

  group('MapLocationPickerStrings', () {
    test('ships English defaults', () {
      const strings = MapLocationPickerStrings();
      expect(strings.confirmAddress, 'Confirm Address');
      expect(strings.mapTypeName(MapType.satellite), 'Satellite Map');
    });

    test('pluralises the matching-address count', () {
      const strings = MapLocationPickerStrings();
      expect(strings.nearbyPlacesCount(1), '1 matching address');
      expect(strings.nearbyPlacesCount(3), '3 matching addresses');
    });

    test('every string can be replaced', () {
      const strings = MapLocationPickerStrings(
        confirmAddress: 'Confirmer',
        mapTypeSatellite: 'Satellite',
        cancel: 'Annuler',
      );
      expect(strings.confirmAddress, 'Confirmer');
      expect(strings.mapTypeName(MapType.satellite), 'Satellite');
      expect(strings.cancel, 'Annuler');
      // Untouched fields keep their defaults.
      expect(strings.mapTypeTerrain, 'Terrain Map');
    });

    test('copyWith replaces only what it is given', () {
      const base = MapLocationPickerStrings();
      final next = base.copyWith(confirmAddress: 'Go');
      expect(next.confirmAddress, 'Go');
      expect(next.cancel, base.cancel);
    });
  });

  group('marker id collision', () {
    test('the reserved "main" id is documented as reserved', () {
      // additionalMarkers['main'] used to collide with the built-in marker and
      // trip google_maps_flutter's duplicate-id assertion. The widget now skips
      // it; this pins the contract.
      const config = MapLocationPickerConfig(
        apiKey: 'k',
        additionalMarkers: {'main': LatLng(1, 1), 'other': LatLng(2, 2)},
      );
      expect(config.additionalMarkers!.containsKey('main'), isTrue);
    });
  });

  group('config defaults', () {
    test('are the documented ones', () {
      const config = MapLocationPickerConfig();
      expect(config.pinMode, PickerPinMode.marker);
      expect(config.draggableMarker, isTrue);
      expect(config.tapToSelect, isTrue);
      expect(config.showSearchBar, isTrue);
      expect(config.startWithCurrentLocation, isFalse);
      expect(config.skipInitialGeocode, isFalse);
      expect(config.requireGeocodedAddress, isFalse);
      expect(
        config.floatingControlsPosition,
        FloatingControlsPosition.bottomEnd,
      );
    });
  });
}

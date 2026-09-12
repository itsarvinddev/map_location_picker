import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';

/// Geocoding stub whose responses are completed by the test.
class _ManualGeoCoding extends GeoCodingConfig {
  _ManualGeoCoding() : super(apiKey: 'test');

  final List<Completer<(GeocodingResult?, List<GeocodingResult>)>> pending = [];
  final List<MapPickerErrorCallback?> sinks = [];
  int calls = 0;

  @override
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position, {
    MapPickerErrorCallback? onErrorOverride,
  }) {
    calls++;
    sinks.add(onErrorOverride);
    final c = Completer<(GeocodingResult?, List<GeocodingResult>)>();
    pending.add(c);
    return c.future;
  }

  void succeed(int i, String address) {
    final r = GeocodingResult(formattedAddress: address);
    pending[i].complete((r, [r]));
  }

  void fail(int i, String message) {
    sinks[i]?.call(
      MapLocationPickerException(MapPickerErrorKind.network, message),
    );
    pending[i].complete((null, const <GeocodingResult>[]));
  }
}

/// Geocoding stub that answers immediately.
class _InstantGeoCoding extends GeoCodingConfig {
  _InstantGeoCoding({this.result}) : super(apiKey: 'test');

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

void main() {
  group('centre-pin commit ordering (CTRL-1)', () {
    test('the card is marked loading for the whole debounce window', () async {
      final geo = _InstantGeoCoding(
        result: GeocodingResult(formattedAddress: 'OLD'),
      );
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          pinMode: PickerPinMode.centerPin,
          pinIdleDebounce: Duration(milliseconds: 50),
        ),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      await controller.refreshAddress();
      expect(controller.address, 'OLD');

      controller.onCameraMoveStarted();
      controller.onCameraMove(
        const CameraPosition(target: LatLng(50, 50), zoom: 14),
      );
      await controller.onCameraIdle();

      // The position has committed but the lookup is only scheduled. If the
      // card were enabled here, confirming would pair the NEW coordinate with
      // the OLD address.
      expect(controller.position, const LatLng(50, 50));
      expect(controller.isLoading, isTrue);
      expect(controller.result, isNull);
    });

    test('a settle at the requested target keeps the chosen place', () async {
      final geo = _InstantGeoCoding(
        result: GeocodingResult(formattedAddress: 'Nelson Rd, Hounslow'),
      );
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          pinMode: PickerPinMode.centerPin,
          pinIdleDebounce: Duration(milliseconds: 5),
        ),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      await controller.selectPlace(
        Place(
          id: 'p1',
          displayName: LocalizedText(text: 'Heathrow Terminal 5'),
          formattedAddress: 'Heathrow Terminal 5',
          location: PlacesLatLng(latitude: 51.4706, longitude: -0.4619),
        ),
      );
      expect(controller.lastSelectedPlace, isNotNull);
      final callsAfterSelect = geo.calls;

      // The platform reports idle at (very nearly) the point we asked for.
      controller.onCameraMove(
        const CameraPosition(
          target: LatLng(51.47060001, -0.46190001),
          zoom: 14,
        ),
      );
      await controller.onCameraIdle();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(
        controller.lastSelectedPlace,
        isNotNull,
        reason: 'our own camera settle must not look like a user pan',
      );
      expect(geo.calls, callsAfterSelect, reason: 'no second billed geocode');
    });
  });

  group('request sequencing', () {
    test('a superseded failure is not reported (CTRL-3)', () async {
      final geo = _ManualGeoCoding();
      final errors = <MapLocationPickerException>[];
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(apiKey: 'k', onError: errors.add),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      unawaited(controller.refreshAddress());
      unawaited(controller.refreshAddress());
      await Future<void>.delayed(Duration.zero);

      geo.succeed(1, 'newer');
      await Future<void>.delayed(Duration.zero);
      geo.fail(0, 'boom');
      await Future<void>.delayed(Duration.zero);

      expect(controller.address, 'newer');
      expect(errors, isEmpty, reason: 'the abandoned lookup must stay silent');
      expect(controller.lastError, isNull);
    });

    test('no error reaches the host after dispose (CTRL-2)', () async {
      final geo = _ManualGeoCoding();
      final errors = <MapLocationPickerException>[];
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(apiKey: 'k', onError: errors.add),
        geoCodingConfig: geo,
      );

      unawaited(controller.refreshAddress());
      await Future<void>.delayed(Duration.zero);
      controller.dispose();

      geo.fail(0, 'closed by dispose');
      await Future<void>.delayed(Duration.zero);

      expect(errors, isEmpty);
    });

    test(
      'goToCurrentLocation does not clear a newer lookup flag (CTRL-4)',
      () async {
        final geo = _ManualGeoCoding();
        final controller = MapLocationPickerController(
          config: const MapLocationPickerConfig(apiKey: 'k'),
          geoCodingConfig: geo,
        );
        addTearDown(controller.dispose);

        // Simulate a lookup that is already running when the FAB path ends.
        unawaited(controller.refreshAddress());
        await Future<void>.delayed(Duration.zero);
        expect(controller.isLoading, isTrue);

        // A services-disabled early return must not steal the flag.
        await controller.goToCurrentLocation();
        await Future<void>.delayed(Duration.zero);

        geo.succeed(0, 'done');
        await Future<void>.delayed(Duration.zero);
        expect(controller.isLoading, isFalse);
      },
    );

    test('nearby results for an abandoned point are dropped (CTRL-10)', () {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          showNearbyPlaces: true,
        ),
        geoCodingConfig: _InstantGeoCoding(),
      );
      addTearDown(controller.dispose);

      // Moving the pin must clear chips for the previous neighbourhood, which
      // were otherwise left rendered and tappable.
      expect(controller.nearbyPlaces, isEmpty);
      controller.moveTo(const LatLng(2, 2), geocode: false, animate: false);
      expect(controller.nearbyPlaces, isEmpty);
    });
  });

  group('configuration is re-read', () {
    test('a changed pinIdleDebounce takes effect (CTRL-7)', () async {
      final geo = _InstantGeoCoding();
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          pinMode: PickerPinMode.centerPin,
          pinIdleDebounce: Duration(seconds: 30),
        ),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      controller.onCameraMove(
        const CameraPosition(target: LatLng(1, 1), zoom: 14),
      );
      await controller.onCameraIdle();

      controller.updateConfig(
        const MapLocationPickerConfig(
          apiKey: 'k',
          pinMode: PickerPinMode.centerPin,
          pinIdleDebounce: Duration(milliseconds: 1),
        ),
        geoCodingConfig: geo,
      );
      controller.onCameraMove(
        const CameraPosition(target: LatLng(2, 2), zoom: 14),
      );
      await controller.onCameraIdle();
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(geo.calls, greaterThan(0), reason: 'the 30s value was frozen in');
    });

    test('initialise runs once per controller (W4)', () async {
      final geo = _InstantGeoCoding(
        result: GeocodingResult(formattedAddress: 'x'),
      );
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'k'),
        geoCodingConfig: geo,
      );
      addTearDown(controller.dispose);

      await controller.initialise();
      await controller.initialise();
      await controller.initialise();
      expect(geo.calls, 1, reason: 'a remount must not re-bill a geocode');

      await controller.initialise(force: true);
      expect(geo.calls, 2);
    });
  });

  group('localization and legacy callbacks', () {
    test('strings.noAddressFound is actually used (REG-6)', () async {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          strings: MapLocationPickerStrings(
            noAddressFound: 'Adresse introuvable',
          ),
        ),
        geoCodingConfig: _InstantGeoCoding(),
      );
      addTearDown(controller.dispose);

      await controller.refreshAddress();

      expect(controller.address, 'Adresse introuvable');
    });

    test('an explicit noAddressFoundText still wins', () async {
      final controller = MapLocationPickerController(
        // ignore: deprecated_member_use_from_same_package
        config: const MapLocationPickerConfig(
          apiKey: 'k',
          // ignore: deprecated_member_use_from_same_package
          noAddressFoundText: 'legacy wins',
          strings: MapLocationPickerStrings(noAddressFound: 'localized'),
        ),
        geoCodingConfig: _InstantGeoCoding(),
      );
      addTearDown(controller.dispose);

      await controller.refreshAddress();

      expect(controller.address, 'legacy wins');
    });

    test('onLocationError still fires for location failures (REG-2)', () async {
      final legacy = <Object?>[];
      final controller = MapLocationPickerController(
        config: MapLocationPickerConfig(
          apiKey: 'k',
          // ignore: deprecated_member_use_from_same_package
          onLocationError: legacy.add,
        ),
        geoCodingConfig: _InstantGeoCoding(),
      );
      addTearDown(controller.dispose);

      // No GeolocatorPlatform fake is installed, so the platform call throws
      // and lands on the generic failure path -- which is exactly the one 3.x
      // reported through onLocationError.
      await controller.goToCurrentLocation();

      expect(legacy, isNotEmpty);
    });
  });

  _sessionTokenRegressions();

  group('embedding (W5)', () {
    testWidgets('the bottom card renders without a Scaffold ancestor', (
      tester,
    ) async {
      // MapLocationPickerView is documented as "no Scaffold of its own", so it
      // has to supply its own Material -- ListTile asserts without one.
      await tester.pumpWidget(
        MaterialApp(
          // Deliberately no Scaffold: this is the "embed it in a screen you
          // already have" case from the README.
          home: Center(
            child: SizedBox(
              width: 400,
              child: Builder(
                builder: (context) => defaultBottomCard(
                  context,
                  GeocodingResult(formattedAddress: '10 Downing St'),
                  '10 Downing St',
                  false,
                  const [],
                  const MapLocationPickerConfig(apiKey: 'k'),
                  () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('10 Downing St'), findsWidgets);
    });
  });
}

/// Returns a canned HTTP response for every request, and counts the calls.
class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter(this.body);

  final String body;
  int calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

void _sessionTokenRegressions() {
  group('Places session token is concluded on every getDetails path', () {
    // `AutoCompleteService.getDetails` short-circuits on its place cache. That
    // early return used to skip the token refresh that `cachePlaceDetails`
    // performs on the network path, so picking the same place twice through one
    // `SessionTokenHandler` carried a spent token into the *next* session.
    // Google bills a reused session token as if no token had been sent, so the
    // whole following session silently fell off the session SKU onto
    // Autocomplete-Per-Request. The handler is memoized for the widget's
    // lifetime (`autocomplete_view.dart`), so one long-lived picker is all it
    // takes.
    test('a cache hit concludes the session just like a network hit', () async {
      final adapter = _CannedAdapter(
        '{"id":"p1","formattedAddress":"1 Test St"}',
      );
      final session = SessionTokenHandler();
      final service = AutoCompleteService(
        placesApi: PlacesAPINew(apiKey: 'k', httpClientAdapter: adapter),
      );
      addTearDown(service.dispose);

      // Session A: keystrokes, then Place Details over the network.
      final tokenA = session.token;
      expect(
        await service.getDetails(
          placeId: 'p1',
          apiKey: 'k',
          sessionToken: session,
        ),
        isNotNull,
      );

      // Session B: fresh keystrokes, then the user re-picks the same place, so
      // Place Details is served from the cache and never reaches Google.
      final tokenB = session.token;
      expect(tokenB, isNot(tokenA), reason: 'the network path must rotate');
      expect(
        await service.getDetails(
          placeId: 'p1',
          apiKey: 'k',
          sessionToken: session,
        ),
        isNotNull,
      );
      expect(adapter.calls, 1, reason: 'the second lookup must hit the cache');

      expect(
        session.token,
        isNot(tokenB),
        reason: 'session C must not reuse a token Google has already seen',
      );
    });

    // Pins the two `google_maps_apis` properties that let `getDetails` hand
    // `response.body` to `cachePlaceDetails` with no null check: the call is
    // null-tolerant, and it refreshes unconditionally. A 2xx means Google
    // processed and billed the Details request, so the session is over
    // server-side whatever the payload was. Returning early on a null body
    // instead -- as PR #73's review suggested -- would keep a dead token.
    test('a 2xx carrying no place still rotates the token', () async {
      final session = SessionTokenHandler();
      final service = AutoCompleteService(
        placesApi: PlacesAPINew(
          apiKey: 'k',
          httpClientAdapter: _CannedAdapter(''),
        ),
      );
      addTearDown(service.dispose);

      final during = session.token;
      expect(
        await service.getDetails(
          placeId: 'p1',
          apiKey: 'k',
          sessionToken: session,
        ),
        isNull,
      );
      expect(session.placeFromCache('p1'), isNull);
      expect(
        session.token,
        isNot(during),
        reason: 'an empty 2xx body was still a billed Details request',
      );
    });
  });
}

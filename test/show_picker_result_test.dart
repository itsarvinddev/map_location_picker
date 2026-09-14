import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';

/// A geocoder that always answers, so the controller holds a real result.
class _Geo extends GeoCodingConfig {
  _Geo() : super(apiKey: 'test');

  int calls = 0;

  @override
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position, {
    MapPickerErrorCallback? onErrorOverride,
  }) async {
    calls++;
    final r = GeocodingResult(formattedAddress: '1 Test St');
    return (r, [r]);
  }
}

/// Opens the picker, lets the address resolve, then either confirms or backs
/// out, and returns what `showMapLocationPicker` resolved with.
Future<Object?> _run(
  WidgetTester tester, {
  required MapLocationPickerController controller,
  void Function(BuildContext context, GeocodingResult? result)? onNext,
  bool confirm = true,
}) async {
  Object? returned = 'never resolved';
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              returned = await showMapLocationPicker(
                context,
                controller: controller,
                config: MapLocationPickerConfig(
                  apiKey: 'test',
                  onNext: onNext == null ? null : (r) => onNext(context, r),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await controller.refreshAddress();
  await tester.pumpAndSettle();

  if (confirm) {
    controller.confirm();
  } else {
    // The system back gesture; the picker has no AppBar back button to tap.
    await tester.binding.handlePopRoute();
  }
  await tester.pumpAndSettle();
  return returned;
}

void main() {
  group(
    'a geocoder given to the controller survives the widget (regression)',
    () {
      testWidgets('MapLocationPicker(controller: c) keeps c\'s geocoder', (
        tester,
      ) async {
        // updateConfig used to assign the widget's null geoCodingConfig over
        // the controller's own, silently swapping a proxy, custom client or
        // test fake for the default geocoder.
        final geo = _Geo();
        final controller = MapLocationPickerController(
          config: const MapLocationPickerConfig(apiKey: 'test'),
          geoCodingConfig: geo,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MapLocationPicker(
              controller: controller,
              config: const MapLocationPickerConfig(apiKey: 'test'),
            ),
          ),
        );
        await tester.pump();
        await controller.refreshAddress();

        expect(geo.calls, greaterThan(0));
        expect(controller.address, '1 Test St');
      });

      testWidgets('a geocoder passed to the widget still takes precedence', (
        tester,
      ) async {
        final own = _Geo();
        final fromWidget = _Geo();
        final controller = MapLocationPickerController(
          config: const MapLocationPickerConfig(apiKey: 'test'),
          geoCodingConfig: own,
        );
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          MaterialApp(
            home: MapLocationPicker(
              controller: controller,
              geoCodingConfig: fromWidget,
              config: const MapLocationPickerConfig(apiKey: 'test'),
            ),
          ),
        );
        await tester.pump();
        final before = own.calls;
        await controller.refreshAddress();

        expect(fromWidget.calls, greaterThan(0));
        expect(own.calls, before, reason: 'the widget\'s geocoder must win');
      });
    },
  );

  group('showMapLocationPicker result with a 3.x onNext (regression)', () {
    testWidgets('popping a GeocodingResult returns a PickedPlace', (
      tester,
    ) async {
      // The route used to be MaterialPageRoute<PickedPlace>, so this threw
      // "pop a route with a result of type GeocodingResult, but the route
      // expected a value of type PickedPlace" -- on exactly the migration path
      // MIGRATION_GUIDE.md recommends.
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'test'),
        geoCodingConfig: _Geo(),
      );
      addTearDown(controller.dispose);

      final returned = await _run(
        tester,
        controller: controller,
        onNext: (context, r) => Navigator.pop(context, r),
      );

      expect(tester.takeException(), isNull);
      expect(returned, isA<PickedPlace>());
      expect((returned! as PickedPlace).formattedAddress, '1 Test St');
    });

    testWidgets('popping null after confirming still returns the pick', (
      tester,
    ) async {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'test'),
        geoCodingConfig: _Geo(),
      );
      addTearDown(controller.dispose);

      final returned = await _run(
        tester,
        controller: controller,
        onNext: (context, r) => Navigator.pop(context),
      );

      expect(returned, isA<PickedPlace>());
      expect((returned! as PickedPlace).formattedAddress, '1 Test St');
    });

    testWidgets('without a caller onNext it returns the pick', (tester) async {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'test'),
        geoCodingConfig: _Geo(),
      );
      addTearDown(controller.dispose);

      final returned = await _run(tester, controller: controller);

      expect(returned, isA<PickedPlace>());
      expect((returned! as PickedPlace).formattedAddress, '1 Test St');
    });

    testWidgets('backing out returns null', (tester) async {
      final controller = MapLocationPickerController(
        config: const MapLocationPickerConfig(apiKey: 'test'),
        geoCodingConfig: _Geo(),
      );
      addTearDown(controller.dispose);

      final returned = await _run(
        tester,
        controller: controller,
        confirm: false,
      );

      expect(returned, isNull);
    });
  });
}

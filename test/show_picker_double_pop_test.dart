import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';

/// Reverse geocoding that resolves immediately, so the picker never touches
/// the network.
class _InstantGeoCoding extends GeoCodingConfig {
  _InstantGeoCoding() : super(apiKey: 'test');

  @override
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position, {
    MapPickerErrorCallback? onErrorOverride,
  }) async => (
    GeocodingResult(formattedAddress: 'somewhere'),
    const <GeocodingResult>[],
  );
}

class _PopCounter extends NavigatorObserver {
  _PopCounter(this.popped);

  final List<String> popped;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popped.add('${route.runtimeType}');
  }
}

/// Opens the picker with [onNext] installed on the config, confirms through the
/// controller, and reports which routes were popped and what the future
/// returned.
///
/// The controller is driven directly because [GoogleMap] renders as a platform
/// view stub under the test harness -- there is no real confirm button to tap.
Future<(List<String>, Object?)> _openAndConfirm(
  WidgetTester tester, {
  void Function(BuildContext context, GeocodingResult? result)? onNext,
  int routesBelow = 0,
}) async {
  final controller = MapLocationPickerController(
    config: const MapLocationPickerConfig(apiKey: 'k'),
    geoCodingConfig: _InstantGeoCoding(),
  );
  addTearDown(controller.dispose);

  final popped = <String>[];
  Object? returned;

  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: [_PopCounter(popped)],
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () async {
                for (var i = 0; i < routesBelow; i++) {
                  unawaited(
                    Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => const Scaffold(body: Text('middle')),
                      ),
                    ),
                  );
                }
                returned = await showMapLocationPicker(
                  context,
                  controller: controller,
                  config: MapLocationPickerConfig(
                    apiKey: 'k',
                    onNext: onNext == null ? null : (r) => onNext(context, r),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.byType(MapLocationPicker), findsOneWidget);
  popped.clear();

  controller.confirm();
  await tester.pumpAndSettle();
  return (popped, returned);
}

void main() {
  group('showMapLocationPicker does not double-pop', () {
    testWidgets('a 3.x onNext that pops closes only the picker', (
      tester,
    ) async {
      // MIGRATION_GUIDE tells 3.x users to move to showMapLocationPicker while
      // keeping their config -- and a 3.x config almost always carries
      // `onNext: (r) => Navigator.pop(context)`. The route stays mounted for
      // the whole exit transition, so `mounted` alone does not catch this and
      // the caller's own screen used to get popped too.
      final (popped, _) = await _openAndConfirm(
        tester,
        onNext: (context, result) => Navigator.pop(context),
      );

      expect(popped, hasLength(1));
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('a 3.x onNext that pops with a result closes only the picker', (
      tester,
    ) async {
      final (popped, _) = await _openAndConfirm(
        tester,
        onNext: (context, result) => Navigator.pop(context, result),
      );

      expect(popped, hasLength(1));
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('the guard holds with routes below the picker', (tester) async {
      // Navigator.canPop would still be true here, so the guard has to be
      // "is this route still the current one", not "is anything left to pop".
      final (popped, _) = await _openAndConfirm(
        tester,
        onNext: (context, result) => Navigator.pop(context),
        routesBelow: 1,
      );

      expect(popped, hasLength(1));
      expect(find.text('middle'), findsOneWidget);
    });

    testWidgets('without a caller onNext the picker still pops with a result', (
      tester,
    ) async {
      final (popped, returned) = await _openAndConfirm(tester);

      expect(popped, hasLength(1));
      expect(returned, isA<PickedPlace>());
      expect(find.text('open'), findsOneWidget);
    });

    testWidgets('a non-popping onNext fires once and the picker still pops', (
      tester,
    ) async {
      var calls = 0;
      final (popped, returned) = await _openAndConfirm(
        tester,
        onNext: (context, result) => calls++,
      );

      expect(calls, 1);
      expect(popped, hasLength(1));
      expect(returned, isA<PickedPlace>());
    });
  });
}

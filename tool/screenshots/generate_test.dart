// Generates every screenshot used by the README and the pub.dev gallery.
//
//   flutter test tool/screenshots/generate_test.dart
//   python3 tool/screenshots/frame.py
//
// The first command renders each scene with the real package widgets into
// doc/readme/raw/. The second adds device frames and builds the composites.
//
// Everything the package would fetch over the network is answered by
// [_FakePlaces] and [_FakeGeocoding] with canned data, so the autocomplete,
// place-details and nearby-search code paths all run for real.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:map_location_picker/map_location_picker.dart';

import 'harness.dart';
import 'map_art.dart';

const _out = 'doc/readme/raw';

/// 393 x 852 logical px at 3x -- a current mid-size phone.
const _physical = Size(1179, 2556);
const _dpr = 3.0;

/// Status bar and home indicator insets, in physical px.
const _insets = FakeViewPadding(top: 54 * _dpr, bottom: 34 * _dpr);

const _seed = Color(0xFF2962FF);
const _ferry = LatLng(37.7955, -122.3937);

// --- canned network --------------------------------------------------------

/// Answers the Places API (New) with fixed JSON.
class _FakePlaces implements dio.HttpClientAdapter {
  _FakePlaces({this.french = false});

  final bool french;

  @override
  Future<dio.ResponseBody> fetch(
    dio.RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final path = options.uri.path;
    Object body;
    if (path.contains(':autocomplete')) {
      body = {'suggestions': _suggestions()};
    } else if (path.contains(':searchNearby')) {
      body = {'places': _nearby()};
    } else {
      body = {
        'id': 'roast',
        'displayName': {'text': 'Roast & Co.'},
        'formattedAddress': '48 Harbor Way, San Francisco, CA 94111, USA',
        'location': {
          'latitude': _ferry.latitude,
          'longitude': _ferry.longitude,
        },
      };
    }
    return dio.ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        dio.Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  List<Map<String, Object>> _suggestions() {
    Map<String, Object> s(String id, String main, String secondary) => {
      'placePrediction': {
        'placeId': id,
        'text': {'text': '$main, $secondary'},
        'structuredFormat': {
          'mainText': {'text': main},
          'secondaryText': {'text': secondary},
        },
      },
    };
    return [
      s('roast', 'Roast & Co.', 'Harbor Way'),
      s('lab', 'Coffee Lab', 'Pine Street'),
      s('grind', 'The Daily Grind', 'Market Avenue'),
      s('bar', 'Harbor Coffee Bar', '3rd Street'),
      s('bean', 'Bean There Café', 'Old Town'),
    ];
  }

  List<Map<String, Object>> _nearby() {
    Map<String, Object> p(String id, String name) => {
      'id': id,
      'displayName': {'text': name},
      'formattedAddress': '$name, San Francisco, CA',
      'location': {'latitude': _ferry.latitude, 'longitude': _ferry.longitude},
    };
    return [
      p('market', 'Harbor Market'),
      p('station', 'Central Station'),
      p('roast', 'Roast & Co.'),
      p('museum', 'City Museum'),
      p('park', 'Riverside Park'),
    ];
  }

  @override
  void close({bool force = false}) {}
}

/// Answers reverse geocoding with a fixed address.
class _FakeGeocoding extends GeoCodingConfig {
  _FakeGeocoding(this.primary) : super(apiKey: 'screenshot');

  final (String title, String address) primary;

  GeocodingResult _result((String, String) r) => GeocodingResult(
    placeId: r.$1,
    formattedAddress: r.$2,
    addressComponents: [
      AddressComponent(
        longName: r.$1,
        shortName: r.$1,
        types: const ['premise'],
      ),
    ],
  );

  @override
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position, {
    MapPickerErrorCallback? onErrorOverride,
  }) async {
    final r = _result(primary);
    return (r, [r]);
  }
}

// --- scene plumbing --------------------------------------------------------

class _Scene {
  const _Scene(
    this.id, {
    required this.build,
    this.dark = false,
    this.french = false,
    this.interact,
    this.showPois = true,
    this.viewScale = 1,
    this.viewOffset = Offset.zero,
    this.labelTop = 118,
    this.labelBottomFraction = 0.78,
  });

  final String id;
  final bool dark;
  final bool french;
  final bool showPois;
  final double viewScale;
  final Offset viewOffset;
  final double labelTop;
  final double labelBottomFraction;
  final Widget Function() build;
  final Future<void> Function(WidgetTester tester)? interact;
}

ThemeData _theme(Brightness b) => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: b,
    // Keeps the seed's chroma; the default tonal mapping renders this blue as
    // a washed-out slate.
    dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
  ),
  useMaterial3: true,
);

PlacesAPINew _places({bool french = false}) => PlacesAPINew(
  apiKey: 'screenshot',
  httpClientAdapter: _FakePlaces(french: french),
);

Future<void> _settle(WidgetTester tester, [int frames = 12]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _render(WidgetTester tester, _Scene scene) async {
  GoogleMapsFlutterPlatform.instance = FakeMapsPlatform(
    painterFor: (camera, markers, config) => IllustratedMapPainter(
      palette: scene.dark ? MapPalette.dark : MapPalette.light,
      labels: scene.french ? MapLabels.fr : MapLabels.en,
      camera: camera,
      markers: markers,
      padding: config.padding ?? EdgeInsets.zero,
      showPois: scene.showPois,
      viewScale: scene.viewScale,
      viewOffset: scene.viewOffset,
      labelTop: scene.labelTop,
      labelBottomFraction: scene.labelBottomFraction,
    ),
  );

  tester.view.physicalSize = _physical;
  tester.view.devicePixelRatio = _dpr;
  tester.view.padding = _insets;
  tester.view.viewPadding = _insets;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: scene.dark ? ThemeMode.dark : ThemeMode.light,
        home: scene.build(),
      ),
    ),
  );
  await _settle(tester);
  await scene.interact?.call(tester);
  await _settle(tester, 8);
  await capture(tester, key, '$_out/${scene.id}.png');
}

// --- scenes ----------------------------------------------------------------

MapLocationPickerConfig _base({
  bool dark = false,
  PickerPinMode pinMode = PickerPinMode.marker,
  String title = '',
  bool nearby = false,
  MapLocationPickerStrings strings = const MapLocationPickerStrings(),
}) => MapLocationPickerConfig(
  apiKey: 'screenshot',
  initialPosition: _ferry,
  initialZoom: 15.5,
  showBackButton: true,
  pinMode: pinMode,
  bottomCardTitle: title,
  showNearbyPlaces: nearby,
  placesApi: _places(),
  strings: strings,
);

final _scenes = <_Scene>[
  _Scene(
    'pick',
    build: () => MapLocationPicker(
      config: _base(),
      searchConfig: SearchConfig(placesApi: _places()),
      geoCodingConfig: _FakeGeocoding((
        'Ferry Building',
        '1 Ferry Building, San Francisco, CA 94111, USA',
      )),
    ),
  ),
  _Scene(
    'search',
    build: () => MapLocationPicker(
      config: _base(),
      searchConfig: SearchConfig(placesApi: _places()),
      geoCodingConfig: _FakeGeocoding((
        'Ferry Building',
        '1 Ferry Building, San Francisco, CA 94111, USA',
      )),
    ),
    interact: (tester) async {
      await tester.enterText(find.byType(EditableText).first, 'coffee');
      await _settle(tester, 12);
    },
  ),
  _Scene(
    'center_pin',
    viewScale: 1.22,
    viewOffset: Offset(-40, 30),
    build: () => MapLocationPicker(
      config: _base(
        pinMode: PickerPinMode.centerPin,
        title: 'Where should we deliver?',
      ),
      searchConfig: SearchConfig(placesApi: _places()),
      geoCodingConfig: _FakeGeocoding((
        '75 Harbor Way',
        '75 Harbor Way, San Francisco, CA 94111, USA',
      )),
    ),
  ),
  _Scene(
    'dark',
    dark: true,
    viewScale: 1.12,
    viewOffset: Offset(22, -40),
    build: () => MapLocationPicker(
      config: _base(dark: true),
      searchConfig: SearchConfig(placesApi: _places()),
      geoCodingConfig: _FakeGeocoding((
        'Harbor Market',
        '88 Harbor Way, San Francisco, CA 94111, USA',
      )),
    ),
  ),
  _Scene(
    'nearby',
    viewScale: 1.15,
    viewOffset: Offset(28, 24),
    // The chips row sits above the bottom card.
    labelBottomFraction: 0.70,
    build: () => MapLocationPicker(
      config: _base(nearby: true),
      searchConfig: SearchConfig(placesApi: _places()),
      geoCodingConfig: _FakeGeocoding((
        'Ferry Building',
        '1 Ferry Building, San Francisco, CA 94111, USA',
      )),
    ),
    interact: (tester) async => _settle(tester, 10),
  ),
  _Scene(
    'localized',
    french: true,
    viewScale: 1.08,
    viewOffset: Offset(-14, -20),
    build: () => MapLocationPicker(
      config: _base(
        title: 'Où livrer ?',
        strings: const MapLocationPickerStrings(
          confirmAddress: "Confirmer l'adresse",
          loadingAddress: "Chargement de l'adresse...",
          loadingAddressSubtitle: 'Récupération des détails.',
          noAddressFound: 'Aucune adresse trouvée',
          mapTypeTooltip: 'Type de carte',
          mapTypeTitle: 'Type de carte',
          mapTypeMessage: 'Choisissez le type de carte.',
          mapTypeNormal: 'Plan',
          mapTypeSatellite: 'Satellite',
          mapTypeTerrain: 'Relief',
          mapTypeHybrid: 'Hybride',
          cancel: 'Annuler',
          tapToSelect: 'touchez pour choisir',
          searchHint: 'Rechercher une adresse',
        ),
      ),
      searchConfig: SearchConfig(placesApi: _places(french: true)),
      geoCodingConfig: _FakeGeocoding((
        'Rue de la Paix',
        '8 Rue de la Paix, 75002 Paris, France',
      )),
    ),
  ),
  _Scene(
    'map_type',
    build: () => MapLocationPicker(
      config: _base(),
      searchConfig: SearchConfig(placesApi: _places()),
      geoCodingConfig: _FakeGeocoding((
        'Ferry Building',
        '1 Ferry Building, San Francisco, CA 94111, USA',
      )),
    ),
    interact: (tester) async {
      await tester.tap(find.byIcon(Icons.layers));
      await _settle(tester, 8);
    },
  ),
  _Scene(
    'embedded',
    showPois: false,
    viewScale: 1.3,
    labelTop: 58,
    labelBottomFraction: 0.55,
    build: () => const _Checkout(),
  ),
];

/// An ordinary app screen with the picker embedded in it -- the case from
/// issue #65, where MapLocationPicker used to render squashed.
class _Checkout extends StatelessWidget {
  const _Checkout();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text('Delivery address', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Drag the map or search to adjust the drop-off point.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 400,
              child: MapLocationPickerView(
                config: MapLocationPickerConfig(
                  apiKey: 'screenshot',
                  initialPosition: _ferry,
                  initialZoom: 15.5,
                  showMapTypeButton: false,
                  hideMoreOptions: true,
                  mapBottomInset: 150,
                  placesApi: _places(),
                  strings: const MapLocationPickerStrings(
                    confirmAddress: 'Use this address',
                  ),
                ),
                searchConfig: SearchConfig(placesApi: _places()),
                geoCodingConfig: _FakeGeocoding((
                  'Ferry Building',
                  '1 Ferry Building, San Francisco, CA',
                )),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Apartment, suite or floor',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Delivery instructions',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: const Text('Place order'),
          ),
        ],
      ),
    );
  }
}

void main() {
  setUpAll(loadFonts);

  final only = Platform.environment['SCENE'];
  for (final scene in _scenes) {
    if (only != null && only != scene.id) continue;
    testWidgets(scene.id, (tester) => _render(tester, scene));
  }

  tearDownAll(() {
    File('$_out/manifest.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          for (final s in _scenes) s.id: {'dark': s.dark},
        }),
      );
  });
}

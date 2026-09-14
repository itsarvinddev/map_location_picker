// Every Dart code sample from README.md, compiled.
//
// The 3.x README's examples all referenced types that had been renamed two
// releases earlier, so copy-pasting from it could not work. Keeping the samples
// here means `flutter analyze` fails if the docs drift again.
//
// It is never executed.
// ignore_for_file: unused_element, unreachable_from_main

import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';

// --- The one-liner under the hero image -------------------------------------
Future<void> _hero(BuildContext context) async {
  final picked = await showMapLocationPicker(
    context,
    config: const MapLocationPickerConfig(apiKey: 'YOUR_API_KEY'),
  );

  debugPrint(picked?.formattedAddress);
}

// --- Getting started: 4. Pick a location ------------------------------------
Future<void> chooseLocation(BuildContext context) async {
  final picked = await showMapLocationPicker(
    context,
    config: MapLocationPickerConfig(
      apiKey: 'YOUR_API_KEY',
      onError: (e) => debugPrint('${e.kind}: ${e.message}'),
    ),
  );

  if (picked == null) return;

  debugPrint(picked.formattedAddress);
  debugPrint('${picked.latLng}');
  debugPrint(picked.city);
  debugPrint(picked.countryCode);
}

// --- Picking modes ----------------------------------------------------------
const _centerPin = MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  pinMode: PickerPinMode.centerPin,
  bottomCardTitle: 'Where should we deliver?',
  showBackButton: true,
);

MapLocationPickerConfig _customPin() => MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  pinMode: PickerPinMode.centerPin,
  centerPinBuilder: (context, state) =>
      Icon(Icons.place, color: state == PinState.dragging ? Colors.red : null),
);

// --- Starting at the user's location ---------------------------------------
const _startAtUser = MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  startWithCurrentLocation: true,
  locationTimeout: Duration(seconds: 8),
);

// --- Restricting search -----------------------------------------------------
const _restricted = MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  countries: ['gb', 'ie'],
  placeTypes: [PlaceType.streetAddress],
  language: 'en',
);

Widget _customFilter() => MapLocationPicker(
  config: const MapLocationPickerConfig(apiKey: 'YOUR_API_KEY'),
  searchConfig: SearchConfig(
    searchFilter: AutocompleteSearchFilter(includeQueryPredictions: true),
  ),
);

// --- Nearby places ----------------------------------------------------------
const _nearby = MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  showNearbyPlaces: true,
  nearbyPlacesRadius: 300,
  nearbyPlacesLimit: 6,
  nearbyPlaceTypes: [PlaceType.restaurant, PlaceType.cafe],
);

// --- Embedding in an existing screen ---------------------------------------
class _Embedded extends StatefulWidget {
  const _Embedded();

  @override
  State<_Embedded> createState() => _EmbeddedState();
}

class _EmbeddedState extends State<_Embedded> {
  LatLng? _position;
  String? _address;

  @override
  Widget build(BuildContext context) {
    debugPrint('$_position $_address');
    return SizedBox(
      height: 400,
      child: MapLocationPickerView(
        config: MapLocationPickerConfig(
          apiKey: 'YOUR_API_KEY',
          showMapTypeButton: false,
          onMainMarkerPositionChanged: (position) =>
              setState(() => _position = position),
          onAddressDecoded: (result) =>
              setState(() => _address = result?.formattedAddress),
        ),
      ),
    );
  }
}

MapLocationPickerConfig _inScrollView() => MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  gestureRecognizers: {
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  },
);

// --- Controlling it from code ----------------------------------------------
Future<void> _programmatic(MapLocationPickerConfig config) async {
  final controller = MapLocationPickerController(config: config);

  MapLocationPicker(config: config, controller: controller);

  await controller.moveTo(const LatLng(48.8584, 2.2945));
  await controller.goToCurrentLocation();
  controller.setMapType(MapType.hybrid);

  ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Text(controller.address),
  );

  // The other state mentioned in the prose.
  controller.position;
  controller.isLoading;
  controller.result;
  controller.results;
  controller.mapType;
  controller.pinState;
  controller.nearbyPlaces;
  controller.lastError;
  controller.confirm;

  controller.dispose();
}

// --- Reading the result -----------------------------------------------------
void _readResult(PickedPlace picked, GeocodingResult result) {
  final LatLng latLng = picked.latLng;
  final String label = picked.displayLabel;
  final List<String?> strings = [
    picked.formattedAddress,
    picked.name,
    picked.streetNumber,
    picked.street,
    picked.city,
    picked.locality,
    picked.administrativeArea,
    picked.postalCode,
    picked.country,
    picked.countryCode,
    picked.placeId,
  ];
  final GeocodingResult? raw = picked.result;
  final Place? place = picked.place;
  debugPrint('$latLng $label $strings $raw $place');

  result.city;
  result.postalCode;
  result.countryCode;
  result.latLng;
  result.component('administrative_area_level_2');
}

// --- Handling errors --------------------------------------------------------
MapLocationPickerConfig _errors(BuildContext context) {
  return MapLocationPickerConfig(
    apiKey: 'YOUR_API_KEY',
    onError: (e) {
      if (!e.isUserFacing) return;

      final message = switch (e.kind) {
        MapPickerErrorKind.requestDenied =>
          'Maps is misconfigured: check the API key and enabled APIs.',
        MapPickerErrorKind.network => 'You appear to be offline.',
        MapPickerErrorKind.locationPermissionDeniedForever =>
          'Allow location access in system settings.',
        _ => e.message,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    },
  );
}

// Every kind the prose lists, so a rename breaks the build.
const _allKinds = [
  MapPickerErrorKind.cancelled,
  MapPickerErrorKind.invalidRequest,
  MapPickerErrorKind.quotaExceeded,
  MapPickerErrorKind.noResults,
  MapPickerErrorKind.locationServiceDisabled,
  MapPickerErrorKind.locationPermissionDenied,
  MapPickerErrorKind.locationTimeout,
  MapPickerErrorKind.mapUnavailable,
  MapPickerErrorKind.unsupportedPlatform,
  MapPickerErrorKind.unknown,
];

// --- Localization -----------------------------------------------------------
MapLocationPickerConfig _french() => MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  language: 'fr',
  bottomCardTitle: 'Où livrer ?',
  strings: MapLocationPickerStrings(
    searchHint: 'Rechercher une adresse',
    confirmAddress: "Confirmer l'adresse",
    loadingAddress: 'Chargement…',
    noAddressFound: 'Aucune adresse trouvée',
    nearbyPlacesCount: (n) => n == 1 ? '1 adresse' : '$n adresses',
  ),
);

// --- Theming and dark mode --------------------------------------------------
const darkMapStyleJson = '[]';

MapLocationPickerConfig _themed(BuildContext context) =>
    MapLocationPickerConfig(
      apiKey: 'YOUR_API_KEY',
      mapStyle: Theme.of(context).brightness == Brightness.dark
          ? darkMapStyleJson
          : null,
      cardType: CardType.liquidCard,
      cardColor: Colors.white,
      cardRadius: BorderRadius.circular(16),
      floatingControlsColor: Colors.white,
      floatingControlsIconColor: Colors.black,
      cloudMapId: null,
    );

// --- Customising the UI -----------------------------------------------------
class MyAddressCard extends StatelessWidget {
  const MyAddressCard({
    super.key,
    required this.address,
    required this.loading,
    required this.onConfirm,
  });

  final String address;
  final bool loading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onConfirm, child: Text(address));
}

MapLocationPickerConfig _chrome(BitmapDescriptor myBitmapDescriptor) {
  return MapLocationPickerConfig(
    apiKey: 'YOUR_API_KEY',
    floatingControlsPosition: FloatingControlsPosition.bottomStart,
    mainMarkerIcon: myBitmapDescriptor,
    confirmButton: (context, onNext) =>
        FilledButton(onPressed: onNext, child: const Text('Deliver here')),
    bottomCardBuilder:
        (context, result, results, address, isLoading, onNext, searchBar) {
          return MyAddressCard(
            address: address,
            loading: isLoading,
            onConfirm: onNext,
          );
        },
    // Named in the prose.
    showSearchBar: true,
    searchBarBuilder: (context, searchBar) => searchBar,
    backButtonBuilder: (context) => const BackButton(),
    showMyLocationButton: true,
    additionalMarkers: const {'shop': LatLng(51.5, -0.12)},
    customMarkerIcons: {'shop': myBitmapDescriptor},
    onMarkerTapped: {'shop': () {}},
  );
}

// --- The search field on its own -------------------------------------------
Widget _standaloneSearch() {
  return PlacesAutocomplete(
    config: const SearchConfig(apiKey: 'YOUR_API_KEY'),
    onGetDetails: (place) => debugPrint(place?.formattedAddress),
    onError: (e) => debugPrint('${e.kind}: ${e.message}'),
  );
}

// --- Restricting the key ----------------------------------------------------
MapLocationPickerConfig _restrictedKey() {
  final headers = <String, String>{
    if (Platform.isIOS) 'X-Ios-Bundle-Identifier': 'com.example.app',
    if (Platform.isAndroid) ...{
      'X-Android-Package': 'com.example.app',
      'X-Android-Cert': '00112233445566778899AABBCCDDEEFF00112233',
    },
  };

  return MapLocationPickerConfig(
    apiKey: 'YOUR_API_KEY',
    geocodingApiHeaders: headers,
    placesApi: PlacesAPINew(apiKey: 'YOUR_API_KEY', headers: headers),
  );
}

// --- Keeping Places costs down ----------------------------------------------
const _cheapFields = SearchConfig(
  placesAllFields: false,
  placeFields: ['id', 'location', 'formattedAddress', 'displayName'],
);

// --- Configuration reference: options named in the table -------------------
const _reference = MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  initialPosition: LatLng(28.8993, 76.6250),
  initialZoom: 14,
  requireGeocodedAddress: false,
  hideBottomCardOnKeyboard: true,
  myLocationEnabled: false,
  zoomControlsEnabled: false,
  minMaxZoomPreference: MinMaxZoomPreference.unbounded,
  padding: EdgeInsets.zero,
);

void _touch() {
  _hero;
  chooseLocation;
  _centerPin;
  _customPin;
  _startAtUser;
  _restricted;
  _customFilter;
  _nearby;
  _Embedded.new;
  _inScrollView;
  _programmatic;
  _readResult;
  _errors;
  _allKinds;
  _french;
  _themed;
  _chrome;
  _standaloneSearch;
  _restrictedKey;
  _cheapFields;
  _reference;
}

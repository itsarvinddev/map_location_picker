// Every code sample from README.md, compiled.
//
// The 3.x README's examples all referenced types that had been renamed two
// releases earlier, so copy-pasting from it could not work. Keeping the samples
// here means `flutter analyze` fails if the docs drift again.
//
// It is never executed.
// ignore_for_file: unused_element, unreachable_from_main, avoid_print

import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';

const key = 'YOUR_API_KEY';

// --- Quick start ------------------------------------------------------------
Future<void> _quickStart(BuildContext context) async {
  final picked = await showMapLocationPicker(
    context,
    config: const MapLocationPickerConfig(apiKey: key),
  );

  if (picked != null) {
    print(picked.latLng);
    print(picked.formattedAddress);
    print(picked.city);
    print(picked.countryCode);
  }
}

// --- Restricting the API key ------------------------------------------------
MapLocationPickerConfig _restrictedKey() {
  final headers = <String, String>{
    if (Platform.isIOS || Platform.isMacOS)
      'X-Ios-Bundle-Identifier': 'com.example.app',
    if (Platform.isAndroid) ...{
      'X-Android-Package': 'com.example.app',
      'X-Android-Cert': '00112233445566778899AABBCCDDEEFF00112233',
    },
  };

  return MapLocationPickerConfig(
    apiKey: key,
    geocodingApiHeaders: headers,
    placesApi: PlacesAPINew(apiKey: key, headers: headers),
  );
}

// --- Picking modes ----------------------------------------------------------
const _tapMode = MapLocationPickerConfig(apiKey: key);
const _centerPin = MapLocationPickerConfig(
  apiKey: key,
  pinMode: PickerPinMode.centerPin,
);

// --- Starting at the user's location ---------------------------------------
const _startAtUser = MapLocationPickerConfig(
  apiKey: key,
  startWithCurrentLocation: true,
  locationTimeout: Duration(seconds: 8),
);

// --- Restricting the search -------------------------------------------------
const _restricted = MapLocationPickerConfig(
  apiKey: key,
  countries: ['gb', 'ie'],
  placeTypes: [PlaceType.streetAddress],
  language: 'en',
);

final _customFilter = SearchConfig(
  searchFilter: AutocompleteSearchFilter(includeQueryPredictions: true),
);

// --- Embedding --------------------------------------------------------------
Widget _embedded() {
  return SizedBox(
    height: 420,
    child: MapLocationPickerView(
      config: MapLocationPickerConfig(
        apiKey: key,
        onNext: (result) => print(result?.formattedAddress),
      ),
    ),
  );
}

// --- Driving it programmatically -------------------------------------------
Future<void> _programmatic() async {
  final controller = MapLocationPickerController(
    config: const MapLocationPickerConfig(apiKey: key),
  );

  MapLocationPicker(config: _tapMode, controller: controller);

  await controller.moveTo(const LatLng(48.8584, 2.2945));
  await controller.goToCurrentLocation();
  controller.setMapType(MapType.hybrid);
  print(controller.address);

  ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Text(controller.address),
  );

  controller.dispose();
}

// --- Handling failures ------------------------------------------------------
MapLocationPickerConfig _errors() {
  return MapLocationPickerConfig(
    apiKey: key,
    onError: (e) {
      switch (e.kind) {
        case MapPickerErrorKind.requestDenied:
        case MapPickerErrorKind.quotaExceeded:
        case MapPickerErrorKind.network:
        case MapPickerErrorKind.locationPermissionDeniedForever:
          break;
        default:
          break;
      }
    },
  );
}

// --- Translating the UI -----------------------------------------------------
const _translated = MapLocationPickerConfig(
  apiKey: key,
  strings: MapLocationPickerStrings(
    confirmAddress: 'Confirmer',
    searchHint: 'Rechercher...',
    noAddressFound: 'Aucune adresse',
  ),
);

// --- Reading the result -----------------------------------------------------
void _readResult(PickedPlace picked, GeocodingResult result) {
  picked.latLng;
  picked.name;
  picked.formattedAddress;
  picked.street;
  picked.locality;
  picked.postalCode;
  picked.countryCode;
  picked.result;
  picked.place;

  result.city;
  result.postalCode;
  result.countryCode;
  result.component('administrative_area_level_2');
  result.latLng;
}

// --- Nearby places ----------------------------------------------------------
const _nearby = MapLocationPickerConfig(
  apiKey: key,
  showNearbyPlaces: true,
  nearbyPlacesRadius: 300,
  nearbyPlaceTypes: [PlaceType.restaurant, PlaceType.cafe],
);

// --- The search field on its own -------------------------------------------
Widget _standaloneSearch() {
  return PlacesAutocomplete(
    config: const SearchConfig(apiKey: key),
    onGetDetails: (place) => print(place?.formattedAddress),
    onError: (e) => print(e),
  );
}

// --- Customising the chrome -------------------------------------------------
MapLocationPickerConfig _chrome(BitmapDescriptor icon) {
  return MapLocationPickerConfig(
    apiKey: key,
    cardType: CardType.liquidCard,
    floatingControlsPosition: FloatingControlsPosition.bottomStart,
    showBackButton: true,
    bottomCardTitle: 'Where should we deliver?',
    mainMarkerIcon: icon,
    centerPinBuilder: (context, state) => Icon(
      Icons.place,
      color: state == PinState.dragging ? Colors.red : null,
    ),
    bottomCardBuilder:
        (context, result, results, address, isLoading, onNext, searchBar) {
          return ElevatedButton(onPressed: onNext, child: Text(address));
        },
  );
}

// --- Costs ------------------------------------------------------------------
const _cheapFields = SearchConfig(
  apiKey: key,
  placesAllFields: false,
  placeFields: ['id', 'location', 'formattedAddress', 'displayName'],
);

void _touch() {
  _quickStart;
  _restrictedKey;
  _tapMode;
  _centerPin;
  _startAtUser;
  _restricted;
  _customFilter;
  _embedded;
  _programmatic;
  _errors;
  _translated;
  _readResult;
  _nearby;
  _standaloneSearch;
  _chrome;
  _cheapFields;
}

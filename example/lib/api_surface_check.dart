// Compile-time guard for the public API surface.
//
// This file imports ONLY the package barrel and then names every type that
// appears in a public signature. If a `show` clause in
// `lib/map_location_picker.dart` ever stops exporting something a consumer
// needs, `flutter analyze` fails here rather than in a user's bug report.
//
// It is never executed.
// ignore_for_file: unused_element, unreachable_from_main

import 'package:map_location_picker/map_location_picker.dart';

void _surface() {
  // Widgets and entry points.
  const MapLocationPicker(config: MapLocationPickerConfig());
  const MapLocationPickerView(config: MapLocationPickerConfig());
  PlacesAutocomplete(config: const SearchConfig());
  MapLocationPickerController(config: const MapLocationPickerConfig());
  showMapLocationPicker;

  // Configuration.
  const MapLocationPickerConfig();
  const SearchConfig();
  const MapLocationPickerStrings();
  GeoCodingConfig(apiKey: '');

  // Enums.
  PickerPinMode.centerPin;
  PinState.idle;
  FloatingControlsPosition.bottomEnd;
  CardType.liquidCard;
  PositionChangeReason.mapTap;
  MapPickerErrorKind.requestDenied;
  MapPickerLogLevel.off;

  // Errors.
  const MapLocationPickerException(MapPickerErrorKind.unknown, '');
  void onError(MapLocationPickerException _) {}
  final MapPickerErrorCallback cb = onError;
  cb;

  // Results.
  const PickedPlace(latLng: LatLng(0, 0));
  GeocodingResult();
  AddressComponent();
  Geometry(location: Location(lat: 0, lng: 0), locationType: '');
  // Named, not constructed: its `status` is a package-internal enum.
  GeocodingResponse;

  // Places API (New) types used by SearchConfig / MapLocationPickerConfig.
  PlacesAPINew(apiKey: '');
  Place();
  Suggestion();
  PlacePrediction();
  PlacesSuggestions();
  PlacesResponse();
  StructuredFormat();
  FormattableText();
  LocalizedText();
  SessionTokenHandler();
  PlaceType.restaurant;
  AutocompleteSearchFilter().copyWith(input: 'x');
  PlaceDetailsFilter().copyWith(sessionToken: 'x');

  // Transitive types that appear in our signatures.
  CancelToken();
  SuggestionsController<Suggestion>();
  Client;

  // Map + location types.
  const LatLng(0, 0);
  MapType.hybrid;
  const LocationSettings();
  LocationPermission.always;
  Geolocator.checkPermission;

  // Services and helpers.
  AutoCompleteService();
  googleStaticMapWithMarker(0, 0, 1);
  mapLogger.level = MapPickerLogLevel.warn;
  addressTitle(null);
  CustomMapCard.kRadius;
}

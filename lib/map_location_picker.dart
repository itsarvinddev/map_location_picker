/// A Google Maps location picker for Flutter.
///
/// The entry points are [MapLocationPicker] (full screen),
/// [MapLocationPickerView] (embeddable), [showMapLocationPicker] (imperative)
/// and [PlacesAutocomplete] (the search field on its own).
///
/// This barrel deliberately re-exports only the types that appear in this
/// package's own public signatures. It used to re-export all of `geolocator`,
/// `google_maps_flutter` and both the legacy *and* new `google_maps_apis`
/// libraries, which dumped several hundred symbols — and nine name collisions,
/// including two different `LatLng` and two different `AddressComponent` — into
/// every file that imported it.
library;

// --- google_maps_flutter: the map surface itself ---------------------------
export 'package:google_maps_flutter/google_maps_flutter.dart';

// --- geolocator: only what MapLocationPickerConfig.locationSettings needs ---
export 'package:geolocator/geolocator.dart'
    show
        AndroidSettings,
        AppleSettings,
        Geolocator,
        LocationAccuracy,
        LocationPermission,
        LocationSettings,
        Position,
        WebSettings,
        ActivityType,
        ForegroundNotificationConfig,
        AndroidResource,
        AndroidPosition,
        LocationAccuracyStatus,
        ServiceStatus,
        LocationServiceDisabledException,
        PermissionDeniedException,
        PermissionDefinitionsNotFoundException,
        PermissionRequestInProgressException,
        ActivityMissingException,
        AlreadySubscribedException,
        InvalidPermissionException,
        PositionUpdateException,
        GeolocatorPlatform;

// --- google_maps_apis (legacy geocoding): the reverse-geocoding result ------
//
// `google_maps_apis/places.dart` (the legacy Places API) is deliberately NOT
// exported: nothing in this package uses it, and it collides with the new
// Places types on Photo, PlusCode, Review, PriceLevel and BusinessStatus.
export 'package:google_maps_apis/geocoding.dart'
    show
        AddressComponent,
        Bounds,
        Component,
        Geometry,
        GeocodingResponse,
        GeocodingResult,
        GoogleMapsGeocoding,
        Location,
        ResponseStatus;

// --- google_maps_apis (Places API New) --------------------------------------
//
// Two omissions are deliberate:
//   * the Places (New) `AddressComponent` — the geocoding one above already
//     claims that name, and exporting both is an ambiguous export;
//   * the Places (New) `AddressComponent`, `Circle` and `LatLng` — all three
//     collide with a name this barrel already exports. They are available as
//     `PlacesAddressComponent`, `PlacesCircle` and `PlacesLatLng` from
//     `src/places_aliases.dart`, since Dart cannot rename on export.
//   * `NearbySearchFilter` — not part of this package's public signatures;
//     nearby search is configured with plain fields on
//     `MapLocationPickerConfig`.
export 'package:google_maps_apis/places_new.dart'
    show
        AutocompleteSearchFilter,
        FormattableText,
        GoogleHTTPResponse,
        LocalizedText,
        LocationBias,
        LocationRestriction,
        QueryPrediction,
        ReferencePoint,
        Place,
        PlaceDetailsFilter,
        PlacePrediction,
        PlaceType,
        PlacesAPINew,
        PlacesResponse,
        PlacesSuggestions,
        SessionTokenHandler,
        StructuredFormat,
        Suggestion,
        // The generated copyWith extensions. A `show` clause hides extensions
        // unless they are named, and without them `filter.copyWith(...)` does
        // not resolve for consumers.
        $AutocompleteSearchFilterCopyWithExtension,
        $PlaceCopyWithExtension,
        $PlaceDetailsFilterCopyWithExtension,
        $SuggestionCopyWithExtension;

// --- transitive types that appear in our config signatures -----------------
//
// Without these a consumer has to add dio, flutter_typeahead and http to their
// own pubspec just to name a parameter type this package asks for.
export 'package:dio/dio.dart' show CancelToken;
export 'package:flutter_typeahead/flutter_typeahead.dart'
    show SuggestionsController;
export 'package:http/http.dart' show Client;

// --- this package ----------------------------------------------------------
export 'src/autocomplete_service.dart';
export 'src/autocomplete_view.dart';
export 'src/card.dart';
export 'src/configs/enums.dart';
export 'src/configs/map_config.dart';
export 'src/configs/search_config.dart';
export 'src/configs/strings.dart';
export 'src/exceptions.dart';
export 'src/geocoding_service.dart';
export 'src/logger.dart';
export 'src/map_location_picker.dart';
export 'src/map_location_picker_controller.dart';
export 'src/picked_place.dart';
export 'src/places_aliases.dart';
export 'src/show_picker.dart';

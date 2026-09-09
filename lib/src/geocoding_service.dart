import 'package:http/http.dart' as http;
import 'package:map_location_picker/map_location_picker.dart';

/// Reverse-geocodes coordinates into addresses using the Google Geocoding API.
///
/// One instance owns one HTTP client. Call [dispose] when you are done with it;
/// [MapLocationPickerController] does this for you.
///
/// ```dart
/// final geocoding = GeoCodingConfig(apiKey: 'YOUR_API_KEY');
/// final (best, all) = await geocoding.reverseGeocode(const LatLng(48.85, 2.29));
/// geocoding.dispose();
/// ```
class GeoCodingConfig {
  /// The Google Maps Platform API key. Requires the Geocoding API to be
  /// enabled for the project.
  final String apiKey;

  /// An HTTP client to use instead of the default one.
  ///
  /// When supplied, [dispose] does *not* close it — you own its lifetime.
  final http.Client? httpClient;

  /// Extra headers sent with every geocoding request.
  ///
  /// Use this for API keys restricted to a bundle identifier or an Android
  /// signing certificate. See the README for the exact header names.
  final Map<String, String>? apiHeaders;

  /// An alternative base URL, e.g. a CORS proxy for Flutter web.
  final String? baseUrl;

  /// The language results are returned in, as an IETF tag such as `en` or
  /// `fr-CA`.
  final String? language;

  /// Restricts results to these location types, e.g. `ROOFTOP`.
  final List<String> locationType;

  /// Restricts results to these address types, e.g. `street_address`.
  final List<String> resultType;

  /// Called for every failure, so a caller can tell an invalid key from a
  /// genuinely empty area.
  final MapPickerErrorCallback? onError;

  /// Creates a geocoding client.
  GeoCodingConfig({
    required this.apiKey,
    this.httpClient,
    this.apiHeaders,
    this.baseUrl,
    this.language,
    this.locationType = const [],
    this.resultType = const [],
    this.onError,
  });

  http.Client? _ownedClient;
  bool _disposed = false;

  /// One client per instance rather than one per request.
  ///
  /// Creating a `GoogleMapsGeocoding` per call leaked a fresh `http.Client`
  /// (and its connection pool) on every pin move.
  GoogleMapsGeocoding get _geocoding {
    final client = httpClient ?? (_ownedClient ??= http.Client());
    return GoogleMapsGeocoding(
      apiKey: apiKey,
      httpClient: client,
      apiHeaders: apiHeaders,
      baseUrl: baseUrl,
    );
  }

  /// Looks up the addresses at [position].
  ///
  /// Returns `(bestResult, allResults)`. Both are empty/null when nothing was
  /// found *or* when the request failed; supply [onError] to tell them apart.
  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position,
  ) async {
    if (_disposed) return (null, const <GeocodingResult>[]);
    try {
      final response = await _geocoding.searchByLocation(
        Location(lat: position.latitude, lng: position.longitude),
        language: language,
        locationType: locationType,
        resultType: resultType,
      );

      final failure = _failureFor(response);
      if (failure != null) {
        onError?.call(failure);
        return (null, const <GeocodingResult>[]);
      }

      final results = response.results ?? const <GeocodingResult>[];
      return (results.isNotEmpty ? results.first : null, results);
    } catch (e, s) {
      onError?.call(
        MapLocationPickerException(
          MapPickerErrorKind.network,
          'Reverse geocoding request failed: $e',
          cause: e,
          stackTrace: s,
        ),
      );
      return (null, const <GeocodingResult>[]);
    }
  }

  /// Translates a Geocoding API status into a typed failure, or null on
  /// success.
  MapLocationPickerException? _failureFor(GeocodingResponse response) {
    if (response.isDenied) {
      return MapLocationPickerException(
        MapPickerErrorKind.requestDenied,
        response.errorMessage ??
            'The Geocoding API rejected the request. Check that the key is '
                'valid, that the Geocoding API is enabled, and that any key '
                'restrictions match this app.',
      );
    }
    if (response.isOverQueryLimit) {
      return MapLocationPickerException(
        MapPickerErrorKind.quotaExceeded,
        response.errorMessage ??
            'The Geocoding API quota was exceeded, or billing is not enabled.',
      );
    }
    if (response.isInvalid) {
      return MapLocationPickerException(
        MapPickerErrorKind.invalidRequest,
        response.errorMessage ?? 'The Geocoding request was malformed.',
      );
    }
    if (response.unknownError) {
      return MapLocationPickerException(
        MapPickerErrorKind.unknown,
        response.errorMessage ?? 'The Geocoding API returned an unknown error.',
      );
    }
    if (response.hasNoResults || response.isNotFound) {
      return const MapLocationPickerException(
        MapPickerErrorKind.noResults,
        'No address was found at this location.',
      );
    }
    return null;
  }

  /// Releases the HTTP client this instance created.
  ///
  /// A client passed in as [httpClient] is left alone.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _ownedClient?.close();
    _ownedClient = null;
  }
}

/// Convenience accessors for pulling individual parts out of a
/// [GeocodingResult].
///
/// The Geocoding API returns address components as an unordered list of typed
/// entries, so reading "the postcode" normally means writing a search each
/// time.
///
/// ```dart
/// final city = result.component('locality');
/// final country = result.countryCode; // e.g. 'FR'
/// ```
extension GeocodingResultParts on GeocodingResult {
  /// The long name of the first component matching [type], e.g. `locality`,
  /// `postal_code`, `country`, `administrative_area_level_1`.
  String? component(String type) {
    for (final c in addressComponents ?? const <AddressComponent>[]) {
      if (c.types?.contains(type) ?? false) return c.longName;
    }
    return null;
  }

  /// The short name of the first component matching [type], e.g. `FR` rather
  /// than `France`.
  String? shortComponent(String type) {
    for (final c in addressComponents ?? const <AddressComponent>[]) {
      if (c.types?.contains(type) ?? false) return c.shortName;
    }
    return null;
  }

  /// The street number, when the result is precise enough to have one.
  String? get streetNumber => component('street_number');

  /// The street name.
  String? get street => component('route');

  /// The city or town.
  String? get city => component('locality') ?? component('postal_town');

  /// The neighbourhood or sub-locality.
  String? get subLocality => component('sublocality');

  /// The state, province or region.
  String? get administrativeArea => component('administrative_area_level_1');

  /// The postal or ZIP code.
  String? get postalCode => component('postal_code');

  /// The country name.
  String? get country => component('country');

  /// The ISO 3166-1 alpha-2 country code, e.g. `FR`.
  String? get countryCode => shortComponent('country');

  /// The coordinates of this result, or null when the geometry is missing.
  LatLng? get latLng {
    final location = geometry?.location;
    if (location == null) return null;
    return LatLng(location.lat, location.lng);
  }
}

/// Builds a Google Static Maps URL showing a red marker at ([lat], [lon]).
///
/// Handy for rendering a preview of a picked location without embedding a live
/// map. Requires the Maps Static API to be enabled for [apiKey].
///
/// ```dart
/// Image.network(googleStaticMapWithMarker(48.85, 2.29, 16, apiKey: key));
/// ```
String googleStaticMapWithMarker(
  double lat,
  double lon,
  int zoom, {
  int width = 600,
  int height = 400,
  String apiKey = "",
}) {
  return 'https://maps.googleapis.com/maps/api/staticmap'
      '?center=$lat,$lon'
      '&zoom=$zoom'
      '&size=${width}x$height'
      '&markers=color:red%7C$lat,$lon'
      '&key=$apiKey';
}

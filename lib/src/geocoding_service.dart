import 'package:http/http.dart' as http;
import 'package:map_location_picker/map_location_picker.dart';

/// The geocoding service to use for the map location picker.
class GeoCodingConfig {
  /// The API key for the geocoding service.
  final String apiKey;

  /// The HTTP client to use for the geocoding service.
  final http.Client? httpClient;

  /// The API headers to use for the geocoding service.
  final Map<String, String>? apiHeaders;
  final String? baseUrl;
  final String? language;
  final List<String> locationType;
  final List<String> resultType;

  GeoCodingConfig({
    required this.apiKey,
    this.httpClient,
    this.apiHeaders,
    this.baseUrl,
    this.language,
    this.locationType = const [],
    this.resultType = const [],
  });

  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
    LatLng position,
  ) async {
    final geocoding = GoogleMapsGeocoding(
      apiKey: apiKey,
      httpClient: httpClient,
      apiHeaders: apiHeaders,
      baseUrl: baseUrl,
    );

    final response = await geocoding.searchByLocation(
      Location(lat: position.latitude, lng: position.longitude),
      language: language,
      locationType: locationType,
      resultType: resultType,
    );
    if (_isErrorResponse(response)) return (null, <GeocodingResult>[]);
    return (
      response.results?.isNotEmpty ?? false
          ? response.results?.firstOrNull
          : null,
      response.results ?? <GeocodingResult>[]
    );
  }

  bool _isErrorResponse(GeocodingResponse response) {
    return response.hasNoResults ||
        response.isDenied ||
        response.isInvalid ||
        response.isNotFound ||
        response.unknownError ||
        response.isOverQueryLimit;
  }
}

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

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webapi/geocoding.dart';
import 'package:http/http.dart';

/// The geocoding service to use for the map location picker.
class GeoCodingService {
  /// The API key for the geocoding service.
  final String apiKey;

  /// The HTTP client to use for the geocoding service.
  final Client? httpClient;

  /// The API headers to use for the geocoding service.
  final Map<String, String>? apiHeaders;
  final String? baseUrl;
  final String? language;
  final List<String> locationType;
  final List<String> resultType;

  GeoCodingService({
    required this.apiKey,
    this.httpClient,
    this.apiHeaders,
    this.baseUrl,
    this.language,
    this.locationType = const [],
    this.resultType = const [],
  });

  Future<(GeocodingResult?, List<GeocodingResult>)> reverseGeocode(
      LatLng position) async {
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
      response.results.isNotEmpty ? response.results.firstOrNull : null,
      response.results
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

import 'package:google_maps_apis/places_new.dart' hide LatLng;
import 'package:google_maps_flutter/google_maps_flutter.dart' hide Circle;

import 'logger.dart';

/// The geocoding service to use for the map location picker.
class GeoCodingConfig {
  /// The HTTP client to use for the geo decoding.
  final PlacesAPINew? placesApi;

  /// The API key for the geocoding service.
  final String apiKey;

  GeoCodingConfig({
    this.placesApi,
    required this.apiKey,
  });

  Future<(Place?, List<Place>)> reverseGeocode({
    required LatLng position,
    NearbySearchFilter? filter,

    /// if true, all fields will be returned.
    /// if false, only the fields specified in the fields parameter will be returned.
    /// ensure [allFields] is false if you are using [fields] parameter.
    bool allFields = true,

    /// the fields to return.
    /// Ensure that allFields = true or fields != null, or instanceFields != null with some field != null.
    /// [Pricing note](https://developers.google.com/maps/documentation/places/web-service/autocomplete#pricing)
    ///
    /// ```
    ///  Each field group (Basic, Contact, Atmosphere) has a separate billing weight.
    ///  So selecting more fields increases cost.
    ///  Examples:
    ///  fields=name,geometry = cheaper
    ///  fields=name,geometry,reviews,photos = more expensive.
    /// ```
    ///
    List<String>? fields,
    PlacesResponse? instanceFields,
    double radius = 500,
  }) async {
    final geocoding = placesApi ?? PlacesAPINew(apiKey: apiKey);
    final response = await geocoding.searchNearby(
      filter: filter ??
          NearbySearchFilter(
            locationRestriction: LocationRestrictionCircle(
              circle: Circle(
                center: ReferencePoint(
                  latitude: position.latitude,
                  longitude: position.longitude,
                ),
                // radius: radius,
              ),
            ),
          ),
      allFields: allFields,
      fields: fields,
      instanceFields: instanceFields,
    );
    if (_isErrorResponse(response)) return (null, <Place>[]);
    return (
      response.body?.places.firstOrNull,
      response.body?.places ?? <Place>[]
    );
  }

  bool _isErrorResponse(GoogleHTTPResponse<PlacesResponse?> response) {
    final isError = response.error != null && !response.isSuccessful;
    if (isError) {
      mapLogger.e(response.error?.error?.toJsonString());
    }
    return isError;
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

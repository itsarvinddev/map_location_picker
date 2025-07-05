import "package:google_maps_webapi/places.dart";
import 'package:http/http.dart';

import 'logger.dart';

class AutoCompleteService {
  final Client? httpClient;
  final Map<String, String>? apiHeaders;
  final String? baseUrl;

  AutoCompleteService({this.httpClient, this.apiHeaders, this.baseUrl});

  Future<List<Prediction>> search({
    required String query,
    required String apiKey,
    String? sessionToken,
    num? offset,
    Location? origin,
    Location? location,
    num? radius,
    String? language,
    List<String> types = const [],
    List<Component> components = const [],
    bool strictbounds = false,
    String? region,
  }) async {
    try {
      final places = GoogleMapsPlaces(
        apiKey: apiKey,
        httpClient: httpClient,
        apiHeaders: apiHeaders,
        baseUrl: baseUrl,
      );

      final response = await places.autocomplete(
        query,
        region: region,
        language: language,
        components: components,
        location: location,
        offset: offset,
        origin: origin,
        radius: radius,
        sessionToken: sessionToken,
        strictbounds: strictbounds,
        types: types,
      );

      if (_isErrorResponse(response)) {
        if (query.isNotEmpty) mapLogger.e(response.errorMessage);
        return [];
      }

      return response.predictions;
    } catch (err) {
      mapLogger.e(err);
      return [];
    }
  }

  bool _isErrorResponse(PlacesAutocompleteResponse response) {
    return response.hasNoResults ||
        response.isDenied ||
        response.isInvalid ||
        response.isNotFound ||
        response.unknownError ||
        response.isOverQueryLimit;
  }
}

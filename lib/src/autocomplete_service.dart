import 'package:dio/dio.dart' show CancelToken;
import 'package:google_maps_apis/places_new.dart';

import 'logger.dart';

/// The autocomplete service for the map location picker.
/// [AutoCompleteService] service is used to search for places and get the details of the place.
///
/// ```dart
/// final service = AutoCompleteService(
///   placesApi: PlacesAPINew(apiKey: "YOUR_API_KEY"),
/// );
/// ```
///
class AutoCompleteService {
  /// The HTTP client to use for the autocomplete service.
  final PlacesAPINew? placesApi;

  AutoCompleteService({this.placesApi});

  Future<List<Suggestion>> search({
    required String query,
    required String apiKey,
    AutocompleteSearchFilter? filter,

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
    List<String>? fields,

    /// the instance fields to return.
    /// [Pricing note](https://developers.google.com/maps/documentation/places/web-service/autocomplete#pricing)
    ///
    /// ```
    ///  Each field group (Basic, Contact, Atmosphere) has a separate billing weight.
    ///  So selecting more fields increases cost.
    PlacesSuggestions? instanceFields,
    SessionTokenHandler? sessionToken,
    CancelToken? cancelToken,
  }) async {
    try {
      if (query.isEmpty) return [];
      final places = placesApi ?? PlacesAPINew(apiKey: apiKey);
      sessionToken ??= SessionTokenHandler();
      cancelToken ??= CancelToken();
      final response = await places.searchAutocomplete(
        filter: filter ??
            AutocompleteSearchFilter(
              input: query,
              sessionToken: sessionToken.token,
            ),
        allFields: allFields,
        fields: fields,
        instanceFields: instanceFields,
        cancelToken: cancelToken,
      );

      if (_isErrorResponse(response)) return <Suggestion>[];
      final suggestions = response.body?.suggestions ?? <Suggestion>[];
      return suggestions;
    } catch (err) {
      mapLogger.e(err);
      return <Suggestion>[];
    }
  }

  bool _isErrorResponse(GoogleHTTPResponse<PlacesSuggestions?> response) {
    final isError = response.error != null && !response.isSuccessful;
    if (isError) {
      mapLogger.e(response.error?.error?.toJsonString());
    }
    return isError;
  }
}

/// Web implementation of autocomplete service using Google Maps JavaScript API.
///
/// This file is used when dart:js_interop is available (web platform).
/// It uses the Google Maps JavaScript API directly via JS interop,
/// which avoids CORS issues that occur with direct HTTP requests.
///
/// This file should not be imported directly - use [autocomplete_service.dart] instead.
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart' show CancelToken;
import 'package:google_maps_apis/places_new.dart';

import '../logger.dart';

// --- JS interop types for Google Maps Places AutocompleteService ---

@JS('google.maps.places.AutocompleteService')
extension type _JsAutocompleteService._(JSObject _) implements JSObject {
  external _JsAutocompleteService();
  external void getPlacePredictions(
    _JsAutocompletionRequest request,
    JSFunction callback,
  );
}

extension type _JsAutocompletionRequest._(JSObject _) implements JSObject {
  external factory _JsAutocompletionRequest({String input});
}

extension type _JsAutocompletePrediction._(JSObject _) implements JSObject {
  // ignore: non_constant_identifier_names
  external String get place_id;
  external String get description;
  // ignore: non_constant_identifier_names
  external _JsStructuredFormatting get structured_formatting;
}

extension type _JsStructuredFormatting._(JSObject _) implements JSObject {
  // ignore: non_constant_identifier_names
  external String get main_text;
  // ignore: non_constant_identifier_names
  external String get secondary_text;
}

/// Checks if the Google Maps JavaScript API with Places library is loaded.
bool _isGoogleMapsPlacesLoaded() {
  try {
    final google = globalContext.getProperty<JSAny?>('google'.toJS);
    if (google == null || google.isUndefinedOrNull) return false;
    final maps = (google as JSObject).getProperty<JSAny?>('maps'.toJS);
    if (maps == null || maps.isUndefinedOrNull) return false;
    final places = (maps as JSObject).getProperty<JSAny?>('places'.toJS);
    return places != null && !places.isUndefinedOrNull;
  } catch (_) {
    return false;
  }
}

/// The autocomplete service for the map location picker on web platform.
/// [AutoCompleteService] service is used to search for places and get the details of the place.
///
/// This implementation uses the Google Maps JavaScript API directly via JS interop,
/// which avoids CORS issues that occur when making direct HTTP requests from the browser.
///
/// ```dart
/// final service = AutoCompleteService(
///   placesApi: PlacesAPINew(apiKey: "YOUR_API_KEY"),
/// );
/// ```
///
class AutoCompleteService {
  /// The HTTP client to use for the autocomplete service.
  /// Note: On web, this is not used for autocomplete searches.
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

    /// Country codes to restrict results to (ISO 3166-1 Alpha-2).
    /// Note: On web, country restriction is not applied via JS API autocomplete
    /// service. Use the Places API (New) search filter for server-side filtering.
    List<String>? countries,
  }) async {
    try {
      if (query.isEmpty) return [];

      // Check if Google Maps JavaScript API with Places library is loaded
      if (!_isGoogleMapsPlacesLoaded()) {
        mapLogger.w(
          'Google Maps JavaScript API with Places library not loaded. '
          'Make sure to include the script tag in your index.html: '
          '<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>',
        );
        // Fall back to returning empty results rather than failing
        return <Suggestion>[];
      }

      // Use the Google Maps JavaScript API for autocomplete
      return _searchWithJsApi(query);
    } catch (err) {
      mapLogger.e('Error in web autocomplete: $err');
      return <Suggestion>[];
    }
  }

  /// Performs autocomplete search using the Google Maps JavaScript API.
  Future<List<Suggestion>> _searchWithJsApi(String query) async {
    try {
      final service = _JsAutocompleteService();
      final request = _JsAutocompletionRequest(input: query);

      final completer = Completer<List<Suggestion>>();

      void onResult(JSArray? predictions, JSString status) {
        try {
          final statusStr = status.toDart;
          if (statusStr != 'OK' || predictions == null) {
            completer.complete(<Suggestion>[]);
            return;
          }

          final suggestions = <Suggestion>[];
          for (int i = 0; i < predictions.length; i++) {
            final prediction =
                predictions[i] as _JsAutocompletePrediction;
            suggestions.add(_convertPrediction(prediction));
          }
          completer.complete(suggestions);
        } catch (e) {
          mapLogger.e('Error processing autocomplete predictions: $e');
          completer.complete(<Suggestion>[]);
        }
      }

      service.getPlacePredictions(request, onResult.toJS);

      return completer.future;
    } catch (e) {
      mapLogger.e('Error calling Google Maps JS API: $e');
      return <Suggestion>[];
    }
  }

  /// Converts a JavaScript AutocompletePrediction to a [Suggestion] object.
  Suggestion _convertPrediction(_JsAutocompletePrediction prediction) {
    String mainText = '';
    String secondaryText = '';

    try {
      final formatting = prediction.structured_formatting;
      mainText = formatting.main_text;
      secondaryText = formatting.secondary_text;
    } catch (_) {
      // structured_formatting may not be available
    }

    return Suggestion(
      placePrediction: PlacePrediction(
        placeId: prediction.place_id,
        structuredFormat: StructuredFormat(
          mainText: FormattableText(text: mainText),
          secondaryText: FormattableText(text: secondaryText),
        ),
      ),
    );
  }
}

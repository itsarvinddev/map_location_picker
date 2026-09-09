/// REST implementation of the autocomplete service, used everywhere except web.
///
/// This talks to the Places API (New) over HTTPS via the `google_maps_apis`
/// package. It is selected by the conditional export in
/// `autocomplete_service.dart` — do not import this file directly.
library;

import 'package:dio/dio.dart' show CancelToken, DioException, DioExceptionType;
import 'package:google_maps_apis/places_new.dart';

import '../exceptions.dart';
import '../logger.dart';

/// Looks up place predictions and place details through the Google Places
/// API (New).
///
/// On every platform except web this issues plain HTTPS requests. On web the
/// identically-named class in `autocomplete_service_web.dart` is used instead,
/// because `places.googleapis.com` does not send CORS headers.
///
/// ```dart
/// final service = AutoCompleteService(
///   placesApi: PlacesAPINew(apiKey: 'YOUR_API_KEY'),
/// );
/// final suggestions = await service.search(
///   query: 'coffee',
///   apiKey: 'YOUR_API_KEY',
/// );
/// ```
class AutoCompleteService {
  /// A pre-configured Places API client.
  ///
  /// Supply this to control headers, interceptors, timeouts or the base URL —
  /// for example to route requests through your own proxy. When null, a client
  /// is created from the `apiKey` passed to each method.
  final PlacesAPINew? placesApi;

  /// Called for every failure, including ones that are recovered from.
  ///
  /// Without this, a failed lookup is indistinguishable from "no matches".
  final MapPickerErrorCallback? onError;

  /// Creates a service.
  AutoCompleteService({this.placesApi, this.onError});

  /// Whether this implementation reaches Google over HTTPS (true here, false
  /// on web where the Maps JavaScript API is used instead).
  static const bool usesRestTransport = true;

  PlacesAPINew _client(String apiKey) =>
      placesApi ?? PlacesAPINew(apiKey: apiKey);

  /// Returns place predictions for [query].
  ///
  /// Returns an empty list when there is nothing to show *or* when the request
  /// failed; supply [onError] on the constructor to tell those apart.
  ///
  /// [filter] is merged rather than replaced: the caller's regionCode,
  /// languageCode, includedRegionCodes, locationBias and friends are all kept,
  /// and only [query] is injected as `input`. A `sessionToken` already present
  /// on [filter] wins over [sessionToken].
  Future<List<Suggestion>> search({
    required String query,
    required String apiKey,

    /// Restricts or biases the search. Merged with the query, never replaced.
    AutocompleteSearchFilter? filter,

    /// Request every field. Cheaper responses come from setting this false and
    /// naming only the fields you render.
    ///
    /// See https://developers.google.com/maps/documentation/places/web-service/autocomplete#pricing
    bool allFields = true,

    /// The exact fields to return. Requires [allFields] to be false.
    List<String>? fields,

    /// A [PlacesSuggestions] instance whose non-null fields form the field
    /// mask. An alternative to [fields].
    PlacesSuggestions? instanceFields,

    /// The session that groups these keystrokes with the eventual
    /// [getDetails] call for billing. Reuse one handler for a whole search.
    SessionTokenHandler? sessionToken,

    /// Cancels this request. A fresh token is used when omitted.
    CancelToken? cancelToken,
  }) async {
    if (query.isEmpty) return const <Suggestion>[];
    final session = sessionToken ?? SessionTokenHandler();
    try {
      final response = await _client(apiKey).searchAutocomplete(
        // Merge, do not replace. Replacing is what broke #70: a caller-supplied
        // filter dropped `input`, so Google never received the search text.
        filter: (filter ?? AutocompleteSearchFilter()).copyWith(
          input: query,
          sessionToken: filter?.sessionToken ?? session.token,
        ),
        allFields: allFields,
        fields: fields,
        instanceFields: instanceFields,
        // A caller-supplied CancelToken is deliberately not reused here: once
        // cancelled, a CancelToken stays cancelled, which would kill every
        // later keystroke.
        cancelToken: cancelToken ?? CancelToken(),
      );

      if (_reportIfError(response.error, response.statusCode)) {
        return const <Suggestion>[];
      }
      return response.body?.suggestions ?? const <Suggestion>[];
    } catch (err, stack) {
      _reportThrown(err, stack);
      return const <Suggestion>[];
    }
  }

  /// Fetches the full [Place] for [placeId], concluding the autocomplete
  /// session.
  ///
  /// Passing [sessionToken] here is what makes the preceding [search] calls
  /// bill as one session rather than one charge per keystroke.
  Future<Place?> getDetails({
    required String placeId,
    required String apiKey,
    bool allFields = true,
    List<String>? fields,
    Place? instanceFields,
    PlaceDetailsFilter? filter,
    SessionTokenHandler? sessionToken,
    CancelToken? cancelToken,
  }) async {
    if (placeId.isEmpty) return null;
    final cached = sessionToken?.placeFromCache(placeId);
    if (cached != null) return cached;
    try {
      final response = await _client(apiKey).getDetails(
        id: placeId,
        allFields: allFields,
        fields: fields,
        instanceFields: instanceFields,
        filter:
            filter?.copyWith(
              sessionToken: filter.sessionToken ?? sessionToken?.token,
            ) ??
            PlaceDetailsFilter(sessionToken: sessionToken?.token),
        cancelToken: cancelToken ?? CancelToken(),
      );

      if (_reportIfError(response.error, response.statusCode)) return null;
      // Caching the details also refreshes the session token, which is how the
      // Places session is formally concluded.
      sessionToken?.cachePlaceDetails(id: placeId, data: response.body);
      return response.body;
    } catch (err, stack) {
      _reportThrown(err, stack);
      return null;
    }
  }

  /// Reports an API-level error. Returns true when [error] was a failure.
  bool _reportIfError(GoogleErrorResponse? error, int? statusCode) {
    if (error == null) return false;
    final message =
        error.error?.message ??
        error.error?.toJsonString() ??
        'Places request failed';
    mapLogger.e(message);
    onError?.call(
      MapLocationPickerException(
        mapPickerErrorKindFromStatus(statusCode ?? error.error?.code),
        message,
        statusCode: statusCode ?? error.error?.code,
      ),
    );
    return true;
  }

  void _reportThrown(Object err, StackTrace stack) {
    mapLogger.e(err, stackTrace: stack);
    onError?.call(_translate(err, stack));
  }

  MapLocationPickerException _translate(Object err, StackTrace stack) {
    if (err is DioException) {
      final kind = switch (err.type) {
        DioExceptionType.cancel => MapPickerErrorKind.cancelled,
        DioExceptionType.connectionTimeout ||
        DioExceptionType.receiveTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.connectionError => MapPickerErrorKind.network,
        DioExceptionType.badResponse => mapPickerErrorKindFromStatus(
          err.response?.statusCode,
        ),
        _ => MapPickerErrorKind.unknown,
      };
      return MapLocationPickerException(
        kind,
        err.message ?? err.toString(),
        statusCode: err.response?.statusCode,
        cause: err,
        stackTrace: stack,
      );
    }
    return MapLocationPickerException(
      MapPickerErrorKind.unknown,
      err.toString(),
      cause: err,
      stackTrace: stack,
    );
  }
}

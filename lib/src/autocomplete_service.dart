/// Autocomplete and place-details lookups against the Places API (New).
library;

import 'dart:async' show TimeoutException;

import 'package:dio/dio.dart' show CancelToken, DioException, DioExceptionType;
import 'package:http/http.dart' show ClientException;
import 'package:google_maps_apis/places_new.dart';

import 'exceptions.dart';
import 'logger.dart';

/// Looks up place predictions and place details through the Google Places
/// API (New).
///
/// One HTTPS transport on every platform, web included.
/// `places.googleapis.com` answers CORS preflights with
/// `Access-Control-Allow-Headers: content-type, x-goog-api-key,
/// x-goog-fieldmask`, and `google_maps_apis` sends the key as the
/// `x-goog-api-key` header, so browser requests are allowed. (Issue #14's CORS
/// failure was against the *legacy* `/maps/api/place/...` endpoints, which this
/// package no longer calls.)
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

  PlacesAPINew? _owned;
  String? _ownedKey;

  /// One client per API key rather than one per request.
  ///
  /// Building a [PlacesAPINew] per call created a fresh Dio/HttpClient on every
  /// debounced keystroke, so no TLS connection was ever reused and each pool
  /// was left open. Keyed on [apiKey] so a `copyWith(apiKey: ...)` is honoured.
  PlacesAPINew _client(String apiKey) {
    final injected = placesApi;
    if (injected != null) return injected;
    final owned = _owned;
    if (owned != null && _ownedKey == apiKey) return owned;
    _closeOwned();
    _ownedKey = apiKey;
    return _owned = PlacesAPINew(apiKey: apiKey);
  }

  void _closeOwned() {
    try {
      _owned?.restAPI.dispose();
    } catch (_) {
      // Closing an already-closed client must not break a lookup.
    }
    _owned = null;
    _ownedKey = null;
  }

  /// Closes the client this service created.
  ///
  /// An injected [placesApi] is left alone -- you own its lifetime, as with
  /// [GeoCodingConfig.dispose].
  void dispose() => _closeOwned();

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
      final effectiveCancel = cancelToken ?? CancelToken();
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
        cancelToken: effectiveCancel,
      );

      if (_reportIfError(response, effectiveCancel)) {
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
    if (cached != null) {
      // Serving from cache still concludes the session: the user has picked a
      // place, so the keystrokes that led here are over. Skipping the refresh
      // would carry a token Google has already seen into the next session, and
      // a reused token is billed as if no token had been sent at all.
      sessionToken?.refresh();
      return cached;
    }
    try {
      final effectiveCancel = cancelToken ?? CancelToken();
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
        cancelToken: effectiveCancel,
      );

      if (_reportIfError(response, effectiveCancel)) return null;
      // Caching the details also refreshes the session token, which is how the
      // Places session is formally concluded.
      sessionToken?.cachePlaceDetails(id: placeId, data: response.body);
      return response.body;
    } catch (err, stack) {
      _reportThrown(err, stack);
      return null;
    }
  }

  /// Reports an API-level error. Returns true when [response] was a failure.
  ///
  /// A non-2xx response counts even when `error` is null: the package
  /// fabricates a response rather than throwing when a request is cancelled.
  bool _reportIfError(GoogleHTTPResponse<Object?> response, CancelToken token) {
    if (response.error == null && response.isSuccessful) return false;
    if (token.isCancelled) {
      onError?.call(
        const MapLocationPickerException(
          MapPickerErrorKind.cancelled,
          'Request cancelled',
        ),
      );
      return true;
    }
    final status = response.statusCode;
    final message =
        response.error?.error?.message ??
        response.error?.error?.toJsonString() ??
        'Places request failed (HTTP $status)';
    mapLogger.e(message);
    onError?.call(
      MapLocationPickerException(
        mapPickerErrorKindFromStatus(status),
        message,
        statusCode: status,
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
    if (err is TimeoutException) {
      return MapLocationPickerException(
        MapPickerErrorKind.network,
        'The Places request timed out.',
        cause: err,
        stackTrace: stack,
      );
    }
    // SocketException lives in dart:io, which this package cannot import
    // (it supports web, including wasm). Match on the runtime type name
    // instead -- these arrive unwrapped, not as DioExceptions.
    final typeName = err.runtimeType.toString();
    if (err is ClientException ||
        typeName == 'SocketException' ||
        typeName == 'HandshakeException' ||
        typeName == 'HttpException') {
      return MapLocationPickerException(
        MapPickerErrorKind.network,
        'The Places request could not reach Google: $err',
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

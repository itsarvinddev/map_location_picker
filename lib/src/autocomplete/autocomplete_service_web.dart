/// Web implementation of the autocomplete service.
///
/// `places.googleapis.com` does not send CORS headers, so the REST transport
/// used on every other platform cannot work from a browser — that is the root
/// of issue #14. This implementation instead drives the Maps JavaScript API,
/// which the browser is allowed to call.
///
/// It uses `google.maps.places.AutocompleteSuggestion` and
/// `google.maps.places.Place`, not the older
/// `google.maps.places.AutocompleteService` / `PlacesService`. Google closed
/// those legacy classes to new customers on 1 March 2025, so a project created
/// after that date cannot use them at all.
///
/// Requires the Places library to be loaded, e.g.
/// ```html
/// <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
/// ```
///
/// Do not import this file directly — use `autocomplete_service.dart`.
library;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:dio/dio.dart' show CancelToken;
import 'package:google_maps_apis/places_new.dart';

import '../exceptions.dart';
import '../logger.dart';

// --- JS interop bindings for the Places (New) JavaScript API ---------------

@JS('google.maps.places.AutocompleteSuggestion')
extension type _JsAutocompleteSuggestion._(JSObject _) implements JSObject {
  external static JSPromise<JSObject> fetchAutocompleteSuggestions(
    JSObject request,
  );
}

@JS('google.maps.places.AutocompleteSessionToken')
extension type _JsSessionToken._(JSObject _) implements JSObject {
  external factory _JsSessionToken();
}

extension type _JsSuggestion._(JSObject _) implements JSObject {
  external _JsPlacePrediction? get placePrediction;
}

extension type _JsPlacePrediction._(JSObject _) implements JSObject {
  external String? get placeId;
  external _JsText? get text;
  external _JsText? get mainText;
  external _JsText? get secondaryText;
  external _JsPlace toPlace();
}

extension type _JsText._(JSObject _) implements JSObject {
  external String? get text;
}

extension type _JsPlace._(JSObject _) implements JSObject {
  external JSPromise<JSObject> fetchFields(JSObject request);
  external String? get id;
  external String? get displayName;
  external String? get formattedAddress;
  external _JsLatLng? get location;
  external JSArray<_JsAddressComponent>? get addressComponents;
}

extension type _JsLatLng._(JSObject _) implements JSObject {
  external double lat();
  external double lng();
}

extension type _JsAddressComponent._(JSObject _) implements JSObject {
  external String? get longText;
  external String? get shortText;
  external JSArray<JSString>? get types;
}

/// Whether `google.maps.places` is present on the page.
bool _isPlacesLibraryLoaded() {
  try {
    final google = globalContext.getProperty<JSAny?>('google'.toJS);
    if (google.isUndefinedOrNull) return false;
    final maps = (google! as JSObject).getProperty<JSAny?>('maps'.toJS);
    if (maps.isUndefinedOrNull) return false;
    final places = (maps! as JSObject).getProperty<JSAny?>('places'.toJS);
    if (places.isUndefinedOrNull) return false;
    return !(places! as JSObject)
        .getProperty<JSAny?>('AutocompleteSuggestion'.toJS)
        .isUndefinedOrNull;
  } catch (_) {
    return false;
  }
}

const String _missingLibraryMessage =
    'The Google Maps JavaScript API with the "places" library is not loaded. '
    'Add this to web/index.html:\n'
    '<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>\n'
    'On web the Places REST endpoint cannot be called directly because '
    'places.googleapis.com does not send CORS headers.';

/// Looks up place predictions and place details through the Maps JavaScript
/// API.
///
/// The public surface matches the REST implementation used on other platforms,
/// so calling code does not branch on platform.
class AutoCompleteService {
  /// Ignored on web — kept so the constructor matches the REST implementation.
  ///
  /// Autocomplete on web goes through the Maps JavaScript API, so a
  /// [PlacesAPINew] client (headers, interceptors, base URL) has no effect
  /// here.
  final PlacesAPINew? placesApi;

  /// Called for every failure, including ones that are recovered from.
  final MapPickerErrorCallback? onError;

  /// Creates a service.
  AutoCompleteService({this.placesApi, this.onError});

  /// Whether this implementation reaches Google over HTTPS. False on web.
  static const bool usesRestTransport = false;

  /// One JS session token per Dart session token, so the browser API bills the
  /// same way the REST API would.
  static final Map<String, _JsSessionToken> _jsSessions = {};

  static _JsSessionToken _jsSessionFor(SessionTokenHandler? handler) {
    if (handler == null) return _JsSessionToken();
    return _jsSessions.putIfAbsent(handler.token, () => _JsSessionToken());
  }

  /// Returns place predictions for [query].
  ///
  /// Honours [filter]'s `languageCode`, `regionCode`, `includedRegionCodes`,
  /// `includedPrimaryTypes`, `inputOffset` and `origin`. `locationBias` and
  /// `locationRestriction` are not forwarded — the JavaScript API wants
  /// `LatLngBounds`/`Circle` instances rather than the REST shapes — and a
  /// warning is logged when they are set so the drop is never silent.
  Future<List<Suggestion>> search({
    required String query,
    required String apiKey,
    AutocompleteSearchFilter? filter,
    bool allFields = true,
    List<String>? fields,
    PlacesSuggestions? instanceFields,
    SessionTokenHandler? sessionToken,
    CancelToken? cancelToken,
  }) async {
    if (query.isEmpty) return const <Suggestion>[];

    if (!_isPlacesLibraryLoaded()) {
      mapLogger.w(_missingLibraryMessage);
      onError?.call(
        const MapLocationPickerException(
          MapPickerErrorKind.unsupportedPlatform,
          _missingLibraryMessage,
        ),
      );
      return const <Suggestion>[];
    }

    if (filter?.locationBias != null || filter?.locationRestriction != null) {
      mapLogger.w(
        'locationBias / locationRestriction are not forwarded to the Maps '
        'JavaScript API on web. Use includedRegionCodes to narrow results '
        'instead.',
      );
    }

    try {
      final request = JSObject();
      request.setProperty('input'.toJS, query.toJS);
      request.setProperty(
        'sessionToken'.toJS,
        _jsSessionFor(sessionToken) as JSAny,
      );
      final language = filter?.languageCode;
      if (language != null) request.setProperty('language'.toJS, language.toJS);
      final region = filter?.regionCode;
      if (region != null) request.setProperty('region'.toJS, region.toJS);
      final regionCodes = filter?.includedRegionCodes;
      if (regionCodes != null && regionCodes.isNotEmpty) {
        request.setProperty(
          'includedRegionCodes'.toJS,
          regionCodes.map((e) => e.toJS).toList().toJS,
        );
      }
      final primaryTypes = filter?.includedPrimaryTypes;
      if (primaryTypes != null && primaryTypes.isNotEmpty) {
        request.setProperty(
          'includedPrimaryTypes'.toJS,
          primaryTypes.map((e) => e.name.toJS).toList().toJS,
        );
      }
      final inputOffset = filter?.inputOffset;
      if (inputOffset != null) {
        request.setProperty('inputOffset'.toJS, inputOffset.toJS);
      }
      final origin = filter?.origin;
      if (origin?.latitude != null && origin?.longitude != null) {
        final jsOrigin = JSObject();
        jsOrigin.setProperty('lat'.toJS, origin!.latitude!.toJS);
        jsOrigin.setProperty('lng'.toJS, origin.longitude!.toJS);
        request.setProperty('origin'.toJS, jsOrigin);
      }

      final result =
          await _JsAutocompleteSuggestion.fetchAutocompleteSuggestions(
            request,
          ).toDart;

      final raw = result.getProperty<JSAny?>('suggestions'.toJS);
      if (raw.isUndefinedOrNull) return const <Suggestion>[];
      final jsSuggestions = (raw! as JSArray<_JsSuggestion>).toDart;

      return jsSuggestions
          .map(_toSuggestion)
          .whereType<Suggestion>()
          .toList(growable: false);
    } catch (err, stack) {
      mapLogger.e(err, stackTrace: stack);
      onError?.call(
        MapLocationPickerException(
          MapPickerErrorKind.unknown,
          'Places autocomplete failed on web: $err',
          cause: err,
          stackTrace: stack,
        ),
      );
      return const <Suggestion>[];
    }
  }

  /// Fetches the full [Place] for [placeId] via `Place.fetchFields`.
  ///
  /// This concludes the autocomplete session, exactly as the REST
  /// implementation does.
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

    if (!_isPlacesLibraryLoaded()) {
      mapLogger.w(_missingLibraryMessage);
      onError?.call(
        const MapLocationPickerException(
          MapPickerErrorKind.unsupportedPlatform,
          _missingLibraryMessage,
        ),
      );
      return null;
    }

    try {
      final placeCtorArgs = JSObject();
      placeCtorArgs.setProperty('id'.toJS, placeId.toJS);
      final places = (globalContext.getProperty<JSObject>('google'.toJS))
          .getProperty<JSObject>('maps'.toJS)
          .getProperty<JSObject>('places'.toJS);
      final placeCtor = places.getProperty<JSFunction>('Place'.toJS);
      final jsPlace = placeCtor.callAsConstructor<_JsPlace>(placeCtorArgs);

      final request = JSObject();
      request.setProperty(
        'fields'.toJS,
        <JSString>[
          'id'.toJS,
          'displayName'.toJS,
          'formattedAddress'.toJS,
          'location'.toJS,
          'addressComponents'.toJS,
        ].toJS,
      );
      await jsPlace.fetchFields(request).toDart;

      final place = _toPlace(jsPlace);
      // Also refreshes the session token, concluding the billing session.
      sessionToken?.cachePlaceDetails(id: placeId, data: place);
      _jsSessions.remove(placeId);
      return place;
    } catch (err, stack) {
      mapLogger.e(err, stackTrace: stack);
      onError?.call(
        MapLocationPickerException(
          MapPickerErrorKind.unknown,
          'Place details failed on web: $err',
          cause: err,
          stackTrace: stack,
        ),
      );
      return null;
    }
  }

  Suggestion? _toSuggestion(_JsSuggestion js) {
    final prediction = js.placePrediction;
    if (prediction == null) return null;
    return Suggestion(
      placePrediction: PlacePrediction(
        placeId: prediction.placeId,
        text: FormattableText(text: prediction.text?.text),
        structuredFormat: StructuredFormat(
          mainText: FormattableText(text: prediction.mainText?.text),
          secondaryText: FormattableText(text: prediction.secondaryText?.text),
        ),
      ),
    );
  }

  Place _toPlace(_JsPlace js) {
    final location = js.location;
    return Place(
      id: js.id,
      displayName: LocalizedText(text: js.displayName),
      formattedAddress: js.formattedAddress,
      location: location == null
          ? null
          : LatLng(latitude: location.lat(), longitude: location.lng()),
      addressComponents: js.addressComponents?.toDart
          .map(
            (c) => AddressComponent(
              longText: c.longText,
              shortText: c.shortText,
              types: c.types?.toDart
                  .map((t) => PlaceType.valueOf(t.toDart))
                  .whereType<PlaceType>()
                  .toList(),
            ),
          )
          .toList(),
    );
  }
}

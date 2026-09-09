import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_apis/geocoding.dart';
import 'package:google_maps_apis/places_new.dart' as places;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'configs/map_config.dart';
import 'exceptions.dart';
import 'geocoding_service.dart';
import 'logger.dart';

/// How the picker arrived at its current position.
enum PositionChangeReason {
  /// The position the picker was constructed with.
  initial,

  /// The user tapped the map.
  mapTap,

  /// The user dragged the main marker.
  markerDrag,

  /// The user pressed the "my location" button.
  currentLocation,

  /// The user chose a search suggestion.
  suggestion,

  /// The map came to rest under the centre pin.
  cameraIdle,

  /// The host app called [MapLocationPickerController.moveTo].
  programmatic,
}

/// Drives a [MapLocationPicker] and exposes its state.
///
/// Create one yourself to control the picker from outside the widget tree — to
/// move the pin, re-run the lookup, or read the currently selected address
/// without waiting for a callback:
///
/// ```dart
/// final controller = MapLocationPickerController(
///   config: MapLocationPickerConfig(apiKey: 'YOUR_API_KEY'),
/// );
///
/// MapLocationPicker(config: config, controller: controller);
///
/// // later
/// await controller.moveTo(const LatLng(48.8584, 2.2945));
/// print(controller.address);
/// ```
///
/// When you do not pass one, [MapLocationPicker] creates and disposes its own.
///
/// This is a [ChangeNotifier]; it notifies on every state change, and is safe
/// to use with `ListenableBuilder`/`AnimatedBuilder`.
class MapLocationPickerController extends ChangeNotifier {
  MapLocationPickerConfig _config;
  GeoCodingConfig? _geoCodingOverride;

  /// Creates a controller.
  ///
  /// [geoCodingConfig] overrides the geocoding client derived from [config].
  MapLocationPickerController({
    required MapLocationPickerConfig config,
    GeoCodingConfig? geoCodingConfig,
  }) : _config = config,
       _geoCodingOverride = geoCodingConfig,
       _position = config.initialPosition,
       _mapType = config.initialMapType;

  // --- state ---------------------------------------------------------------

  LatLng _position;
  String _address = '';
  bool _isLoading = false;
  GeocodingResult? _result;
  List<GeocodingResult> _results = const [];
  MapType _mapType;
  MapLocationPickerException? _lastError;
  PositionChangeReason _lastReason = PositionChangeReason.initial;

  /// The currently selected coordinates.
  LatLng get position => _position;

  /// The formatted address for [position], or
  /// [MapLocationPickerConfig.noAddressFoundText] when none was found.
  String get address => _address;

  /// Whether a lookup is in flight.
  bool get isLoading => _isLoading;

  /// The best geocoding result for [position].
  GeocodingResult? get result => _result;

  /// Every geocoding result for [position], best first.
  List<GeocodingResult> get results => _results;

  /// The map type currently displayed.
  MapType get mapType => _mapType;

  /// The most recent failure, or null if the last operation succeeded.
  ///
  /// Cleared at the start of each new operation.
  MapLocationPickerException? get lastError => _lastError;

  /// Why [position] last changed.
  PositionChangeReason get lastPositionChangeReason => _lastReason;

  /// The configuration currently in effect.
  MapLocationPickerConfig get config => _config;

  /// Whether the underlying [GoogleMapController] is available yet.
  bool get isMapReady => _mapControllerCompleter.isCompleted;

  // --- internals -----------------------------------------------------------

  Completer<GoogleMapController> _mapControllerCompleter =
      Completer<GoogleMapController>();

  /// Monotonic id of the newest lookup. A response whose id is stale is
  /// discarded, so a slow earlier request can never overwrite a newer one.
  int _requestId = 0;
  bool _disposed = false;
  GeoCodingConfig? _cachedGeoCoding;
  String? _cachedGeoCodingKey;

  /// How long to wait for the map to become available before giving up.
  ///
  /// Without this, a missing Android API key or a missing Maps JavaScript API
  /// script tag makes every tap hang forever with the spinner stuck on.
  static const Duration mapReadyTimeout = Duration(seconds: 15);

  GeoCodingConfig get _geoCoding {
    if (_geoCodingOverride != null) return _geoCodingOverride!;
    // Keyed on the fields that matter, so `copyWith(apiKey: ...)` is not
    // silently ignored by a cached client.
    final key =
        '${_config.apiKey}|${_config.language}|${_config.geocodingBaseUrl}'
        '|${_config.geocodingLocationType}|${_config.geocodingResultType}';
    if (_cachedGeoCoding != null && _cachedGeoCodingKey == key) {
      return _cachedGeoCoding!;
    }
    _cachedGeoCoding?.dispose();
    _cachedGeoCodingKey = key;
    return _cachedGeoCoding = GeoCodingConfig(
      apiKey: _config.apiKey,
      language: _config.language,
      httpClient: _config.geocodingHttpClient,
      apiHeaders: _config.geocodingApiHeaders,
      baseUrl: _config.geocodingBaseUrl,
      locationType: _config.geocodingLocationType ?? const [],
      resultType: _config.geocodingResultType ?? const [],
      onError: _report,
    );
  }

  /// Replaces the configuration, e.g. when the host widget rebuilds with a new
  /// one. Does not move the pin.
  void updateConfig(
    MapLocationPickerConfig config, {
    GeoCodingConfig? geoCodingConfig,
  }) {
    if (_disposed) return;
    final changed = _config != config || _geoCodingOverride != geoCodingConfig;
    _config = config;
    _geoCodingOverride = geoCodingConfig;
    if (changed) _safeNotify();
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  void _report(MapLocationPickerException error) {
    _lastError = error;
    mapLogger.e(error.message);
    _config.onError?.call(error);
    _safeNotify();
  }

  // --- map wiring ----------------------------------------------------------

  /// Called by [MapLocationPicker] when the platform map view is created.
  ///
  /// Safe to call more than once: Android recreates the platform view on
  /// surface re-attach, and completing a [Completer] twice throws.
  void attachMap(GoogleMapController controller) {
    if (_disposed) return;
    if (_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter = Completer<GoogleMapController>();
    }
    _mapControllerCompleter.complete(controller);
    _config.onMapCreated?.call(controller);
  }

  /// The map controller, once the map has initialised.
  ///
  /// Throws a [MapLocationPickerException] of kind
  /// [MapPickerErrorKind.mapUnavailable] if the map never appears.
  Future<GoogleMapController> get mapController async {
    try {
      return await _mapControllerCompleter.future.timeout(mapReadyTimeout);
    } on TimeoutException catch (e, s) {
      throw MapLocationPickerException(
        MapPickerErrorKind.mapUnavailable,
        'The Google Map never finished initialising. Check that the Maps SDK '
        'API key is configured for this platform.',
        cause: e,
        stackTrace: s,
      );
    }
  }

  /// Changes the displayed map type.
  void setMapType(MapType type) {
    if (_disposed || _mapType == type) return;
    _mapType = type;
    _config.onMapTypeChanged?.call(type);
    _safeNotify();
  }

  // --- actions -------------------------------------------------------------

  /// Moves the pin to [target].
  ///
  /// Set [geocode] false to move without looking up an address, and [animate]
  /// false to jump the camera instead of animating it.
  Future<void> moveTo(
    LatLng target, {
    PositionChangeReason reason = PositionChangeReason.programmatic,
    bool geocode = true,
    bool animate = true,
    double? zoom,
  }) async {
    if (_disposed) return;
    _setPosition(target, reason);

    if (animate || zoom != null) {
      // Camera movement is best-effort: a map that never initialises must not
      // stop the address lookup below.
      unawaited(_moveCamera(target, zoom: zoom, animate: animate));
    }
    if (geocode) await refreshAddress();
  }

  Future<void> _moveCamera(
    LatLng target, {
    double? zoom,
    bool animate = true,
  }) async {
    try {
      final controller = await mapController;
      if (_disposed) return;
      final update = zoom == null
          ? CameraUpdate.newLatLng(target)
          : CameraUpdate.newCameraPosition(
              CameraPosition(target: target, zoom: zoom),
            );
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    } on MapLocationPickerException catch (e) {
      _report(e);
    } catch (e, s) {
      _report(
        MapLocationPickerException(
          MapPickerErrorKind.mapUnavailable,
          'Failed to move the camera: $e',
          cause: e,
          stackTrace: s,
        ),
      );
    }
  }

  void _setPosition(LatLng target, PositionChangeReason reason) {
    if (_position == target && reason != PositionChangeReason.initial) {
      return;
    }
    _position = target;
    _lastReason = reason;
    _config.onMainMarkerPositionChanged?.call(target);
    _safeNotify();
  }

  /// Re-runs reverse geocoding for the current [position].
  ///
  /// Responses are sequenced: if the user taps again while this is in flight,
  /// the older response is discarded rather than overwriting the newer one.
  Future<void> refreshAddress() async {
    if (_disposed) return;
    final requestId = ++_requestId;
    _lastError = null;
    _isLoading = true;
    _safeNotify();

    try {
      final (best, all) = await _geoCoding.reverseGeocode(_position);
      // A newer request superseded this one, or the controller went away.
      if (_disposed || requestId != _requestId) return;

      final chosen = best ?? (all.isNotEmpty ? all.first : null);
      if (chosen != null) {
        _result = chosen;
        _results = all;
        _address = _formatAddress(chosen);
        _config.onAddressDecoded?.call(chosen);
      } else {
        _result = null;
        _results = const [];
        _address = _config.noAddressFoundText;
        mapLogger.i(
          'No address found for $_position. Try a larger radius or relax '
          'geocodingResultType / geocodingLocationType.',
        );
      }
    } catch (e, s) {
      if (_disposed || requestId != _requestId) return;
      _result = null;
      _results = const [];
      _address = _config.noAddressFoundText;
      _report(
        MapLocationPickerException(
          MapPickerErrorKind.unknown,
          'Reverse geocoding failed: $e',
          cause: e,
          stackTrace: s,
        ),
      );
    } finally {
      if (!_disposed && requestId == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  String _formatAddress(GeocodingResult result) {
    final formatted = result.formattedAddress;
    if (formatted != null && formatted.isNotEmpty) return formatted;
    final parts =
        result.addressComponents
            ?.map((c) => c.longName)
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .toList() ??
        const <String>[];
    if (parts.isNotEmpty) return parts.join(', ');
    return _config.noAddressFoundText;
  }

  /// Selects [result] as the current address without moving the map.
  ///
  /// Used by the "places found nearby" sheet.
  void selectResult(GeocodingResult result) {
    if (_disposed) return;
    _result = result;
    _address = _formatAddress(result);
    _config.onAddressSelected?.call(result);
    _safeNotify();
  }

  /// Centres on a place returned by the autocomplete search.
  ///
  /// The [places.Place] already carries a formatted address, so it is used
  /// directly instead of paying for a second reverse-geocode round trip. The
  /// full [GeocodingResult] list is then refreshed in the background so the
  /// "nearby places" sheet still works.
  Future<void> selectPlace(places.Place? place) async {
    if (_disposed || place == null) return;
    final location = place.location;
    final lat = location?.latitude;
    final lng = location?.longitude;
    if (lat == null || lng == null) {
      _report(
        const MapLocationPickerException(
          MapPickerErrorKind.noResults,
          'The selected place has no coordinates.',
        ),
      );
      return;
    }

    final target = LatLng(lat, lng);
    _setPosition(target, PositionChangeReason.suggestion);

    final formatted = place.formattedAddress;
    if (formatted != null && formatted.isNotEmpty) {
      _address = formatted;
      _safeNotify();
    }
    _config.onSuggestionSelected?.call(place);

    unawaited(_moveCamera(target, zoom: _config.initialZoom));
    await refreshAddress();
  }

  /// Moves the pin to the device's current location.
  ///
  /// Every failure path — services off, permission denied, permission denied
  /// forever, timeout — is reported through [MapLocationPickerConfig.onError]
  /// with a distinct [MapPickerErrorKind], instead of returning silently.
  Future<void> goToCurrentLocation() async {
    if (_disposed) return;
    _lastError = null;
    _isLoading = true;
    _safeNotify();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _report(
          const MapLocationPickerException(
            MapPickerErrorKind.locationServiceDisabled,
            'Location services are turned off on this device.',
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _report(
          const MapLocationPickerException(
            MapPickerErrorKind.locationPermissionDeniedForever,
            'Location permission is permanently denied. It can only be granted '
            'from the system settings.',
          ),
        );
        return;
      }
      // The original code used `!=  whileInUse || != always`, which no value can
      // fail, so this branch always returned and the button did nothing.
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        _report(
          const MapLocationPickerException(
            MapPickerErrorKind.locationPermissionDenied,
            'Location permission was denied.',
          ),
        );
        return;
      }

      final current = await Geolocator.getCurrentPosition(
        locationSettings: _config.locationSettings,
      );
      if (_disposed) return;

      await moveTo(
        LatLng(current.latitude, current.longitude),
        reason: PositionChangeReason.currentLocation,
        zoom: _config.initialZoom,
      );
    } on TimeoutException catch (e, s) {
      _report(
        MapLocationPickerException(
          MapPickerErrorKind.locationTimeout,
          'Timed out waiting for a location fix.',
          cause: e,
          stackTrace: s,
        ),
      );
    } catch (e, s) {
      _report(
        MapLocationPickerException(
          MapPickerErrorKind.unknown,
          'Failed to get the current location: $e',
          cause: e,
          stackTrace: s,
        ),
      );
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  /// Confirms the current selection, invoking
  /// [MapLocationPickerConfig.onNext].
  void confirm() {
    if (_disposed) return;
    _config.onNext?.call(_result);
  }

  @override
  void dispose() {
    _disposed = true;
    // Invalidate any in-flight response.
    _requestId++;
    _cachedGeoCoding?.dispose();
    _cachedGeoCoding = null;
    super.dispose();
  }
}

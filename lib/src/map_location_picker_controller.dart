import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_apis/geocoding.dart';
import 'package:google_maps_apis/places_new.dart' as places;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'configs/enums.dart';
import 'debouncer.dart';
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
  /// It is *not* disposed with the controller -- an injected client may outlive
  /// one picker, so you own its lifetime.
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
  PinState _pinState = PinState.preparing;
  List<places.Place> _nearbyPlaces = const [];
  places.Place? _lastSelectedPlace;
  bool _isLoadingNearby = false;

  /// The currently selected coordinates.
  LatLng get position => _position;

  /// The formatted address for [position], or
  /// [MapLocationPickerStrings.noAddressFound] when none was found.
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

  /// The state of the centre pin in [PickerPinMode.centerPin].
  PinState get pinState => _pinState;

  /// The [places.Place] most recently chosen from the search results.
  ///
  /// Kept so the human-readable name survives into the final result —
  /// reverse-geocoding a point of interest returns its street address, which
  /// loses "Heathrow Terminal 5". Cleared as soon as the pin moves for any
  /// other reason.
  places.Place? get lastSelectedPlace => _lastSelectedPlace;

  /// Places near [position], when
  /// [MapLocationPickerConfig.showNearbyPlaces] is on.
  List<places.Place> get nearbyPlaces => _nearbyPlaces;

  /// Whether the nearby-places lookup is in flight.
  bool get isLoadingNearbyPlaces => _isLoadingNearby;

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

  /// Superseded geocoding clients, disposed once nothing is in flight.
  ///
  /// Closing one inline would abort a request still using it and surface the
  /// abort as a spurious network failure.
  final List<GeoCodingConfig> _retiredGeoCoding = [];

  /// Nearby search owns its own sequence, so a superseded nearby response
  /// cannot clear the loading flag of a newer one.
  int _nearbyRequestId = 0;
  bool _initialised = false;

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
    final cached = _cachedGeoCoding;
    if (cached != null &&
        _cachedGeoCodingKey == key &&
        identical(cached.httpClient, _config.geocodingHttpClient) &&
        mapEquals(cached.apiHeaders, _config.geocodingApiHeaders)) {
      return cached;
    }
    // Retire rather than dispose: closing the client now would abort a request
    // that is still in flight and surface the abort as a network failure.
    if (cached != null) _retiredGeoCoding.add(cached);
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

  /// The "nothing found here" label.
  ///
  /// `MapLocationPickerConfig.noAddressFoundText` is the deprecated override;
  /// when it is null the localized [MapLocationPickerStrings.noAddressFound]
  /// applies.
  String get _noAddressText =>
      // ignore: deprecated_member_use_from_same_package
      _config.noAddressFoundText ?? _config.strings.noAddressFound;

  void _report(
    MapLocationPickerException error, {
    bool legacyLocation = false,
  }) {
    // A request aborted *by* dispose() would otherwise call back into a host
    // that has already torn down the route it would report on.
    if (_disposed) return;
    _lastError = error;
    mapLogger.e(error.message);
    if (legacyLocation) {
      // 3.x reported location failures here, and handed over the raw thrown
      // object rather than a typed exception.
      // ignore: deprecated_member_use_from_same_package
      _config.onLocationError?.call(error.cause ?? error);
    }
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
    if (_pinState == PinState.preparing) _pinState = PinState.idle;
    _config.onMapCreated?.call(controller);
    _safeNotify();
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

  /// Call when the camera starts moving.
  ///
  /// In [PickerPinMode.centerPin] this lifts the pin to signal dragging.
  void onCameraMoveStarted() {
    if (_disposed || _config.pinMode != PickerPinMode.centerPin) return;
    if (_pinState == PinState.dragging) return;
    _pinState = PinState.dragging;
    _safeNotify();
  }

  /// Call on every camera frame. Only the latest target is retained.
  void onCameraMove(CameraPosition camera) {
    if (_disposed) return;
    _pendingCameraTarget = camera.target;
  }

  /// Call when the camera comes to rest.
  ///
  /// In [PickerPinMode.centerPin] this is what commits the selection: the
  /// point under the pin becomes the picked position and is geocoded.
  Future<void> onCameraIdle() async {
    if (_disposed) return;
    if (_config.pinMode != PickerPinMode.centerPin) return;
    _pinState = PinState.idle;
    final target = _pendingCameraTarget;
    final settleTarget = _awaitingSettleAt;
    _awaitingSettleAt = null; // only the next idle is excused
    if (target == null || target == _position) {
      _safeNotify();
      return;
    }
    if (settleTarget != null && _isSameSpot(target, settleTarget)) {
      // The map settled where we asked it to. Treating that as a user pan
      // would clear lastSelectedPlace (losing the POI name) and pay for a
      // second geocode of a point we just geocoded.
      _safeNotify();
      return;
    }
    _setPosition(target, PositionChangeReason.cameraIdle);
    // The lookup below is only *scheduled*. Without marking it in flight now,
    // the card would keep showing the previous point's address with an enabled
    // confirm button for the whole debounce window -- so confirming inside it
    // returned the new coordinates paired with the old address.
    _isLoading = true;
    _result = null;
    _results = const [];
    _safeNotify();
    // Android reports idle more than once as a fling settles, and each one
    // would otherwise be a billed geocode.
    if (_idleDebouncer == null ||
        _idleDebounceDuration != _config.pinIdleDebounce) {
      _idleDebouncer?.dispose();
      _idleDebounceDuration = _config.pinIdleDebounce;
      _idleDebouncer = DeBouncer(duration: _idleDebounceDuration!);
    }
    _idleDebouncer!.run(() {
      if (!_disposed) refreshAddress();
    });
  }

  LatLng? _pendingCameraTarget;

  /// Target of an in-flight programmatic camera move, so the resulting idle is
  /// not mistaken for the user panning.
  LatLng? _awaitingSettleAt;

  /// ~1e-5 degrees is about a metre: well under any deliberate pan, well over
  /// the rounding the platform applies to camera targets.
  static bool _isSameSpot(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < 1e-5 &&
      (a.longitude - b.longitude).abs() < 1e-5;

  DeBouncer? _idleDebouncer;
  Duration? _idleDebounceDuration;

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

    // Camera movement is best-effort: a map that never initialises must not
    // stop the address lookup below.
    unawaited(_moveCamera(target, zoom: zoom, animate: animate));
    if (geocode) await refreshAddress();
  }

  Future<void> _moveCamera(
    LatLng target, {
    double? zoom,
    bool animate = true,
  }) async {
    _awaitingSettleAt = target;
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
    if (reason != PositionChangeReason.suggestion) _lastSelectedPlace = null;
    _position = target;
    _lastReason = reason;
    // Chips for the previous neighbourhood must not stay rendered and
    // tappable -- tapping one would yank the pin back.
    if (_config.showNearbyPlaces) _nearbyPlaces = const [];
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
      final (best, all) = await _geoCoding.reverseGeocode(
        _position,
        // Route failures through the same sequencing the results get: a
        // superseded request must not report an error for a lookup the user
        // already abandoned.
        onErrorOverride: (e) {
          if (_disposed || requestId != _requestId) return;
          _report(e);
        },
      );
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
        _address = _noAddressText;
        mapLogger.i(
          'No address found for $_position. Try a larger radius or relax '
          'geocodingResultType / geocodingLocationType.',
        );
      }
    } catch (e, s) {
      if (_disposed || requestId != _requestId) return;
      _result = null;
      _results = const [];
      _address = _noAddressText;
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
        _drainRetiredGeoCoding();
        _safeNotify();
        if (_config.showNearbyPlaces) unawaited(refreshNearbyPlaces());
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
    return _noAddressText;
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
  /// The place's own address is shown immediately as an optimistic label, then
  /// a reverse geocode runs and supersedes it -- that second lookup is what
  /// populates [result] and [results] for the matching-addresses sheet, so it
  /// is not skippable. [lastSelectedPlace] keeps the place's display name, and
  /// [PickedPlace.name] is built from it.
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
    _lastSelectedPlace = place;
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
    final requestId = _requestId;
    _lastError = null;
    _isLoading = true;
    _safeNotify();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _report(
          legacyLocation: true,
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
          legacyLocation: true,
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
          legacyLocation: true,
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
        legacyLocation: true,
        MapLocationPickerException(
          MapPickerErrorKind.locationTimeout,
          'Timed out waiting for a location fix.',
          cause: e,
          stackTrace: s,
        ),
      );
    } catch (e, s) {
      _report(
        legacyLocation: true,
        MapLocationPickerException(
          MapPickerErrorKind.unknown,
          'Failed to get the current location: $e',
          cause: e,
          stackTrace: s,
        ),
      );
    } finally {
      // Only clear the flag if no lookup was started in the meantime:
      // `moveTo` delegates to `refreshAddress`, which owns the flag from that
      // point on. Clearing it here would stop the spinner while the newer
      // lookup is still in flight.
      if (!_disposed && requestId == _requestId) {
        _isLoading = false;
        _safeNotify();
      }
    }
  }

  /// Resolves the device location and centres on it.
  ///
  /// Used for [MapLocationPickerConfig.startWithCurrentLocation]. Unlike
  /// [goToCurrentLocation] this never surfaces a permission failure as an
  /// error: opening the picker should not nag, so it quietly falls back to
  /// [MapLocationPickerConfig.initialPosition].
  /// Runs once per controller. Pass `force: true` to re-resolve, e.g. when
  /// reopening the picker on a different address with a controller you own.
  Future<void> initialise({bool force = false}) async {
    if (_disposed) return;
    // A caller-supplied controller outlives the widget, so a remount
    // (TabBarView, PageView, a conditional subtree) must not re-run this:
    // it costs a billed geocode and, with startWithCurrentLocation, would
    // discard the point the user had already chosen.
    if (_initialised && !force) return;
    _initialised = true; // set before awaiting so overlapping calls collapse
    if (_config.startWithCurrentLocation) {
      final located = await _tryCurrentPosition();
      if (_disposed) return;
      if (located != null) {
        await moveTo(
          located,
          reason: PositionChangeReason.currentLocation,
          zoom: _config.initialZoom,
        );
        return;
      }
    }
    if (!_config.skipInitialGeocode) await refreshAddress();
  }

  Future<LatLng?> _tryCurrentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return null;
      }
      final current = await Geolocator.getCurrentPosition(
        locationSettings: _config.locationSettings,
      ).timeout(_config.locationTimeout);
      return LatLng(current.latitude, current.longitude);
    } on TimeoutException {
      // A cold GPS fix can take longer than anyone wants to stare at a
      // spinner. Fall back to the last known position rather than blocking.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return LatLng(last.latitude, last.longitude);
      } catch (_) {
        // ignore
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Looks up places near [position].
  ///
  /// Uses the Places API (New) `searchNearby` endpoint. Called automatically
  /// when [MapLocationPickerConfig.showNearbyPlaces] is on.
  Future<void> refreshNearbyPlaces() async {
    if (_disposed || !_config.showNearbyPlaces) return;
    final nearbyId = ++_nearbyRequestId; // owns the loading flag
    final addressId = _requestId; // detects a moved pin
    _isLoadingNearby = true;
    _safeNotify();
    try {
      final api =
          _config.placesApi ?? places.PlacesAPINew(apiKey: _config.apiKey);
      final response = await api.searchNearby(
        fields: const [
          'places.id',
          'places.displayName',
          'places.formattedAddress',
          'places.location',
          'places.types',
        ],
        filter: places.NearbySearchFilter(
          maxResultCount: _config.nearbyPlacesLimit,
          includedTypes: _config.nearbyPlaceTypes,
          languageCode: _config.language,
          locationRestriction: places.LocationRestrictionCircle(
            circle: places.Circle(
              center: places.ReferencePoint(
                latitude: _position.latitude,
                longitude: _position.longitude,
              ),
              radius: _config.nearbyPlacesRadius,
            ),
          ),
        ),
      );
      if (_disposed ||
          nearbyId != _nearbyRequestId ||
          addressId != _requestId) {
        return;
      }
      if (response.error != null && !response.isSuccessful) {
        _report(
          MapLocationPickerException(
            mapPickerErrorKindFromStatus(response.statusCode),
            response.error?.error?.message ?? 'Nearby search failed',
            statusCode: response.statusCode,
          ),
        );
        _nearbyPlaces = const [];
        return;
      }
      _nearbyPlaces = response.body?.places ?? const [];
    } catch (e, s) {
      if (_disposed ||
          nearbyId != _nearbyRequestId ||
          addressId != _requestId) {
        return;
      }
      _nearbyPlaces = const [];
      _report(
        MapLocationPickerException(
          MapPickerErrorKind.unknown,
          'Nearby search failed: $e',
          cause: e,
          stackTrace: s,
        ),
      );
    } finally {
      if (!_disposed && nearbyId == _nearbyRequestId) {
        _isLoadingNearby = false;
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

  void _drainRetiredGeoCoding() {
    if (_retiredGeoCoding.isEmpty) return;
    for (final client in _retiredGeoCoding) {
      client.dispose();
    }
    _retiredGeoCoding.clear();
  }

  @override
  void dispose() {
    _disposed = true;
    // Invalidate any in-flight response.
    _requestId++;
    _nearbyRequestId++;
    // Settle the map future so a pending `mapController` await resolves now
    // instead of holding a 15s timer past teardown.
    if (!_mapControllerCompleter.isCompleted) {
      _mapControllerCompleter.completeError(
        const MapLocationPickerException(
          MapPickerErrorKind.mapUnavailable,
          'The controller was disposed before the map initialised.',
        ),
      );
      _mapControllerCompleter.future.ignore();
    }
    _idleDebouncer?.dispose();
    _drainRetiredGeoCoding();
    // Only the client this controller derived from the config -- an injected
    // `geoCodingConfig` belongs to the caller.
    _cachedGeoCoding?.dispose();
    _cachedGeoCoding = null;
    super.dispose();
  }
}

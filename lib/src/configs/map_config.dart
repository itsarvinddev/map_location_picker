import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:map_location_picker/map_location_picker.dart';

part 'map_config.freezed.dart';

typedef SearchBarBuilder =
    Widget Function(BuildContext context, Widget searchBar)?;
typedef ConfirmButtonBuilder =
    Widget Function(BuildContext context, VoidCallback onNext)?;
typedef BottomCardBuilder =
    Widget Function(
      BuildContext context,
      GeocodingResult? place,
      List<GeocodingResult> places,
      String formattedAddress,
      bool isLoading,
      VoidCallback onPlaceSelected,
      Widget searchBar,
    )?;

@freezed
abstract class MapLocationPickerConfig with _$MapLocationPickerConfig {
  const factory MapLocationPickerConfig({
    // Core configuration
    @Default('') String apiKey,
    @Default(null) String? language,
    @Default(null) PlacesAPINew? placesApi,
    @Default(null) http.Client? geocodingHttpClient,
    @Default(null) Map<String, String>? geocodingApiHeaders,
    @Default(null) String? geocodingBaseUrl,
    @Default(null) List<String>? geocodingLocationType,
    @Default(null) List<String>? geocodingResultType,
    @Default(LatLng(28.8993468, 76.6250249)) LatLng initialPosition,
    @Default(14.0) double initialZoom,
    @Default(MapType.normal) MapType initialMapType,
    @Default(false) bool myLocationButtonEnabled,
    @Default(false) bool myLocationEnabled,
    @Default(false) bool zoomControlsEnabled,
    @Default(MinMaxZoomPreference.unbounded)
    MinMaxZoomPreference minMaxZoomPreference,
    @Default(null) void Function(CameraPosition)? onCameraMove,
    @Default(EdgeInsets.zero) EdgeInsets padding,
    @Default(true) bool compassEnabled,
    @Default(false) bool liteModeEnabled,
    @Default(null) String? mapStyle,
    @Default(null) Color? floatingControlsColor,
    @Default(null) Color? floatingControlsIconColor,
    @Default(null) IconData? mapTypeIcon,
    @Default(null) IconData? locationIcon,
    @Default(null) BitmapDescriptor? mainMarkerIcon,
    @Default(true) bool hideBottomCardOnKeyboard,

    /// Title shown above the address in the default bottom card.
    ///
    /// Leave empty to hide it.
    @Default('') String bottomCardTitle,

    /// Superseded by [cardType], which is what the widgets actually read.
    @Deprecated(
      'bottomCardType was never read. Use cardType instead. '
      'Will be removed in map_location_picker 5.0.0.',
    )
    @Default(CardType.defaultCard)
    CardType bottomCardType,
    @Default(null) ConfirmButtonBuilder confirmButton,
    @Default(null) BottomCardBuilder bottomCardBuilder,

    /// Wraps or replaces the search bar.
    ///
    /// The returned widget is placed **directly** in the picker's [Stack], so
    /// return a [Positioned] (or it will be stretched by `StackFit.expand`).
    /// The `searchBar` handed to you already carries the web pointer
    /// interceptor.
    @Default(null) SearchBarBuilder searchBarBuilder,
    @Default(null) LocationSettings? locationSettings,

    /// Superseded by [onError], which reports a typed
    /// [MapLocationPickerException] for every failure, not just location ones.
    ///
    /// Still invoked for current-location failures, with the raw thrown object
    /// as 3.x did.
    @Deprecated(
      'Use onError instead, which reports a typed MapLocationPickerException. '
      'Will be removed in map_location_picker 5.0.0.',
    )
    @Default(null)
    Function(dynamic error)? onLocationError,
    @Default(false) bool hideMoreOptions,
    @Default(null) Widget? mapTypeButton,
    @Default(null) Widget? locationButton,
    @Default('My Location') String fabTooltip,
    @Default(null) Map<String, LatLng>? additionalMarkers,
    @Default(null) Map<String, BitmapDescriptor>? customMarkerIcons,
    @Default(null) Map<String, InfoWindow>? customInfoWindows,
    @Default(null) Map<String, VoidCallback>? onMarkerTapped,
    @Default(null) Function(GoogleMapController)? onMapCreated,
    @Default(null) Function(MapType)? onMapTypeChanged,
    @Default(null) Function(Place?)? onSuggestionSelected,
    @Default(null) Function(GeocodingResult?)? onNext,

    /// Called whenever the main marker moves, for any reason: a map tap, a
    /// marker drag, the "my location" button, a chosen suggestion, or
    /// [MapLocationPickerController.moveTo].
    @Default(null) ValueChanged<LatLng>? onMainMarkerPositionChanged,

    /// Called for every failure the picker produces.
    ///
    /// Switch on [MapLocationPickerException.kind] to tell an invalid API key
    /// from an exceeded quota from "no results here" — distinctions the
    /// package used to collapse into a silent empty state.
    @Default(null) MapPickerErrorCallback? onError,

    /// Whether the confirm button requires a successfully geocoded address.
    ///
    /// When false (the default), the user can confirm a raw coordinate even if
    /// the Geocoding API returned nothing — a bad key, an exceeded quota or a
    /// point over water no longer leaves them with a dead button and no way
    /// out. [PickedPlace.latLng] is always populated.
    @Default(false) bool requireGeocodedAddress,

    /// Whether the main marker can be dragged to fine-tune the selection.
    @Default(true) bool draggableMarker,

    /// Every user-visible string, so the picker can be translated.
    @Default(MapLocationPickerStrings()) MapLocationPickerStrings strings,

    /// Skips the reverse-geocode that normally runs on first build.
    ///
    /// Set this when [initialPosition] is a placeholder and you intend to move
    /// the pin yourself. Previously `LatLng(0, 0)` was treated as a magic
    /// "unset" sentinel, which left anyone genuinely picking a point in the
    /// Gulf of Guinea with a marker-less, address-less picker.
    @Default(false) bool skipInitialGeocode,

    /// Whether the search bar is rendered.
    ///
    /// Set false when you render the search bar yourself from the `searchBar`
    /// argument of [bottomCardBuilder]; otherwise two live search fields end
    /// up sharing one [SearchConfig.suggestionsController].
    @Default(true) bool showSearchBar,

    /// Whether the map-type button is rendered.
    @Default(true) bool showMapTypeButton,

    /// Whether the "my location" button is rendered.
    @Default(true) bool showMyLocationButton,

    /// How the user picks a point.
    ///
    /// [PickerPinMode.marker] drops a marker where the map is tapped.
    /// [PickerPinMode.centerPin] fixes a pin at the centre of the screen and
    /// pans the map underneath it, resolving the address when the map comes to
    /// rest — the interaction used by most ride-hailing and delivery apps.
    @Default(PickerPinMode.marker) PickerPinMode pinMode,

    /// The widget drawn at the screen centre in [PickerPinMode.centerPin].
    ///
    /// Receives the current [PinState] so it can react to dragging.
    @Default(null) Widget Function(BuildContext, PinState)? centerPinBuilder,

    /// Whether tapping the map moves the pin.
    @Default(true) bool tapToSelect,

    /// Resolves the device's location when the picker opens, instead of
    /// starting at [initialPosition].
    ///
    /// Falls back to [initialPosition] if permission is refused or no fix is
    /// available, so the picker is never left blank.
    @Default(false) bool startWithCurrentLocation,

    /// How long to wait for the initial location fix before falling back.
    @Default(Duration(seconds: 10)) Duration locationTimeout,

    /// Whether to show a back button over the map.
    @Default(false) bool showBackButton,

    /// Builds the back button. Defaults to a circular icon button that pops
    /// the current route.
    @Default(null) Widget Function(BuildContext)? backButtonBuilder,

    /// Where the floating controls sit inside the picker.
    @Default(FloatingControlsPosition.bottomEnd)
    FloatingControlsPosition floatingControlsPosition,

    /// Restricts autocomplete results to these ISO 3166-1 alpha-2 country
    /// codes, e.g. `['us', 'ca']`. Up to 15.
    ///
    /// The README documented this for years without it existing.
    @Default(null) List<String>? countries,

    /// Restricts autocomplete results to these Places types, e.g.
    /// `[PlaceType.restaurant]`. Up to 5.
    @Default(null) List<PlaceType>? placeTypes,

    /// Shows a list of places near the selected point under the address card.
    @Default(false) bool showNearbyPlaces,

    /// How many nearby places to request. Google caps this at 20.
    @Default(6) int nearbyPlacesLimit,

    /// Restricts nearby places to these Places types.
    @Default(null) List<PlaceType>? nearbyPlaceTypes,

    /// Radius in metres for the nearby-places search.
    @Default(500.0) double nearbyPlacesRadius,

    /// Bottom inset applied to the map so the Google logo and the "terms"
    /// link stay visible above the bottom card.
    ///
    /// Keeping the logo unobscured is a Google Maps Platform terms requirement.
    /// Ignored when [padding] is set to something other than [EdgeInsets.zero].
    @Default(96.0) double mapBottomInset,
    @Default(null) Function(GeocodingResult?)? onAddressDecoded,
    @Default(null) Function(GeocodingResult)? onAddressSelected,
    @Default(true) bool buildingsEnabled,
    @Default(CameraTargetBounds.unbounded)
    CameraTargetBounds cameraTargetBounds,
    @Default(<Circle>{}) Set<Circle> circles,

    /// A cloud-based map style id.
    ///
    /// Forwarded to `GoogleMap.cloudMapId`. `GoogleMap.mapId` supersedes it
    /// from google_maps_flutter 2.15, but this package's dependency range
    /// reaches back to 2.13.1, where `mapId` does not exist.
    @Default(null) String? cloudMapId,

    /// Hero tag for the map-type button. Set this when two pickers can be in
    /// the same route (a TabBarView, an IndexedStack) -- Flutter throws when
    /// two heroes share a tag.
    @Default('map_location_picker_map_type') Object? mapTypeButtonHeroTag,

    /// Hero tag for the "my location" button. See [mapTypeButtonHeroTag].
    @Default('map_location_picker_my_location') Object? locationButtonHeroTag,

    /// How long the map must sit still before the centre pin commits a
    /// selection, in [PickerPinMode.centerPin].
    ///
    /// Android fires `onCameraIdle` more than once as a fling settles; without
    /// this you pay for several geocodes per gesture.
    @Default(Duration(milliseconds: 350)) Duration pinIdleDebounce,
    @Default(false) bool fortyFiveDegreeImageryEnabled,
    @Default(<Factory<OneSequenceGestureRecognizer>>{})
    Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
    @Default(false) bool indoorViewEnabled,
    @Default(null) TextDirection? layoutDirection,
    @Default(true) bool mapToolbarEnabled,
    @Default(null) VoidCallback? onCameraIdle,
    @Default(null) VoidCallback? onCameraMoveStarted,
    @Default(null) ArgumentCallback<LatLng>? onLongPress,
    @Default(<Polygon>{}) Set<Polygon> polygons,
    @Default(<Polyline>{}) Set<Polyline> polylines,
    @Default(true) bool rotateGesturesEnabled,
    @Default(true) bool scrollGesturesEnabled,
    @Default(<TileOverlay>{}) Set<TileOverlay> tileOverlays,
    @Default(true) bool tiltGesturesEnabled,
    @Default(false) bool trafficEnabled,
    @Default(null) WebGestureHandling? webGestureHandling,
    @Default(true) bool zoomGesturesEnabled,
    @Default(<ClusterManager>{}) Set<ClusterManager> clusterManagers,
    @Default(<GroundOverlay>{}) Set<GroundOverlay> groundOverlays,
    @Default(<Heatmap>{}) Set<Heatmap> heatmaps,
    @Default(CardType.defaultCard) CardType cardType,
    @Default(null) Color? cardColor,
    @Default(null) BorderRadiusGeometry? cardRadius,
    @Default(null) BoxBorder? cardBorder,

    /// Superseded by [MapLocationPickerStrings.noAddressFound].
    ///
    /// When null (the default) the localized string is used. An explicit value
    /// still wins, so existing callers are unaffected.
    @Deprecated(
      'Use strings.noAddressFound instead, which is localizable. '
      'Will be removed in map_location_picker 5.0.0.',
    )
    @Default(null)
    String? noAddressFoundText,
  }) = _MapLocationPickerConfig;
}

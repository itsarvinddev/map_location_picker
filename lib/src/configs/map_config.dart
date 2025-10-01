import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_apis/places_new.dart' hide LatLng, Circle;
import 'package:map_location_picker/map_location_picker.dart';

part 'map_config.freezed.dart';

typedef SearchBarBuilder = Widget Function(
  BuildContext context,
  Widget searchBar,
)?;
typedef ConfirmButtonBuilder = Widget Function(
  BuildContext context,
  VoidCallback onNext,
)?;
typedef BottomCardBuilder = Widget Function(
  BuildContext context,
  Place? place,
  List<Place> places,
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
    @Default(null) PlacesAPINew? placesApi,
    @Default(500) double geocodingRadius,
    @Default(true) bool geocodingAllFields,
    @Default(null) List<String>? geocodingFields,
    @Default(null) PlacesResponse? geocodingInstanceFields,
    @Default(null) NearbySearchFilter? geocodingFilter,
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
    @Default('Select your location') String bottomCardTitle,
    @Default(CardType.defaultCard) CardType bottomCardType,
    @Default(null) ConfirmButtonBuilder confirmButton,
    @Default(null) BottomCardBuilder bottomCardBuilder,
    @Default(null) SearchBarBuilder searchBarBuilder,
    @Default(null) LocationSettings? locationSettings,
    @Default(null) Function(dynamic error)? onLocationError,
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
    @Default(null) Function(Place?)? onNext,
    @Default(null) Function(Place?)? onAddressDecoded,
    @Default(null) Function(Place)? onAddressSelected,
    @Default(true) bool buildingsEnabled,
    @Default(CameraTargetBounds.unbounded)
    CameraTargetBounds cameraTargetBounds,
    @Default(<Circle>{}) Set<Circle> circles,
    @Default(null) String? cloudMapId,
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
    @Default("No address found") String noAddressFoundText,
  }) = _MapLocationPickerConfig;
}

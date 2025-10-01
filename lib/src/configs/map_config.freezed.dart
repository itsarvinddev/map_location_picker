// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MapLocationPickerConfig {
// Core configuration
  String get apiKey;
  PlacesAPINew? get placesApi;
  double get geocodingRadius;
  bool get geocodingAllFields;
  List<String>? get geocodingFields;
  PlacesResponse? get geocodingInstanceFields;
  NearbySearchFilter? get geocodingFilter;
  LatLng get initialPosition;
  double get initialZoom;
  MapType get initialMapType;
  bool get myLocationButtonEnabled;
  bool get myLocationEnabled;
  bool get zoomControlsEnabled;
  MinMaxZoomPreference get minMaxZoomPreference;
  void Function(CameraPosition)? get onCameraMove;
  EdgeInsets get padding;
  bool get compassEnabled;
  bool get liteModeEnabled;
  String? get mapStyle;
  Color? get floatingControlsColor;
  Color? get floatingControlsIconColor;
  IconData? get mapTypeIcon;
  IconData? get locationIcon;
  BitmapDescriptor? get mainMarkerIcon;
  bool get hideBottomCardOnKeyboard;
  String get bottomCardTitle;
  CardType get bottomCardType;
  ConfirmButtonBuilder get confirmButton;
  BottomCardBuilder get bottomCardBuilder;
  SearchBarBuilder get searchBarBuilder;
  LocationSettings? get locationSettings;
  Function(dynamic error)? get onLocationError;
  bool get hideMoreOptions;
  Widget? get mapTypeButton;
  Widget? get locationButton;
  String get fabTooltip;
  Map<String, LatLng>? get additionalMarkers;
  Map<String, BitmapDescriptor>? get customMarkerIcons;
  Map<String, InfoWindow>? get customInfoWindows;
  Map<String, VoidCallback>? get onMarkerTapped;
  Function(GoogleMapController)? get onMapCreated;
  Function(MapType)? get onMapTypeChanged;
  Function(Place?)? get onSuggestionSelected;
  Function(Place?)? get onNext;
  Function(Place?)? get onAddressDecoded;
  Function(Place)? get onAddressSelected;
  bool get buildingsEnabled;
  CameraTargetBounds get cameraTargetBounds;
  Set<Circle> get circles;
  String? get cloudMapId;
  bool get fortyFiveDegreeImageryEnabled;
  Set<Factory<OneSequenceGestureRecognizer>> get gestureRecognizers;
  bool get indoorViewEnabled;
  TextDirection? get layoutDirection;
  bool get mapToolbarEnabled;
  VoidCallback? get onCameraIdle;
  VoidCallback? get onCameraMoveStarted;
  ArgumentCallback<LatLng>? get onLongPress;
  Set<Polygon> get polygons;
  Set<Polyline> get polylines;
  bool get rotateGesturesEnabled;
  bool get scrollGesturesEnabled;
  Set<TileOverlay> get tileOverlays;
  bool get tiltGesturesEnabled;
  bool get trafficEnabled;
  WebGestureHandling? get webGestureHandling;
  bool get zoomGesturesEnabled;
  Set<ClusterManager> get clusterManagers;
  Set<GroundOverlay> get groundOverlays;
  Set<Heatmap> get heatmaps;
  CardType get cardType;
  Color? get cardColor;
  BorderRadiusGeometry? get cardRadius;
  BoxBorder? get cardBorder;
  String get noAddressFoundText;

  /// Create a copy of MapLocationPickerConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MapLocationPickerConfigCopyWith<MapLocationPickerConfig> get copyWith =>
      _$MapLocationPickerConfigCopyWithImpl<MapLocationPickerConfig>(
          this as MapLocationPickerConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MapLocationPickerConfig &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            const DeepCollectionEquality().equals(other.placesApi, placesApi) &&
            (identical(other.geocodingRadius, geocodingRadius) ||
                other.geocodingRadius == geocodingRadius) &&
            (identical(other.geocodingAllFields, geocodingAllFields) ||
                other.geocodingAllFields == geocodingAllFields) &&
            const DeepCollectionEquality()
                .equals(other.geocodingFields, geocodingFields) &&
            const DeepCollectionEquality().equals(
                other.geocodingInstanceFields, geocodingInstanceFields) &&
            const DeepCollectionEquality()
                .equals(other.geocodingFilter, geocodingFilter) &&
            (identical(other.initialPosition, initialPosition) ||
                other.initialPosition == initialPosition) &&
            (identical(other.initialZoom, initialZoom) ||
                other.initialZoom == initialZoom) &&
            (identical(other.initialMapType, initialMapType) ||
                other.initialMapType == initialMapType) &&
            (identical(other.myLocationButtonEnabled, myLocationButtonEnabled) ||
                other.myLocationButtonEnabled == myLocationButtonEnabled) &&
            (identical(other.myLocationEnabled, myLocationEnabled) ||
                other.myLocationEnabled == myLocationEnabled) &&
            (identical(other.zoomControlsEnabled, zoomControlsEnabled) ||
                other.zoomControlsEnabled == zoomControlsEnabled) &&
            (identical(other.minMaxZoomPreference, minMaxZoomPreference) ||
                other.minMaxZoomPreference == minMaxZoomPreference) &&
            (identical(other.onCameraMove, onCameraMove) ||
                other.onCameraMove == onCameraMove) &&
            (identical(other.padding, padding) || other.padding == padding) &&
            (identical(other.compassEnabled, compassEnabled) ||
                other.compassEnabled == compassEnabled) &&
            (identical(other.liteModeEnabled, liteModeEnabled) ||
                other.liteModeEnabled == liteModeEnabled) &&
            (identical(other.mapStyle, mapStyle) ||
                other.mapStyle == mapStyle) &&
            (identical(other.floatingControlsColor, floatingControlsColor) ||
                other.floatingControlsColor == floatingControlsColor) &&
            (identical(other.floatingControlsIconColor, floatingControlsIconColor) ||
                other.floatingControlsIconColor == floatingControlsIconColor) &&
            (identical(other.mapTypeIcon, mapTypeIcon) ||
                other.mapTypeIcon == mapTypeIcon) &&
            (identical(other.locationIcon, locationIcon) ||
                other.locationIcon == locationIcon) &&
            (identical(other.mainMarkerIcon, mainMarkerIcon) ||
                other.mainMarkerIcon == mainMarkerIcon) &&
            (identical(other.hideBottomCardOnKeyboard, hideBottomCardOnKeyboard) ||
                other.hideBottomCardOnKeyboard == hideBottomCardOnKeyboard) &&
            (identical(other.bottomCardTitle, bottomCardTitle) ||
                other.bottomCardTitle == bottomCardTitle) &&
            (identical(other.bottomCardType, bottomCardType) ||
                other.bottomCardType == bottomCardType) &&
            (identical(other.confirmButton, confirmButton) ||
                other.confirmButton == confirmButton) &&
            (identical(other.bottomCardBuilder, bottomCardBuilder) ||
                other.bottomCardBuilder == bottomCardBuilder) &&
            (identical(other.searchBarBuilder, searchBarBuilder) ||
                other.searchBarBuilder == searchBarBuilder) &&
            (identical(other.locationSettings, locationSettings) ||
                other.locationSettings == locationSettings) &&
            (identical(other.onLocationError, onLocationError) ||
                other.onLocationError == onLocationError) &&
            (identical(other.hideMoreOptions, hideMoreOptions) ||
                other.hideMoreOptions == hideMoreOptions) &&
            (identical(other.mapTypeButton, mapTypeButton) ||
                other.mapTypeButton == mapTypeButton) &&
            (identical(other.locationButton, locationButton) || other.locationButton == locationButton) &&
            (identical(other.fabTooltip, fabTooltip) || other.fabTooltip == fabTooltip) &&
            const DeepCollectionEquality().equals(other.additionalMarkers, additionalMarkers) &&
            const DeepCollectionEquality().equals(other.customMarkerIcons, customMarkerIcons) &&
            const DeepCollectionEquality().equals(other.customInfoWindows, customInfoWindows) &&
            const DeepCollectionEquality().equals(other.onMarkerTapped, onMarkerTapped) &&
            (identical(other.onMapCreated, onMapCreated) || other.onMapCreated == onMapCreated) &&
            (identical(other.onMapTypeChanged, onMapTypeChanged) || other.onMapTypeChanged == onMapTypeChanged) &&
            (identical(other.onSuggestionSelected, onSuggestionSelected) || other.onSuggestionSelected == onSuggestionSelected) &&
            (identical(other.onNext, onNext) || other.onNext == onNext) &&
            (identical(other.onAddressDecoded, onAddressDecoded) || other.onAddressDecoded == onAddressDecoded) &&
            (identical(other.onAddressSelected, onAddressSelected) || other.onAddressSelected == onAddressSelected) &&
            (identical(other.buildingsEnabled, buildingsEnabled) || other.buildingsEnabled == buildingsEnabled) &&
            (identical(other.cameraTargetBounds, cameraTargetBounds) || other.cameraTargetBounds == cameraTargetBounds) &&
            const DeepCollectionEquality().equals(other.circles, circles) &&
            (identical(other.cloudMapId, cloudMapId) || other.cloudMapId == cloudMapId) &&
            (identical(other.fortyFiveDegreeImageryEnabled, fortyFiveDegreeImageryEnabled) || other.fortyFiveDegreeImageryEnabled == fortyFiveDegreeImageryEnabled) &&
            const DeepCollectionEquality().equals(other.gestureRecognizers, gestureRecognizers) &&
            (identical(other.indoorViewEnabled, indoorViewEnabled) || other.indoorViewEnabled == indoorViewEnabled) &&
            (identical(other.layoutDirection, layoutDirection) || other.layoutDirection == layoutDirection) &&
            (identical(other.mapToolbarEnabled, mapToolbarEnabled) || other.mapToolbarEnabled == mapToolbarEnabled) &&
            (identical(other.onCameraIdle, onCameraIdle) || other.onCameraIdle == onCameraIdle) &&
            (identical(other.onCameraMoveStarted, onCameraMoveStarted) || other.onCameraMoveStarted == onCameraMoveStarted) &&
            (identical(other.onLongPress, onLongPress) || other.onLongPress == onLongPress) &&
            const DeepCollectionEquality().equals(other.polygons, polygons) &&
            const DeepCollectionEquality().equals(other.polylines, polylines) &&
            (identical(other.rotateGesturesEnabled, rotateGesturesEnabled) || other.rotateGesturesEnabled == rotateGesturesEnabled) &&
            (identical(other.scrollGesturesEnabled, scrollGesturesEnabled) || other.scrollGesturesEnabled == scrollGesturesEnabled) &&
            const DeepCollectionEquality().equals(other.tileOverlays, tileOverlays) &&
            (identical(other.tiltGesturesEnabled, tiltGesturesEnabled) || other.tiltGesturesEnabled == tiltGesturesEnabled) &&
            (identical(other.trafficEnabled, trafficEnabled) || other.trafficEnabled == trafficEnabled) &&
            (identical(other.webGestureHandling, webGestureHandling) || other.webGestureHandling == webGestureHandling) &&
            (identical(other.zoomGesturesEnabled, zoomGesturesEnabled) || other.zoomGesturesEnabled == zoomGesturesEnabled) &&
            const DeepCollectionEquality().equals(other.clusterManagers, clusterManagers) &&
            const DeepCollectionEquality().equals(other.groundOverlays, groundOverlays) &&
            const DeepCollectionEquality().equals(other.heatmaps, heatmaps) &&
            (identical(other.cardType, cardType) || other.cardType == cardType) &&
            (identical(other.cardColor, cardColor) || other.cardColor == cardColor) &&
            (identical(other.cardRadius, cardRadius) || other.cardRadius == cardRadius) &&
            (identical(other.cardBorder, cardBorder) || other.cardBorder == cardBorder) &&
            (identical(other.noAddressFoundText, noAddressFoundText) || other.noAddressFoundText == noAddressFoundText));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        apiKey,
        const DeepCollectionEquality().hash(placesApi),
        geocodingRadius,
        geocodingAllFields,
        const DeepCollectionEquality().hash(geocodingFields),
        const DeepCollectionEquality().hash(geocodingInstanceFields),
        const DeepCollectionEquality().hash(geocodingFilter),
        initialPosition,
        initialZoom,
        initialMapType,
        myLocationButtonEnabled,
        myLocationEnabled,
        zoomControlsEnabled,
        minMaxZoomPreference,
        onCameraMove,
        padding,
        compassEnabled,
        liteModeEnabled,
        mapStyle,
        floatingControlsColor,
        floatingControlsIconColor,
        mapTypeIcon,
        locationIcon,
        mainMarkerIcon,
        hideBottomCardOnKeyboard,
        bottomCardTitle,
        bottomCardType,
        confirmButton,
        bottomCardBuilder,
        searchBarBuilder,
        locationSettings,
        onLocationError,
        hideMoreOptions,
        mapTypeButton,
        locationButton,
        fabTooltip,
        const DeepCollectionEquality().hash(additionalMarkers),
        const DeepCollectionEquality().hash(customMarkerIcons),
        const DeepCollectionEquality().hash(customInfoWindows),
        const DeepCollectionEquality().hash(onMarkerTapped),
        onMapCreated,
        onMapTypeChanged,
        onSuggestionSelected,
        onNext,
        onAddressDecoded,
        onAddressSelected,
        buildingsEnabled,
        cameraTargetBounds,
        const DeepCollectionEquality().hash(circles),
        cloudMapId,
        fortyFiveDegreeImageryEnabled,
        const DeepCollectionEquality().hash(gestureRecognizers),
        indoorViewEnabled,
        layoutDirection,
        mapToolbarEnabled,
        onCameraIdle,
        onCameraMoveStarted,
        onLongPress,
        const DeepCollectionEquality().hash(polygons),
        const DeepCollectionEquality().hash(polylines),
        rotateGesturesEnabled,
        scrollGesturesEnabled,
        const DeepCollectionEquality().hash(tileOverlays),
        tiltGesturesEnabled,
        trafficEnabled,
        webGestureHandling,
        zoomGesturesEnabled,
        const DeepCollectionEquality().hash(clusterManagers),
        const DeepCollectionEquality().hash(groundOverlays),
        const DeepCollectionEquality().hash(heatmaps),
        cardType,
        cardColor,
        cardRadius,
        cardBorder,
        noAddressFoundText
      ]);

  @override
  String toString() {
    return 'MapLocationPickerConfig(apiKey: $apiKey, placesApi: $placesApi, geocodingRadius: $geocodingRadius, geocodingAllFields: $geocodingAllFields, geocodingFields: $geocodingFields, geocodingInstanceFields: $geocodingInstanceFields, geocodingFilter: $geocodingFilter, initialPosition: $initialPosition, initialZoom: $initialZoom, initialMapType: $initialMapType, myLocationButtonEnabled: $myLocationButtonEnabled, myLocationEnabled: $myLocationEnabled, zoomControlsEnabled: $zoomControlsEnabled, minMaxZoomPreference: $minMaxZoomPreference, onCameraMove: $onCameraMove, padding: $padding, compassEnabled: $compassEnabled, liteModeEnabled: $liteModeEnabled, mapStyle: $mapStyle, floatingControlsColor: $floatingControlsColor, floatingControlsIconColor: $floatingControlsIconColor, mapTypeIcon: $mapTypeIcon, locationIcon: $locationIcon, mainMarkerIcon: $mainMarkerIcon, hideBottomCardOnKeyboard: $hideBottomCardOnKeyboard, bottomCardTitle: $bottomCardTitle, bottomCardType: $bottomCardType, confirmButton: $confirmButton, bottomCardBuilder: $bottomCardBuilder, searchBarBuilder: $searchBarBuilder, locationSettings: $locationSettings, onLocationError: $onLocationError, hideMoreOptions: $hideMoreOptions, mapTypeButton: $mapTypeButton, locationButton: $locationButton, fabTooltip: $fabTooltip, additionalMarkers: $additionalMarkers, customMarkerIcons: $customMarkerIcons, customInfoWindows: $customInfoWindows, onMarkerTapped: $onMarkerTapped, onMapCreated: $onMapCreated, onMapTypeChanged: $onMapTypeChanged, onSuggestionSelected: $onSuggestionSelected, onNext: $onNext, onAddressDecoded: $onAddressDecoded, onAddressSelected: $onAddressSelected, buildingsEnabled: $buildingsEnabled, cameraTargetBounds: $cameraTargetBounds, circles: $circles, cloudMapId: $cloudMapId, fortyFiveDegreeImageryEnabled: $fortyFiveDegreeImageryEnabled, gestureRecognizers: $gestureRecognizers, indoorViewEnabled: $indoorViewEnabled, layoutDirection: $layoutDirection, mapToolbarEnabled: $mapToolbarEnabled, onCameraIdle: $onCameraIdle, onCameraMoveStarted: $onCameraMoveStarted, onLongPress: $onLongPress, polygons: $polygons, polylines: $polylines, rotateGesturesEnabled: $rotateGesturesEnabled, scrollGesturesEnabled: $scrollGesturesEnabled, tileOverlays: $tileOverlays, tiltGesturesEnabled: $tiltGesturesEnabled, trafficEnabled: $trafficEnabled, webGestureHandling: $webGestureHandling, zoomGesturesEnabled: $zoomGesturesEnabled, clusterManagers: $clusterManagers, groundOverlays: $groundOverlays, heatmaps: $heatmaps, cardType: $cardType, cardColor: $cardColor, cardRadius: $cardRadius, cardBorder: $cardBorder, noAddressFoundText: $noAddressFoundText)';
  }
}

/// @nodoc
abstract mixin class $MapLocationPickerConfigCopyWith<$Res> {
  factory $MapLocationPickerConfigCopyWith(MapLocationPickerConfig value,
          $Res Function(MapLocationPickerConfig) _then) =
      _$MapLocationPickerConfigCopyWithImpl;
  @useResult
  $Res call(
      {String apiKey,
      PlacesAPINew? placesApi,
      double geocodingRadius,
      bool geocodingAllFields,
      List<String>? geocodingFields,
      PlacesResponse? geocodingInstanceFields,
      NearbySearchFilter? geocodingFilter,
      LatLng initialPosition,
      double initialZoom,
      MapType initialMapType,
      bool myLocationButtonEnabled,
      bool myLocationEnabled,
      bool zoomControlsEnabled,
      MinMaxZoomPreference minMaxZoomPreference,
      void Function(CameraPosition)? onCameraMove,
      EdgeInsets padding,
      bool compassEnabled,
      bool liteModeEnabled,
      String? mapStyle,
      Color? floatingControlsColor,
      Color? floatingControlsIconColor,
      IconData? mapTypeIcon,
      IconData? locationIcon,
      BitmapDescriptor? mainMarkerIcon,
      bool hideBottomCardOnKeyboard,
      String bottomCardTitle,
      CardType bottomCardType,
      ConfirmButtonBuilder confirmButton,
      BottomCardBuilder bottomCardBuilder,
      SearchBarBuilder searchBarBuilder,
      LocationSettings? locationSettings,
      Function(dynamic error)? onLocationError,
      bool hideMoreOptions,
      Widget? mapTypeButton,
      Widget? locationButton,
      String fabTooltip,
      Map<String, LatLng>? additionalMarkers,
      Map<String, BitmapDescriptor>? customMarkerIcons,
      Map<String, InfoWindow>? customInfoWindows,
      Map<String, VoidCallback>? onMarkerTapped,
      Function(GoogleMapController)? onMapCreated,
      Function(MapType)? onMapTypeChanged,
      Function(Place?)? onSuggestionSelected,
      Function(Place?)? onNext,
      Function(Place?)? onAddressDecoded,
      Function(Place)? onAddressSelected,
      bool buildingsEnabled,
      CameraTargetBounds cameraTargetBounds,
      Set<Circle> circles,
      String? cloudMapId,
      bool fortyFiveDegreeImageryEnabled,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      bool indoorViewEnabled,
      TextDirection? layoutDirection,
      bool mapToolbarEnabled,
      VoidCallback? onCameraIdle,
      VoidCallback? onCameraMoveStarted,
      ArgumentCallback<LatLng>? onLongPress,
      Set<Polygon> polygons,
      Set<Polyline> polylines,
      bool rotateGesturesEnabled,
      bool scrollGesturesEnabled,
      Set<TileOverlay> tileOverlays,
      bool tiltGesturesEnabled,
      bool trafficEnabled,
      WebGestureHandling? webGestureHandling,
      bool zoomGesturesEnabled,
      Set<ClusterManager> clusterManagers,
      Set<GroundOverlay> groundOverlays,
      Set<Heatmap> heatmaps,
      CardType cardType,
      Color? cardColor,
      BorderRadiusGeometry? cardRadius,
      BoxBorder? cardBorder,
      String noAddressFoundText});
}

/// @nodoc
class _$MapLocationPickerConfigCopyWithImpl<$Res>
    implements $MapLocationPickerConfigCopyWith<$Res> {
  _$MapLocationPickerConfigCopyWithImpl(this._self, this._then);

  final MapLocationPickerConfig _self;
  final $Res Function(MapLocationPickerConfig) _then;

  /// Create a copy of MapLocationPickerConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKey = null,
    Object? placesApi = freezed,
    Object? geocodingRadius = null,
    Object? geocodingAllFields = null,
    Object? geocodingFields = freezed,
    Object? geocodingInstanceFields = freezed,
    Object? geocodingFilter = freezed,
    Object? initialPosition = null,
    Object? initialZoom = null,
    Object? initialMapType = null,
    Object? myLocationButtonEnabled = null,
    Object? myLocationEnabled = null,
    Object? zoomControlsEnabled = null,
    Object? minMaxZoomPreference = null,
    Object? onCameraMove = freezed,
    Object? padding = null,
    Object? compassEnabled = null,
    Object? liteModeEnabled = null,
    Object? mapStyle = freezed,
    Object? floatingControlsColor = freezed,
    Object? floatingControlsIconColor = freezed,
    Object? mapTypeIcon = freezed,
    Object? locationIcon = freezed,
    Object? mainMarkerIcon = freezed,
    Object? hideBottomCardOnKeyboard = null,
    Object? bottomCardTitle = null,
    Object? bottomCardType = null,
    Object? confirmButton = freezed,
    Object? bottomCardBuilder = freezed,
    Object? searchBarBuilder = freezed,
    Object? locationSettings = freezed,
    Object? onLocationError = freezed,
    Object? hideMoreOptions = null,
    Object? mapTypeButton = freezed,
    Object? locationButton = freezed,
    Object? fabTooltip = null,
    Object? additionalMarkers = freezed,
    Object? customMarkerIcons = freezed,
    Object? customInfoWindows = freezed,
    Object? onMarkerTapped = freezed,
    Object? onMapCreated = freezed,
    Object? onMapTypeChanged = freezed,
    Object? onSuggestionSelected = freezed,
    Object? onNext = freezed,
    Object? onAddressDecoded = freezed,
    Object? onAddressSelected = freezed,
    Object? buildingsEnabled = null,
    Object? cameraTargetBounds = null,
    Object? circles = null,
    Object? cloudMapId = freezed,
    Object? fortyFiveDegreeImageryEnabled = null,
    Object? gestureRecognizers = null,
    Object? indoorViewEnabled = null,
    Object? layoutDirection = freezed,
    Object? mapToolbarEnabled = null,
    Object? onCameraIdle = freezed,
    Object? onCameraMoveStarted = freezed,
    Object? onLongPress = freezed,
    Object? polygons = null,
    Object? polylines = null,
    Object? rotateGesturesEnabled = null,
    Object? scrollGesturesEnabled = null,
    Object? tileOverlays = null,
    Object? tiltGesturesEnabled = null,
    Object? trafficEnabled = null,
    Object? webGestureHandling = freezed,
    Object? zoomGesturesEnabled = null,
    Object? clusterManagers = null,
    Object? groundOverlays = null,
    Object? heatmaps = null,
    Object? cardType = null,
    Object? cardColor = freezed,
    Object? cardRadius = freezed,
    Object? cardBorder = freezed,
    Object? noAddressFoundText = null,
  }) {
    return _then(_self.copyWith(
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      placesApi: freezed == placesApi
          ? _self.placesApi
          : placesApi // ignore: cast_nullable_to_non_nullable
              as PlacesAPINew?,
      geocodingRadius: null == geocodingRadius
          ? _self.geocodingRadius
          : geocodingRadius // ignore: cast_nullable_to_non_nullable
              as double,
      geocodingAllFields: null == geocodingAllFields
          ? _self.geocodingAllFields
          : geocodingAllFields // ignore: cast_nullable_to_non_nullable
              as bool,
      geocodingFields: freezed == geocodingFields
          ? _self.geocodingFields
          : geocodingFields // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      geocodingInstanceFields: freezed == geocodingInstanceFields
          ? _self.geocodingInstanceFields
          : geocodingInstanceFields // ignore: cast_nullable_to_non_nullable
              as PlacesResponse?,
      geocodingFilter: freezed == geocodingFilter
          ? _self.geocodingFilter
          : geocodingFilter // ignore: cast_nullable_to_non_nullable
              as NearbySearchFilter?,
      initialPosition: null == initialPosition
          ? _self.initialPosition
          : initialPosition // ignore: cast_nullable_to_non_nullable
              as LatLng,
      initialZoom: null == initialZoom
          ? _self.initialZoom
          : initialZoom // ignore: cast_nullable_to_non_nullable
              as double,
      initialMapType: null == initialMapType
          ? _self.initialMapType
          : initialMapType // ignore: cast_nullable_to_non_nullable
              as MapType,
      myLocationButtonEnabled: null == myLocationButtonEnabled
          ? _self.myLocationButtonEnabled
          : myLocationButtonEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      myLocationEnabled: null == myLocationEnabled
          ? _self.myLocationEnabled
          : myLocationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      zoomControlsEnabled: null == zoomControlsEnabled
          ? _self.zoomControlsEnabled
          : zoomControlsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      minMaxZoomPreference: null == minMaxZoomPreference
          ? _self.minMaxZoomPreference
          : minMaxZoomPreference // ignore: cast_nullable_to_non_nullable
              as MinMaxZoomPreference,
      onCameraMove: freezed == onCameraMove
          ? _self.onCameraMove
          : onCameraMove // ignore: cast_nullable_to_non_nullable
              as void Function(CameraPosition)?,
      padding: null == padding
          ? _self.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
      compassEnabled: null == compassEnabled
          ? _self.compassEnabled
          : compassEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      liteModeEnabled: null == liteModeEnabled
          ? _self.liteModeEnabled
          : liteModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      mapStyle: freezed == mapStyle
          ? _self.mapStyle
          : mapStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      floatingControlsColor: freezed == floatingControlsColor
          ? _self.floatingControlsColor
          : floatingControlsColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      floatingControlsIconColor: freezed == floatingControlsIconColor
          ? _self.floatingControlsIconColor
          : floatingControlsIconColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      mapTypeIcon: freezed == mapTypeIcon
          ? _self.mapTypeIcon
          : mapTypeIcon // ignore: cast_nullable_to_non_nullable
              as IconData?,
      locationIcon: freezed == locationIcon
          ? _self.locationIcon
          : locationIcon // ignore: cast_nullable_to_non_nullable
              as IconData?,
      mainMarkerIcon: freezed == mainMarkerIcon
          ? _self.mainMarkerIcon
          : mainMarkerIcon // ignore: cast_nullable_to_non_nullable
              as BitmapDescriptor?,
      hideBottomCardOnKeyboard: null == hideBottomCardOnKeyboard
          ? _self.hideBottomCardOnKeyboard
          : hideBottomCardOnKeyboard // ignore: cast_nullable_to_non_nullable
              as bool,
      bottomCardTitle: null == bottomCardTitle
          ? _self.bottomCardTitle
          : bottomCardTitle // ignore: cast_nullable_to_non_nullable
              as String,
      bottomCardType: null == bottomCardType
          ? _self.bottomCardType
          : bottomCardType // ignore: cast_nullable_to_non_nullable
              as CardType,
      confirmButton: freezed == confirmButton
          ? _self.confirmButton
          : confirmButton // ignore: cast_nullable_to_non_nullable
              as ConfirmButtonBuilder,
      bottomCardBuilder: freezed == bottomCardBuilder
          ? _self.bottomCardBuilder
          : bottomCardBuilder // ignore: cast_nullable_to_non_nullable
              as BottomCardBuilder,
      searchBarBuilder: freezed == searchBarBuilder
          ? _self.searchBarBuilder
          : searchBarBuilder // ignore: cast_nullable_to_non_nullable
              as SearchBarBuilder,
      locationSettings: freezed == locationSettings
          ? _self.locationSettings
          : locationSettings // ignore: cast_nullable_to_non_nullable
              as LocationSettings?,
      onLocationError: freezed == onLocationError
          ? _self.onLocationError
          : onLocationError // ignore: cast_nullable_to_non_nullable
              as Function(dynamic error)?,
      hideMoreOptions: null == hideMoreOptions
          ? _self.hideMoreOptions
          : hideMoreOptions // ignore: cast_nullable_to_non_nullable
              as bool,
      mapTypeButton: freezed == mapTypeButton
          ? _self.mapTypeButton
          : mapTypeButton // ignore: cast_nullable_to_non_nullable
              as Widget?,
      locationButton: freezed == locationButton
          ? _self.locationButton
          : locationButton // ignore: cast_nullable_to_non_nullable
              as Widget?,
      fabTooltip: null == fabTooltip
          ? _self.fabTooltip
          : fabTooltip // ignore: cast_nullable_to_non_nullable
              as String,
      additionalMarkers: freezed == additionalMarkers
          ? _self.additionalMarkers
          : additionalMarkers // ignore: cast_nullable_to_non_nullable
              as Map<String, LatLng>?,
      customMarkerIcons: freezed == customMarkerIcons
          ? _self.customMarkerIcons
          : customMarkerIcons // ignore: cast_nullable_to_non_nullable
              as Map<String, BitmapDescriptor>?,
      customInfoWindows: freezed == customInfoWindows
          ? _self.customInfoWindows
          : customInfoWindows // ignore: cast_nullable_to_non_nullable
              as Map<String, InfoWindow>?,
      onMarkerTapped: freezed == onMarkerTapped
          ? _self.onMarkerTapped
          : onMarkerTapped // ignore: cast_nullable_to_non_nullable
              as Map<String, VoidCallback>?,
      onMapCreated: freezed == onMapCreated
          ? _self.onMapCreated
          : onMapCreated // ignore: cast_nullable_to_non_nullable
              as Function(GoogleMapController)?,
      onMapTypeChanged: freezed == onMapTypeChanged
          ? _self.onMapTypeChanged
          : onMapTypeChanged // ignore: cast_nullable_to_non_nullable
              as Function(MapType)?,
      onSuggestionSelected: freezed == onSuggestionSelected
          ? _self.onSuggestionSelected
          : onSuggestionSelected // ignore: cast_nullable_to_non_nullable
              as Function(Place?)?,
      onNext: freezed == onNext
          ? _self.onNext
          : onNext // ignore: cast_nullable_to_non_nullable
              as Function(Place?)?,
      onAddressDecoded: freezed == onAddressDecoded
          ? _self.onAddressDecoded
          : onAddressDecoded // ignore: cast_nullable_to_non_nullable
              as Function(Place?)?,
      onAddressSelected: freezed == onAddressSelected
          ? _self.onAddressSelected
          : onAddressSelected // ignore: cast_nullable_to_non_nullable
              as Function(Place)?,
      buildingsEnabled: null == buildingsEnabled
          ? _self.buildingsEnabled
          : buildingsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      cameraTargetBounds: null == cameraTargetBounds
          ? _self.cameraTargetBounds
          : cameraTargetBounds // ignore: cast_nullable_to_non_nullable
              as CameraTargetBounds,
      circles: null == circles
          ? _self.circles
          : circles // ignore: cast_nullable_to_non_nullable
              as Set<Circle>,
      cloudMapId: freezed == cloudMapId
          ? _self.cloudMapId
          : cloudMapId // ignore: cast_nullable_to_non_nullable
              as String?,
      fortyFiveDegreeImageryEnabled: null == fortyFiveDegreeImageryEnabled
          ? _self.fortyFiveDegreeImageryEnabled
          : fortyFiveDegreeImageryEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      gestureRecognizers: null == gestureRecognizers
          ? _self.gestureRecognizers
          : gestureRecognizers // ignore: cast_nullable_to_non_nullable
              as Set<Factory<OneSequenceGestureRecognizer>>,
      indoorViewEnabled: null == indoorViewEnabled
          ? _self.indoorViewEnabled
          : indoorViewEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      layoutDirection: freezed == layoutDirection
          ? _self.layoutDirection
          : layoutDirection // ignore: cast_nullable_to_non_nullable
              as TextDirection?,
      mapToolbarEnabled: null == mapToolbarEnabled
          ? _self.mapToolbarEnabled
          : mapToolbarEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      onCameraIdle: freezed == onCameraIdle
          ? _self.onCameraIdle
          : onCameraIdle // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
      onCameraMoveStarted: freezed == onCameraMoveStarted
          ? _self.onCameraMoveStarted
          : onCameraMoveStarted // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
      onLongPress: freezed == onLongPress
          ? _self.onLongPress
          : onLongPress // ignore: cast_nullable_to_non_nullable
              as ArgumentCallback<LatLng>?,
      polygons: null == polygons
          ? _self.polygons
          : polygons // ignore: cast_nullable_to_non_nullable
              as Set<Polygon>,
      polylines: null == polylines
          ? _self.polylines
          : polylines // ignore: cast_nullable_to_non_nullable
              as Set<Polyline>,
      rotateGesturesEnabled: null == rotateGesturesEnabled
          ? _self.rotateGesturesEnabled
          : rotateGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      scrollGesturesEnabled: null == scrollGesturesEnabled
          ? _self.scrollGesturesEnabled
          : scrollGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      tileOverlays: null == tileOverlays
          ? _self.tileOverlays
          : tileOverlays // ignore: cast_nullable_to_non_nullable
              as Set<TileOverlay>,
      tiltGesturesEnabled: null == tiltGesturesEnabled
          ? _self.tiltGesturesEnabled
          : tiltGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      trafficEnabled: null == trafficEnabled
          ? _self.trafficEnabled
          : trafficEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      webGestureHandling: freezed == webGestureHandling
          ? _self.webGestureHandling
          : webGestureHandling // ignore: cast_nullable_to_non_nullable
              as WebGestureHandling?,
      zoomGesturesEnabled: null == zoomGesturesEnabled
          ? _self.zoomGesturesEnabled
          : zoomGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      clusterManagers: null == clusterManagers
          ? _self.clusterManagers
          : clusterManagers // ignore: cast_nullable_to_non_nullable
              as Set<ClusterManager>,
      groundOverlays: null == groundOverlays
          ? _self.groundOverlays
          : groundOverlays // ignore: cast_nullable_to_non_nullable
              as Set<GroundOverlay>,
      heatmaps: null == heatmaps
          ? _self.heatmaps
          : heatmaps // ignore: cast_nullable_to_non_nullable
              as Set<Heatmap>,
      cardType: null == cardType
          ? _self.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as CardType,
      cardColor: freezed == cardColor
          ? _self.cardColor
          : cardColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      cardRadius: freezed == cardRadius
          ? _self.cardRadius
          : cardRadius // ignore: cast_nullable_to_non_nullable
              as BorderRadiusGeometry?,
      cardBorder: freezed == cardBorder
          ? _self.cardBorder
          : cardBorder // ignore: cast_nullable_to_non_nullable
              as BoxBorder?,
      noAddressFoundText: null == noAddressFoundText
          ? _self.noAddressFoundText
          : noAddressFoundText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [MapLocationPickerConfig].
extension MapLocationPickerConfigPatterns on MapLocationPickerConfig {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MapLocationPickerConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapLocationPickerConfig() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MapLocationPickerConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapLocationPickerConfig():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MapLocationPickerConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapLocationPickerConfig() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String apiKey,
            PlacesAPINew? placesApi,
            double geocodingRadius,
            bool geocodingAllFields,
            List<String>? geocodingFields,
            PlacesResponse? geocodingInstanceFields,
            NearbySearchFilter? geocodingFilter,
            LatLng initialPosition,
            double initialZoom,
            MapType initialMapType,
            bool myLocationButtonEnabled,
            bool myLocationEnabled,
            bool zoomControlsEnabled,
            MinMaxZoomPreference minMaxZoomPreference,
            void Function(CameraPosition)? onCameraMove,
            EdgeInsets padding,
            bool compassEnabled,
            bool liteModeEnabled,
            String? mapStyle,
            Color? floatingControlsColor,
            Color? floatingControlsIconColor,
            IconData? mapTypeIcon,
            IconData? locationIcon,
            BitmapDescriptor? mainMarkerIcon,
            bool hideBottomCardOnKeyboard,
            String bottomCardTitle,
            CardType bottomCardType,
            ConfirmButtonBuilder confirmButton,
            BottomCardBuilder bottomCardBuilder,
            SearchBarBuilder searchBarBuilder,
            LocationSettings? locationSettings,
            Function(dynamic error)? onLocationError,
            bool hideMoreOptions,
            Widget? mapTypeButton,
            Widget? locationButton,
            String fabTooltip,
            Map<String, LatLng>? additionalMarkers,
            Map<String, BitmapDescriptor>? customMarkerIcons,
            Map<String, InfoWindow>? customInfoWindows,
            Map<String, VoidCallback>? onMarkerTapped,
            Function(GoogleMapController)? onMapCreated,
            Function(MapType)? onMapTypeChanged,
            Function(Place?)? onSuggestionSelected,
            Function(Place?)? onNext,
            Function(Place?)? onAddressDecoded,
            Function(Place)? onAddressSelected,
            bool buildingsEnabled,
            CameraTargetBounds cameraTargetBounds,
            Set<Circle> circles,
            String? cloudMapId,
            bool fortyFiveDegreeImageryEnabled,
            Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
            bool indoorViewEnabled,
            TextDirection? layoutDirection,
            bool mapToolbarEnabled,
            VoidCallback? onCameraIdle,
            VoidCallback? onCameraMoveStarted,
            ArgumentCallback<LatLng>? onLongPress,
            Set<Polygon> polygons,
            Set<Polyline> polylines,
            bool rotateGesturesEnabled,
            bool scrollGesturesEnabled,
            Set<TileOverlay> tileOverlays,
            bool tiltGesturesEnabled,
            bool trafficEnabled,
            WebGestureHandling? webGestureHandling,
            bool zoomGesturesEnabled,
            Set<ClusterManager> clusterManagers,
            Set<GroundOverlay> groundOverlays,
            Set<Heatmap> heatmaps,
            CardType cardType,
            Color? cardColor,
            BorderRadiusGeometry? cardRadius,
            BoxBorder? cardBorder,
            String noAddressFoundText)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MapLocationPickerConfig() when $default != null:
        return $default(
            _that.apiKey,
            _that.placesApi,
            _that.geocodingRadius,
            _that.geocodingAllFields,
            _that.geocodingFields,
            _that.geocodingInstanceFields,
            _that.geocodingFilter,
            _that.initialPosition,
            _that.initialZoom,
            _that.initialMapType,
            _that.myLocationButtonEnabled,
            _that.myLocationEnabled,
            _that.zoomControlsEnabled,
            _that.minMaxZoomPreference,
            _that.onCameraMove,
            _that.padding,
            _that.compassEnabled,
            _that.liteModeEnabled,
            _that.mapStyle,
            _that.floatingControlsColor,
            _that.floatingControlsIconColor,
            _that.mapTypeIcon,
            _that.locationIcon,
            _that.mainMarkerIcon,
            _that.hideBottomCardOnKeyboard,
            _that.bottomCardTitle,
            _that.bottomCardType,
            _that.confirmButton,
            _that.bottomCardBuilder,
            _that.searchBarBuilder,
            _that.locationSettings,
            _that.onLocationError,
            _that.hideMoreOptions,
            _that.mapTypeButton,
            _that.locationButton,
            _that.fabTooltip,
            _that.additionalMarkers,
            _that.customMarkerIcons,
            _that.customInfoWindows,
            _that.onMarkerTapped,
            _that.onMapCreated,
            _that.onMapTypeChanged,
            _that.onSuggestionSelected,
            _that.onNext,
            _that.onAddressDecoded,
            _that.onAddressSelected,
            _that.buildingsEnabled,
            _that.cameraTargetBounds,
            _that.circles,
            _that.cloudMapId,
            _that.fortyFiveDegreeImageryEnabled,
            _that.gestureRecognizers,
            _that.indoorViewEnabled,
            _that.layoutDirection,
            _that.mapToolbarEnabled,
            _that.onCameraIdle,
            _that.onCameraMoveStarted,
            _that.onLongPress,
            _that.polygons,
            _that.polylines,
            _that.rotateGesturesEnabled,
            _that.scrollGesturesEnabled,
            _that.tileOverlays,
            _that.tiltGesturesEnabled,
            _that.trafficEnabled,
            _that.webGestureHandling,
            _that.zoomGesturesEnabled,
            _that.clusterManagers,
            _that.groundOverlays,
            _that.heatmaps,
            _that.cardType,
            _that.cardColor,
            _that.cardRadius,
            _that.cardBorder,
            _that.noAddressFoundText);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String apiKey,
            PlacesAPINew? placesApi,
            double geocodingRadius,
            bool geocodingAllFields,
            List<String>? geocodingFields,
            PlacesResponse? geocodingInstanceFields,
            NearbySearchFilter? geocodingFilter,
            LatLng initialPosition,
            double initialZoom,
            MapType initialMapType,
            bool myLocationButtonEnabled,
            bool myLocationEnabled,
            bool zoomControlsEnabled,
            MinMaxZoomPreference minMaxZoomPreference,
            void Function(CameraPosition)? onCameraMove,
            EdgeInsets padding,
            bool compassEnabled,
            bool liteModeEnabled,
            String? mapStyle,
            Color? floatingControlsColor,
            Color? floatingControlsIconColor,
            IconData? mapTypeIcon,
            IconData? locationIcon,
            BitmapDescriptor? mainMarkerIcon,
            bool hideBottomCardOnKeyboard,
            String bottomCardTitle,
            CardType bottomCardType,
            ConfirmButtonBuilder confirmButton,
            BottomCardBuilder bottomCardBuilder,
            SearchBarBuilder searchBarBuilder,
            LocationSettings? locationSettings,
            Function(dynamic error)? onLocationError,
            bool hideMoreOptions,
            Widget? mapTypeButton,
            Widget? locationButton,
            String fabTooltip,
            Map<String, LatLng>? additionalMarkers,
            Map<String, BitmapDescriptor>? customMarkerIcons,
            Map<String, InfoWindow>? customInfoWindows,
            Map<String, VoidCallback>? onMarkerTapped,
            Function(GoogleMapController)? onMapCreated,
            Function(MapType)? onMapTypeChanged,
            Function(Place?)? onSuggestionSelected,
            Function(Place?)? onNext,
            Function(Place?)? onAddressDecoded,
            Function(Place)? onAddressSelected,
            bool buildingsEnabled,
            CameraTargetBounds cameraTargetBounds,
            Set<Circle> circles,
            String? cloudMapId,
            bool fortyFiveDegreeImageryEnabled,
            Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
            bool indoorViewEnabled,
            TextDirection? layoutDirection,
            bool mapToolbarEnabled,
            VoidCallback? onCameraIdle,
            VoidCallback? onCameraMoveStarted,
            ArgumentCallback<LatLng>? onLongPress,
            Set<Polygon> polygons,
            Set<Polyline> polylines,
            bool rotateGesturesEnabled,
            bool scrollGesturesEnabled,
            Set<TileOverlay> tileOverlays,
            bool tiltGesturesEnabled,
            bool trafficEnabled,
            WebGestureHandling? webGestureHandling,
            bool zoomGesturesEnabled,
            Set<ClusterManager> clusterManagers,
            Set<GroundOverlay> groundOverlays,
            Set<Heatmap> heatmaps,
            CardType cardType,
            Color? cardColor,
            BorderRadiusGeometry? cardRadius,
            BoxBorder? cardBorder,
            String noAddressFoundText)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapLocationPickerConfig():
        return $default(
            _that.apiKey,
            _that.placesApi,
            _that.geocodingRadius,
            _that.geocodingAllFields,
            _that.geocodingFields,
            _that.geocodingInstanceFields,
            _that.geocodingFilter,
            _that.initialPosition,
            _that.initialZoom,
            _that.initialMapType,
            _that.myLocationButtonEnabled,
            _that.myLocationEnabled,
            _that.zoomControlsEnabled,
            _that.minMaxZoomPreference,
            _that.onCameraMove,
            _that.padding,
            _that.compassEnabled,
            _that.liteModeEnabled,
            _that.mapStyle,
            _that.floatingControlsColor,
            _that.floatingControlsIconColor,
            _that.mapTypeIcon,
            _that.locationIcon,
            _that.mainMarkerIcon,
            _that.hideBottomCardOnKeyboard,
            _that.bottomCardTitle,
            _that.bottomCardType,
            _that.confirmButton,
            _that.bottomCardBuilder,
            _that.searchBarBuilder,
            _that.locationSettings,
            _that.onLocationError,
            _that.hideMoreOptions,
            _that.mapTypeButton,
            _that.locationButton,
            _that.fabTooltip,
            _that.additionalMarkers,
            _that.customMarkerIcons,
            _that.customInfoWindows,
            _that.onMarkerTapped,
            _that.onMapCreated,
            _that.onMapTypeChanged,
            _that.onSuggestionSelected,
            _that.onNext,
            _that.onAddressDecoded,
            _that.onAddressSelected,
            _that.buildingsEnabled,
            _that.cameraTargetBounds,
            _that.circles,
            _that.cloudMapId,
            _that.fortyFiveDegreeImageryEnabled,
            _that.gestureRecognizers,
            _that.indoorViewEnabled,
            _that.layoutDirection,
            _that.mapToolbarEnabled,
            _that.onCameraIdle,
            _that.onCameraMoveStarted,
            _that.onLongPress,
            _that.polygons,
            _that.polylines,
            _that.rotateGesturesEnabled,
            _that.scrollGesturesEnabled,
            _that.tileOverlays,
            _that.tiltGesturesEnabled,
            _that.trafficEnabled,
            _that.webGestureHandling,
            _that.zoomGesturesEnabled,
            _that.clusterManagers,
            _that.groundOverlays,
            _that.heatmaps,
            _that.cardType,
            _that.cardColor,
            _that.cardRadius,
            _that.cardBorder,
            _that.noAddressFoundText);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String apiKey,
            PlacesAPINew? placesApi,
            double geocodingRadius,
            bool geocodingAllFields,
            List<String>? geocodingFields,
            PlacesResponse? geocodingInstanceFields,
            NearbySearchFilter? geocodingFilter,
            LatLng initialPosition,
            double initialZoom,
            MapType initialMapType,
            bool myLocationButtonEnabled,
            bool myLocationEnabled,
            bool zoomControlsEnabled,
            MinMaxZoomPreference minMaxZoomPreference,
            void Function(CameraPosition)? onCameraMove,
            EdgeInsets padding,
            bool compassEnabled,
            bool liteModeEnabled,
            String? mapStyle,
            Color? floatingControlsColor,
            Color? floatingControlsIconColor,
            IconData? mapTypeIcon,
            IconData? locationIcon,
            BitmapDescriptor? mainMarkerIcon,
            bool hideBottomCardOnKeyboard,
            String bottomCardTitle,
            CardType bottomCardType,
            ConfirmButtonBuilder confirmButton,
            BottomCardBuilder bottomCardBuilder,
            SearchBarBuilder searchBarBuilder,
            LocationSettings? locationSettings,
            Function(dynamic error)? onLocationError,
            bool hideMoreOptions,
            Widget? mapTypeButton,
            Widget? locationButton,
            String fabTooltip,
            Map<String, LatLng>? additionalMarkers,
            Map<String, BitmapDescriptor>? customMarkerIcons,
            Map<String, InfoWindow>? customInfoWindows,
            Map<String, VoidCallback>? onMarkerTapped,
            Function(GoogleMapController)? onMapCreated,
            Function(MapType)? onMapTypeChanged,
            Function(Place?)? onSuggestionSelected,
            Function(Place?)? onNext,
            Function(Place?)? onAddressDecoded,
            Function(Place)? onAddressSelected,
            bool buildingsEnabled,
            CameraTargetBounds cameraTargetBounds,
            Set<Circle> circles,
            String? cloudMapId,
            bool fortyFiveDegreeImageryEnabled,
            Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
            bool indoorViewEnabled,
            TextDirection? layoutDirection,
            bool mapToolbarEnabled,
            VoidCallback? onCameraIdle,
            VoidCallback? onCameraMoveStarted,
            ArgumentCallback<LatLng>? onLongPress,
            Set<Polygon> polygons,
            Set<Polyline> polylines,
            bool rotateGesturesEnabled,
            bool scrollGesturesEnabled,
            Set<TileOverlay> tileOverlays,
            bool tiltGesturesEnabled,
            bool trafficEnabled,
            WebGestureHandling? webGestureHandling,
            bool zoomGesturesEnabled,
            Set<ClusterManager> clusterManagers,
            Set<GroundOverlay> groundOverlays,
            Set<Heatmap> heatmaps,
            CardType cardType,
            Color? cardColor,
            BorderRadiusGeometry? cardRadius,
            BoxBorder? cardBorder,
            String noAddressFoundText)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MapLocationPickerConfig() when $default != null:
        return $default(
            _that.apiKey,
            _that.placesApi,
            _that.geocodingRadius,
            _that.geocodingAllFields,
            _that.geocodingFields,
            _that.geocodingInstanceFields,
            _that.geocodingFilter,
            _that.initialPosition,
            _that.initialZoom,
            _that.initialMapType,
            _that.myLocationButtonEnabled,
            _that.myLocationEnabled,
            _that.zoomControlsEnabled,
            _that.minMaxZoomPreference,
            _that.onCameraMove,
            _that.padding,
            _that.compassEnabled,
            _that.liteModeEnabled,
            _that.mapStyle,
            _that.floatingControlsColor,
            _that.floatingControlsIconColor,
            _that.mapTypeIcon,
            _that.locationIcon,
            _that.mainMarkerIcon,
            _that.hideBottomCardOnKeyboard,
            _that.bottomCardTitle,
            _that.bottomCardType,
            _that.confirmButton,
            _that.bottomCardBuilder,
            _that.searchBarBuilder,
            _that.locationSettings,
            _that.onLocationError,
            _that.hideMoreOptions,
            _that.mapTypeButton,
            _that.locationButton,
            _that.fabTooltip,
            _that.additionalMarkers,
            _that.customMarkerIcons,
            _that.customInfoWindows,
            _that.onMarkerTapped,
            _that.onMapCreated,
            _that.onMapTypeChanged,
            _that.onSuggestionSelected,
            _that.onNext,
            _that.onAddressDecoded,
            _that.onAddressSelected,
            _that.buildingsEnabled,
            _that.cameraTargetBounds,
            _that.circles,
            _that.cloudMapId,
            _that.fortyFiveDegreeImageryEnabled,
            _that.gestureRecognizers,
            _that.indoorViewEnabled,
            _that.layoutDirection,
            _that.mapToolbarEnabled,
            _that.onCameraIdle,
            _that.onCameraMoveStarted,
            _that.onLongPress,
            _that.polygons,
            _that.polylines,
            _that.rotateGesturesEnabled,
            _that.scrollGesturesEnabled,
            _that.tileOverlays,
            _that.tiltGesturesEnabled,
            _that.trafficEnabled,
            _that.webGestureHandling,
            _that.zoomGesturesEnabled,
            _that.clusterManagers,
            _that.groundOverlays,
            _that.heatmaps,
            _that.cardType,
            _that.cardColor,
            _that.cardRadius,
            _that.cardBorder,
            _that.noAddressFoundText);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MapLocationPickerConfig implements MapLocationPickerConfig {
  const _MapLocationPickerConfig(
      {this.apiKey = '',
      this.placesApi = null,
      this.geocodingRadius = 500,
      this.geocodingAllFields = true,
      final List<String>? geocodingFields = null,
      this.geocodingInstanceFields = null,
      this.geocodingFilter = null,
      this.initialPosition = const LatLng(28.8993468, 76.6250249),
      this.initialZoom = 14.0,
      this.initialMapType = MapType.normal,
      this.myLocationButtonEnabled = false,
      this.myLocationEnabled = false,
      this.zoomControlsEnabled = false,
      this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
      this.onCameraMove = null,
      this.padding = EdgeInsets.zero,
      this.compassEnabled = true,
      this.liteModeEnabled = false,
      this.mapStyle = null,
      this.floatingControlsColor = null,
      this.floatingControlsIconColor = null,
      this.mapTypeIcon = null,
      this.locationIcon = null,
      this.mainMarkerIcon = null,
      this.hideBottomCardOnKeyboard = true,
      this.bottomCardTitle = 'Select your location',
      this.bottomCardType = CardType.defaultCard,
      this.confirmButton = null,
      this.bottomCardBuilder = null,
      this.searchBarBuilder = null,
      this.locationSettings = null,
      this.onLocationError = null,
      this.hideMoreOptions = false,
      this.mapTypeButton = null,
      this.locationButton = null,
      this.fabTooltip = 'My Location',
      final Map<String, LatLng>? additionalMarkers = null,
      final Map<String, BitmapDescriptor>? customMarkerIcons = null,
      final Map<String, InfoWindow>? customInfoWindows = null,
      final Map<String, VoidCallback>? onMarkerTapped = null,
      this.onMapCreated = null,
      this.onMapTypeChanged = null,
      this.onSuggestionSelected = null,
      this.onNext = null,
      this.onAddressDecoded = null,
      this.onAddressSelected = null,
      this.buildingsEnabled = true,
      this.cameraTargetBounds = CameraTargetBounds.unbounded,
      final Set<Circle> circles = const <Circle>{},
      this.cloudMapId = null,
      this.fortyFiveDegreeImageryEnabled = false,
      final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers =
          const <Factory<OneSequenceGestureRecognizer>>{},
      this.indoorViewEnabled = false,
      this.layoutDirection = null,
      this.mapToolbarEnabled = true,
      this.onCameraIdle = null,
      this.onCameraMoveStarted = null,
      this.onLongPress = null,
      final Set<Polygon> polygons = const <Polygon>{},
      final Set<Polyline> polylines = const <Polyline>{},
      this.rotateGesturesEnabled = true,
      this.scrollGesturesEnabled = true,
      final Set<TileOverlay> tileOverlays = const <TileOverlay>{},
      this.tiltGesturesEnabled = true,
      this.trafficEnabled = false,
      this.webGestureHandling = null,
      this.zoomGesturesEnabled = true,
      final Set<ClusterManager> clusterManagers = const <ClusterManager>{},
      final Set<GroundOverlay> groundOverlays = const <GroundOverlay>{},
      final Set<Heatmap> heatmaps = const <Heatmap>{},
      this.cardType = CardType.defaultCard,
      this.cardColor = null,
      this.cardRadius = null,
      this.cardBorder = null,
      this.noAddressFoundText = "No address found"})
      : _geocodingFields = geocodingFields,
        _additionalMarkers = additionalMarkers,
        _customMarkerIcons = customMarkerIcons,
        _customInfoWindows = customInfoWindows,
        _onMarkerTapped = onMarkerTapped,
        _circles = circles,
        _gestureRecognizers = gestureRecognizers,
        _polygons = polygons,
        _polylines = polylines,
        _tileOverlays = tileOverlays,
        _clusterManagers = clusterManagers,
        _groundOverlays = groundOverlays,
        _heatmaps = heatmaps;

// Core configuration
  @override
  @JsonKey()
  final String apiKey;
  @override
  @JsonKey()
  final PlacesAPINew? placesApi;
  @override
  @JsonKey()
  final double geocodingRadius;
  @override
  @JsonKey()
  final bool geocodingAllFields;
  final List<String>? _geocodingFields;
  @override
  @JsonKey()
  List<String>? get geocodingFields {
    final value = _geocodingFields;
    if (value == null) return null;
    if (_geocodingFields is EqualUnmodifiableListView) return _geocodingFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final PlacesResponse? geocodingInstanceFields;
  @override
  @JsonKey()
  final NearbySearchFilter? geocodingFilter;
  @override
  @JsonKey()
  final LatLng initialPosition;
  @override
  @JsonKey()
  final double initialZoom;
  @override
  @JsonKey()
  final MapType initialMapType;
  @override
  @JsonKey()
  final bool myLocationButtonEnabled;
  @override
  @JsonKey()
  final bool myLocationEnabled;
  @override
  @JsonKey()
  final bool zoomControlsEnabled;
  @override
  @JsonKey()
  final MinMaxZoomPreference minMaxZoomPreference;
  @override
  @JsonKey()
  final void Function(CameraPosition)? onCameraMove;
  @override
  @JsonKey()
  final EdgeInsets padding;
  @override
  @JsonKey()
  final bool compassEnabled;
  @override
  @JsonKey()
  final bool liteModeEnabled;
  @override
  @JsonKey()
  final String? mapStyle;
  @override
  @JsonKey()
  final Color? floatingControlsColor;
  @override
  @JsonKey()
  final Color? floatingControlsIconColor;
  @override
  @JsonKey()
  final IconData? mapTypeIcon;
  @override
  @JsonKey()
  final IconData? locationIcon;
  @override
  @JsonKey()
  final BitmapDescriptor? mainMarkerIcon;
  @override
  @JsonKey()
  final bool hideBottomCardOnKeyboard;
  @override
  @JsonKey()
  final String bottomCardTitle;
  @override
  @JsonKey()
  final CardType bottomCardType;
  @override
  @JsonKey()
  final ConfirmButtonBuilder confirmButton;
  @override
  @JsonKey()
  final BottomCardBuilder bottomCardBuilder;
  @override
  @JsonKey()
  final SearchBarBuilder searchBarBuilder;
  @override
  @JsonKey()
  final LocationSettings? locationSettings;
  @override
  @JsonKey()
  final Function(dynamic error)? onLocationError;
  @override
  @JsonKey()
  final bool hideMoreOptions;
  @override
  @JsonKey()
  final Widget? mapTypeButton;
  @override
  @JsonKey()
  final Widget? locationButton;
  @override
  @JsonKey()
  final String fabTooltip;
  final Map<String, LatLng>? _additionalMarkers;
  @override
  @JsonKey()
  Map<String, LatLng>? get additionalMarkers {
    final value = _additionalMarkers;
    if (value == null) return null;
    if (_additionalMarkers is EqualUnmodifiableMapView)
      return _additionalMarkers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, BitmapDescriptor>? _customMarkerIcons;
  @override
  @JsonKey()
  Map<String, BitmapDescriptor>? get customMarkerIcons {
    final value = _customMarkerIcons;
    if (value == null) return null;
    if (_customMarkerIcons is EqualUnmodifiableMapView)
      return _customMarkerIcons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, InfoWindow>? _customInfoWindows;
  @override
  @JsonKey()
  Map<String, InfoWindow>? get customInfoWindows {
    final value = _customInfoWindows;
    if (value == null) return null;
    if (_customInfoWindows is EqualUnmodifiableMapView)
      return _customInfoWindows;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, VoidCallback>? _onMarkerTapped;
  @override
  @JsonKey()
  Map<String, VoidCallback>? get onMarkerTapped {
    final value = _onMarkerTapped;
    if (value == null) return null;
    if (_onMarkerTapped is EqualUnmodifiableMapView) return _onMarkerTapped;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final Function(GoogleMapController)? onMapCreated;
  @override
  @JsonKey()
  final Function(MapType)? onMapTypeChanged;
  @override
  @JsonKey()
  final Function(Place?)? onSuggestionSelected;
  @override
  @JsonKey()
  final Function(Place?)? onNext;
  @override
  @JsonKey()
  final Function(Place?)? onAddressDecoded;
  @override
  @JsonKey()
  final Function(Place)? onAddressSelected;
  @override
  @JsonKey()
  final bool buildingsEnabled;
  @override
  @JsonKey()
  final CameraTargetBounds cameraTargetBounds;
  final Set<Circle> _circles;
  @override
  @JsonKey()
  Set<Circle> get circles {
    if (_circles is EqualUnmodifiableSetView) return _circles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_circles);
  }

  @override
  @JsonKey()
  final String? cloudMapId;
  @override
  @JsonKey()
  final bool fortyFiveDegreeImageryEnabled;
  final Set<Factory<OneSequenceGestureRecognizer>> _gestureRecognizers;
  @override
  @JsonKey()
  Set<Factory<OneSequenceGestureRecognizer>> get gestureRecognizers {
    if (_gestureRecognizers is EqualUnmodifiableSetView)
      return _gestureRecognizers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_gestureRecognizers);
  }

  @override
  @JsonKey()
  final bool indoorViewEnabled;
  @override
  @JsonKey()
  final TextDirection? layoutDirection;
  @override
  @JsonKey()
  final bool mapToolbarEnabled;
  @override
  @JsonKey()
  final VoidCallback? onCameraIdle;
  @override
  @JsonKey()
  final VoidCallback? onCameraMoveStarted;
  @override
  @JsonKey()
  final ArgumentCallback<LatLng>? onLongPress;
  final Set<Polygon> _polygons;
  @override
  @JsonKey()
  Set<Polygon> get polygons {
    if (_polygons is EqualUnmodifiableSetView) return _polygons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_polygons);
  }

  final Set<Polyline> _polylines;
  @override
  @JsonKey()
  Set<Polyline> get polylines {
    if (_polylines is EqualUnmodifiableSetView) return _polylines;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_polylines);
  }

  @override
  @JsonKey()
  final bool rotateGesturesEnabled;
  @override
  @JsonKey()
  final bool scrollGesturesEnabled;
  final Set<TileOverlay> _tileOverlays;
  @override
  @JsonKey()
  Set<TileOverlay> get tileOverlays {
    if (_tileOverlays is EqualUnmodifiableSetView) return _tileOverlays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_tileOverlays);
  }

  @override
  @JsonKey()
  final bool tiltGesturesEnabled;
  @override
  @JsonKey()
  final bool trafficEnabled;
  @override
  @JsonKey()
  final WebGestureHandling? webGestureHandling;
  @override
  @JsonKey()
  final bool zoomGesturesEnabled;
  final Set<ClusterManager> _clusterManagers;
  @override
  @JsonKey()
  Set<ClusterManager> get clusterManagers {
    if (_clusterManagers is EqualUnmodifiableSetView) return _clusterManagers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_clusterManagers);
  }

  final Set<GroundOverlay> _groundOverlays;
  @override
  @JsonKey()
  Set<GroundOverlay> get groundOverlays {
    if (_groundOverlays is EqualUnmodifiableSetView) return _groundOverlays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_groundOverlays);
  }

  final Set<Heatmap> _heatmaps;
  @override
  @JsonKey()
  Set<Heatmap> get heatmaps {
    if (_heatmaps is EqualUnmodifiableSetView) return _heatmaps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_heatmaps);
  }

  @override
  @JsonKey()
  final CardType cardType;
  @override
  @JsonKey()
  final Color? cardColor;
  @override
  @JsonKey()
  final BorderRadiusGeometry? cardRadius;
  @override
  @JsonKey()
  final BoxBorder? cardBorder;
  @override
  @JsonKey()
  final String noAddressFoundText;

  /// Create a copy of MapLocationPickerConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MapLocationPickerConfigCopyWith<_MapLocationPickerConfig> get copyWith =>
      __$MapLocationPickerConfigCopyWithImpl<_MapLocationPickerConfig>(
          this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MapLocationPickerConfig &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            const DeepCollectionEquality().equals(other.placesApi, placesApi) &&
            (identical(other.geocodingRadius, geocodingRadius) ||
                other.geocodingRadius == geocodingRadius) &&
            (identical(other.geocodingAllFields, geocodingAllFields) ||
                other.geocodingAllFields == geocodingAllFields) &&
            const DeepCollectionEquality()
                .equals(other._geocodingFields, _geocodingFields) &&
            const DeepCollectionEquality().equals(
                other.geocodingInstanceFields, geocodingInstanceFields) &&
            const DeepCollectionEquality()
                .equals(other.geocodingFilter, geocodingFilter) &&
            (identical(other.initialPosition, initialPosition) ||
                other.initialPosition == initialPosition) &&
            (identical(other.initialZoom, initialZoom) ||
                other.initialZoom == initialZoom) &&
            (identical(other.initialMapType, initialMapType) ||
                other.initialMapType == initialMapType) &&
            (identical(other.myLocationButtonEnabled, myLocationButtonEnabled) ||
                other.myLocationButtonEnabled == myLocationButtonEnabled) &&
            (identical(other.myLocationEnabled, myLocationEnabled) ||
                other.myLocationEnabled == myLocationEnabled) &&
            (identical(other.zoomControlsEnabled, zoomControlsEnabled) ||
                other.zoomControlsEnabled == zoomControlsEnabled) &&
            (identical(other.minMaxZoomPreference, minMaxZoomPreference) ||
                other.minMaxZoomPreference == minMaxZoomPreference) &&
            (identical(other.onCameraMove, onCameraMove) ||
                other.onCameraMove == onCameraMove) &&
            (identical(other.padding, padding) || other.padding == padding) &&
            (identical(other.compassEnabled, compassEnabled) ||
                other.compassEnabled == compassEnabled) &&
            (identical(other.liteModeEnabled, liteModeEnabled) ||
                other.liteModeEnabled == liteModeEnabled) &&
            (identical(other.mapStyle, mapStyle) ||
                other.mapStyle == mapStyle) &&
            (identical(other.floatingControlsColor, floatingControlsColor) ||
                other.floatingControlsColor == floatingControlsColor) &&
            (identical(other.floatingControlsIconColor, floatingControlsIconColor) ||
                other.floatingControlsIconColor == floatingControlsIconColor) &&
            (identical(other.mapTypeIcon, mapTypeIcon) ||
                other.mapTypeIcon == mapTypeIcon) &&
            (identical(other.locationIcon, locationIcon) ||
                other.locationIcon == locationIcon) &&
            (identical(other.mainMarkerIcon, mainMarkerIcon) ||
                other.mainMarkerIcon == mainMarkerIcon) &&
            (identical(other.hideBottomCardOnKeyboard, hideBottomCardOnKeyboard) ||
                other.hideBottomCardOnKeyboard == hideBottomCardOnKeyboard) &&
            (identical(other.bottomCardTitle, bottomCardTitle) ||
                other.bottomCardTitle == bottomCardTitle) &&
            (identical(other.bottomCardType, bottomCardType) ||
                other.bottomCardType == bottomCardType) &&
            (identical(other.confirmButton, confirmButton) ||
                other.confirmButton == confirmButton) &&
            (identical(other.bottomCardBuilder, bottomCardBuilder) ||
                other.bottomCardBuilder == bottomCardBuilder) &&
            (identical(other.searchBarBuilder, searchBarBuilder) ||
                other.searchBarBuilder == searchBarBuilder) &&
            (identical(other.locationSettings, locationSettings) ||
                other.locationSettings == locationSettings) &&
            (identical(other.onLocationError, onLocationError) ||
                other.onLocationError == onLocationError) &&
            (identical(other.hideMoreOptions, hideMoreOptions) ||
                other.hideMoreOptions == hideMoreOptions) &&
            (identical(other.mapTypeButton, mapTypeButton) ||
                other.mapTypeButton == mapTypeButton) &&
            (identical(other.locationButton, locationButton) || other.locationButton == locationButton) &&
            (identical(other.fabTooltip, fabTooltip) || other.fabTooltip == fabTooltip) &&
            const DeepCollectionEquality().equals(other._additionalMarkers, _additionalMarkers) &&
            const DeepCollectionEquality().equals(other._customMarkerIcons, _customMarkerIcons) &&
            const DeepCollectionEquality().equals(other._customInfoWindows, _customInfoWindows) &&
            const DeepCollectionEquality().equals(other._onMarkerTapped, _onMarkerTapped) &&
            (identical(other.onMapCreated, onMapCreated) || other.onMapCreated == onMapCreated) &&
            (identical(other.onMapTypeChanged, onMapTypeChanged) || other.onMapTypeChanged == onMapTypeChanged) &&
            (identical(other.onSuggestionSelected, onSuggestionSelected) || other.onSuggestionSelected == onSuggestionSelected) &&
            (identical(other.onNext, onNext) || other.onNext == onNext) &&
            (identical(other.onAddressDecoded, onAddressDecoded) || other.onAddressDecoded == onAddressDecoded) &&
            (identical(other.onAddressSelected, onAddressSelected) || other.onAddressSelected == onAddressSelected) &&
            (identical(other.buildingsEnabled, buildingsEnabled) || other.buildingsEnabled == buildingsEnabled) &&
            (identical(other.cameraTargetBounds, cameraTargetBounds) || other.cameraTargetBounds == cameraTargetBounds) &&
            const DeepCollectionEquality().equals(other._circles, _circles) &&
            (identical(other.cloudMapId, cloudMapId) || other.cloudMapId == cloudMapId) &&
            (identical(other.fortyFiveDegreeImageryEnabled, fortyFiveDegreeImageryEnabled) || other.fortyFiveDegreeImageryEnabled == fortyFiveDegreeImageryEnabled) &&
            const DeepCollectionEquality().equals(other._gestureRecognizers, _gestureRecognizers) &&
            (identical(other.indoorViewEnabled, indoorViewEnabled) || other.indoorViewEnabled == indoorViewEnabled) &&
            (identical(other.layoutDirection, layoutDirection) || other.layoutDirection == layoutDirection) &&
            (identical(other.mapToolbarEnabled, mapToolbarEnabled) || other.mapToolbarEnabled == mapToolbarEnabled) &&
            (identical(other.onCameraIdle, onCameraIdle) || other.onCameraIdle == onCameraIdle) &&
            (identical(other.onCameraMoveStarted, onCameraMoveStarted) || other.onCameraMoveStarted == onCameraMoveStarted) &&
            (identical(other.onLongPress, onLongPress) || other.onLongPress == onLongPress) &&
            const DeepCollectionEquality().equals(other._polygons, _polygons) &&
            const DeepCollectionEquality().equals(other._polylines, _polylines) &&
            (identical(other.rotateGesturesEnabled, rotateGesturesEnabled) || other.rotateGesturesEnabled == rotateGesturesEnabled) &&
            (identical(other.scrollGesturesEnabled, scrollGesturesEnabled) || other.scrollGesturesEnabled == scrollGesturesEnabled) &&
            const DeepCollectionEquality().equals(other._tileOverlays, _tileOverlays) &&
            (identical(other.tiltGesturesEnabled, tiltGesturesEnabled) || other.tiltGesturesEnabled == tiltGesturesEnabled) &&
            (identical(other.trafficEnabled, trafficEnabled) || other.trafficEnabled == trafficEnabled) &&
            (identical(other.webGestureHandling, webGestureHandling) || other.webGestureHandling == webGestureHandling) &&
            (identical(other.zoomGesturesEnabled, zoomGesturesEnabled) || other.zoomGesturesEnabled == zoomGesturesEnabled) &&
            const DeepCollectionEquality().equals(other._clusterManagers, _clusterManagers) &&
            const DeepCollectionEquality().equals(other._groundOverlays, _groundOverlays) &&
            const DeepCollectionEquality().equals(other._heatmaps, _heatmaps) &&
            (identical(other.cardType, cardType) || other.cardType == cardType) &&
            (identical(other.cardColor, cardColor) || other.cardColor == cardColor) &&
            (identical(other.cardRadius, cardRadius) || other.cardRadius == cardRadius) &&
            (identical(other.cardBorder, cardBorder) || other.cardBorder == cardBorder) &&
            (identical(other.noAddressFoundText, noAddressFoundText) || other.noAddressFoundText == noAddressFoundText));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        apiKey,
        const DeepCollectionEquality().hash(placesApi),
        geocodingRadius,
        geocodingAllFields,
        const DeepCollectionEquality().hash(_geocodingFields),
        const DeepCollectionEquality().hash(geocodingInstanceFields),
        const DeepCollectionEquality().hash(geocodingFilter),
        initialPosition,
        initialZoom,
        initialMapType,
        myLocationButtonEnabled,
        myLocationEnabled,
        zoomControlsEnabled,
        minMaxZoomPreference,
        onCameraMove,
        padding,
        compassEnabled,
        liteModeEnabled,
        mapStyle,
        floatingControlsColor,
        floatingControlsIconColor,
        mapTypeIcon,
        locationIcon,
        mainMarkerIcon,
        hideBottomCardOnKeyboard,
        bottomCardTitle,
        bottomCardType,
        confirmButton,
        bottomCardBuilder,
        searchBarBuilder,
        locationSettings,
        onLocationError,
        hideMoreOptions,
        mapTypeButton,
        locationButton,
        fabTooltip,
        const DeepCollectionEquality().hash(_additionalMarkers),
        const DeepCollectionEquality().hash(_customMarkerIcons),
        const DeepCollectionEquality().hash(_customInfoWindows),
        const DeepCollectionEquality().hash(_onMarkerTapped),
        onMapCreated,
        onMapTypeChanged,
        onSuggestionSelected,
        onNext,
        onAddressDecoded,
        onAddressSelected,
        buildingsEnabled,
        cameraTargetBounds,
        const DeepCollectionEquality().hash(_circles),
        cloudMapId,
        fortyFiveDegreeImageryEnabled,
        const DeepCollectionEquality().hash(_gestureRecognizers),
        indoorViewEnabled,
        layoutDirection,
        mapToolbarEnabled,
        onCameraIdle,
        onCameraMoveStarted,
        onLongPress,
        const DeepCollectionEquality().hash(_polygons),
        const DeepCollectionEquality().hash(_polylines),
        rotateGesturesEnabled,
        scrollGesturesEnabled,
        const DeepCollectionEquality().hash(_tileOverlays),
        tiltGesturesEnabled,
        trafficEnabled,
        webGestureHandling,
        zoomGesturesEnabled,
        const DeepCollectionEquality().hash(_clusterManagers),
        const DeepCollectionEquality().hash(_groundOverlays),
        const DeepCollectionEquality().hash(_heatmaps),
        cardType,
        cardColor,
        cardRadius,
        cardBorder,
        noAddressFoundText
      ]);

  @override
  String toString() {
    return 'MapLocationPickerConfig(apiKey: $apiKey, placesApi: $placesApi, geocodingRadius: $geocodingRadius, geocodingAllFields: $geocodingAllFields, geocodingFields: $geocodingFields, geocodingInstanceFields: $geocodingInstanceFields, geocodingFilter: $geocodingFilter, initialPosition: $initialPosition, initialZoom: $initialZoom, initialMapType: $initialMapType, myLocationButtonEnabled: $myLocationButtonEnabled, myLocationEnabled: $myLocationEnabled, zoomControlsEnabled: $zoomControlsEnabled, minMaxZoomPreference: $minMaxZoomPreference, onCameraMove: $onCameraMove, padding: $padding, compassEnabled: $compassEnabled, liteModeEnabled: $liteModeEnabled, mapStyle: $mapStyle, floatingControlsColor: $floatingControlsColor, floatingControlsIconColor: $floatingControlsIconColor, mapTypeIcon: $mapTypeIcon, locationIcon: $locationIcon, mainMarkerIcon: $mainMarkerIcon, hideBottomCardOnKeyboard: $hideBottomCardOnKeyboard, bottomCardTitle: $bottomCardTitle, bottomCardType: $bottomCardType, confirmButton: $confirmButton, bottomCardBuilder: $bottomCardBuilder, searchBarBuilder: $searchBarBuilder, locationSettings: $locationSettings, onLocationError: $onLocationError, hideMoreOptions: $hideMoreOptions, mapTypeButton: $mapTypeButton, locationButton: $locationButton, fabTooltip: $fabTooltip, additionalMarkers: $additionalMarkers, customMarkerIcons: $customMarkerIcons, customInfoWindows: $customInfoWindows, onMarkerTapped: $onMarkerTapped, onMapCreated: $onMapCreated, onMapTypeChanged: $onMapTypeChanged, onSuggestionSelected: $onSuggestionSelected, onNext: $onNext, onAddressDecoded: $onAddressDecoded, onAddressSelected: $onAddressSelected, buildingsEnabled: $buildingsEnabled, cameraTargetBounds: $cameraTargetBounds, circles: $circles, cloudMapId: $cloudMapId, fortyFiveDegreeImageryEnabled: $fortyFiveDegreeImageryEnabled, gestureRecognizers: $gestureRecognizers, indoorViewEnabled: $indoorViewEnabled, layoutDirection: $layoutDirection, mapToolbarEnabled: $mapToolbarEnabled, onCameraIdle: $onCameraIdle, onCameraMoveStarted: $onCameraMoveStarted, onLongPress: $onLongPress, polygons: $polygons, polylines: $polylines, rotateGesturesEnabled: $rotateGesturesEnabled, scrollGesturesEnabled: $scrollGesturesEnabled, tileOverlays: $tileOverlays, tiltGesturesEnabled: $tiltGesturesEnabled, trafficEnabled: $trafficEnabled, webGestureHandling: $webGestureHandling, zoomGesturesEnabled: $zoomGesturesEnabled, clusterManagers: $clusterManagers, groundOverlays: $groundOverlays, heatmaps: $heatmaps, cardType: $cardType, cardColor: $cardColor, cardRadius: $cardRadius, cardBorder: $cardBorder, noAddressFoundText: $noAddressFoundText)';
  }
}

/// @nodoc
abstract mixin class _$MapLocationPickerConfigCopyWith<$Res>
    implements $MapLocationPickerConfigCopyWith<$Res> {
  factory _$MapLocationPickerConfigCopyWith(_MapLocationPickerConfig value,
          $Res Function(_MapLocationPickerConfig) _then) =
      __$MapLocationPickerConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String apiKey,
      PlacesAPINew? placesApi,
      double geocodingRadius,
      bool geocodingAllFields,
      List<String>? geocodingFields,
      PlacesResponse? geocodingInstanceFields,
      NearbySearchFilter? geocodingFilter,
      LatLng initialPosition,
      double initialZoom,
      MapType initialMapType,
      bool myLocationButtonEnabled,
      bool myLocationEnabled,
      bool zoomControlsEnabled,
      MinMaxZoomPreference minMaxZoomPreference,
      void Function(CameraPosition)? onCameraMove,
      EdgeInsets padding,
      bool compassEnabled,
      bool liteModeEnabled,
      String? mapStyle,
      Color? floatingControlsColor,
      Color? floatingControlsIconColor,
      IconData? mapTypeIcon,
      IconData? locationIcon,
      BitmapDescriptor? mainMarkerIcon,
      bool hideBottomCardOnKeyboard,
      String bottomCardTitle,
      CardType bottomCardType,
      ConfirmButtonBuilder confirmButton,
      BottomCardBuilder bottomCardBuilder,
      SearchBarBuilder searchBarBuilder,
      LocationSettings? locationSettings,
      Function(dynamic error)? onLocationError,
      bool hideMoreOptions,
      Widget? mapTypeButton,
      Widget? locationButton,
      String fabTooltip,
      Map<String, LatLng>? additionalMarkers,
      Map<String, BitmapDescriptor>? customMarkerIcons,
      Map<String, InfoWindow>? customInfoWindows,
      Map<String, VoidCallback>? onMarkerTapped,
      Function(GoogleMapController)? onMapCreated,
      Function(MapType)? onMapTypeChanged,
      Function(Place?)? onSuggestionSelected,
      Function(Place?)? onNext,
      Function(Place?)? onAddressDecoded,
      Function(Place)? onAddressSelected,
      bool buildingsEnabled,
      CameraTargetBounds cameraTargetBounds,
      Set<Circle> circles,
      String? cloudMapId,
      bool fortyFiveDegreeImageryEnabled,
      Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers,
      bool indoorViewEnabled,
      TextDirection? layoutDirection,
      bool mapToolbarEnabled,
      VoidCallback? onCameraIdle,
      VoidCallback? onCameraMoveStarted,
      ArgumentCallback<LatLng>? onLongPress,
      Set<Polygon> polygons,
      Set<Polyline> polylines,
      bool rotateGesturesEnabled,
      bool scrollGesturesEnabled,
      Set<TileOverlay> tileOverlays,
      bool tiltGesturesEnabled,
      bool trafficEnabled,
      WebGestureHandling? webGestureHandling,
      bool zoomGesturesEnabled,
      Set<ClusterManager> clusterManagers,
      Set<GroundOverlay> groundOverlays,
      Set<Heatmap> heatmaps,
      CardType cardType,
      Color? cardColor,
      BorderRadiusGeometry? cardRadius,
      BoxBorder? cardBorder,
      String noAddressFoundText});
}

/// @nodoc
class __$MapLocationPickerConfigCopyWithImpl<$Res>
    implements _$MapLocationPickerConfigCopyWith<$Res> {
  __$MapLocationPickerConfigCopyWithImpl(this._self, this._then);

  final _MapLocationPickerConfig _self;
  final $Res Function(_MapLocationPickerConfig) _then;

  /// Create a copy of MapLocationPickerConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? apiKey = null,
    Object? placesApi = freezed,
    Object? geocodingRadius = null,
    Object? geocodingAllFields = null,
    Object? geocodingFields = freezed,
    Object? geocodingInstanceFields = freezed,
    Object? geocodingFilter = freezed,
    Object? initialPosition = null,
    Object? initialZoom = null,
    Object? initialMapType = null,
    Object? myLocationButtonEnabled = null,
    Object? myLocationEnabled = null,
    Object? zoomControlsEnabled = null,
    Object? minMaxZoomPreference = null,
    Object? onCameraMove = freezed,
    Object? padding = null,
    Object? compassEnabled = null,
    Object? liteModeEnabled = null,
    Object? mapStyle = freezed,
    Object? floatingControlsColor = freezed,
    Object? floatingControlsIconColor = freezed,
    Object? mapTypeIcon = freezed,
    Object? locationIcon = freezed,
    Object? mainMarkerIcon = freezed,
    Object? hideBottomCardOnKeyboard = null,
    Object? bottomCardTitle = null,
    Object? bottomCardType = null,
    Object? confirmButton = freezed,
    Object? bottomCardBuilder = freezed,
    Object? searchBarBuilder = freezed,
    Object? locationSettings = freezed,
    Object? onLocationError = freezed,
    Object? hideMoreOptions = null,
    Object? mapTypeButton = freezed,
    Object? locationButton = freezed,
    Object? fabTooltip = null,
    Object? additionalMarkers = freezed,
    Object? customMarkerIcons = freezed,
    Object? customInfoWindows = freezed,
    Object? onMarkerTapped = freezed,
    Object? onMapCreated = freezed,
    Object? onMapTypeChanged = freezed,
    Object? onSuggestionSelected = freezed,
    Object? onNext = freezed,
    Object? onAddressDecoded = freezed,
    Object? onAddressSelected = freezed,
    Object? buildingsEnabled = null,
    Object? cameraTargetBounds = null,
    Object? circles = null,
    Object? cloudMapId = freezed,
    Object? fortyFiveDegreeImageryEnabled = null,
    Object? gestureRecognizers = null,
    Object? indoorViewEnabled = null,
    Object? layoutDirection = freezed,
    Object? mapToolbarEnabled = null,
    Object? onCameraIdle = freezed,
    Object? onCameraMoveStarted = freezed,
    Object? onLongPress = freezed,
    Object? polygons = null,
    Object? polylines = null,
    Object? rotateGesturesEnabled = null,
    Object? scrollGesturesEnabled = null,
    Object? tileOverlays = null,
    Object? tiltGesturesEnabled = null,
    Object? trafficEnabled = null,
    Object? webGestureHandling = freezed,
    Object? zoomGesturesEnabled = null,
    Object? clusterManagers = null,
    Object? groundOverlays = null,
    Object? heatmaps = null,
    Object? cardType = null,
    Object? cardColor = freezed,
    Object? cardRadius = freezed,
    Object? cardBorder = freezed,
    Object? noAddressFoundText = null,
  }) {
    return _then(_MapLocationPickerConfig(
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      placesApi: freezed == placesApi
          ? _self.placesApi
          : placesApi // ignore: cast_nullable_to_non_nullable
              as PlacesAPINew?,
      geocodingRadius: null == geocodingRadius
          ? _self.geocodingRadius
          : geocodingRadius // ignore: cast_nullable_to_non_nullable
              as double,
      geocodingAllFields: null == geocodingAllFields
          ? _self.geocodingAllFields
          : geocodingAllFields // ignore: cast_nullable_to_non_nullable
              as bool,
      geocodingFields: freezed == geocodingFields
          ? _self._geocodingFields
          : geocodingFields // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      geocodingInstanceFields: freezed == geocodingInstanceFields
          ? _self.geocodingInstanceFields
          : geocodingInstanceFields // ignore: cast_nullable_to_non_nullable
              as PlacesResponse?,
      geocodingFilter: freezed == geocodingFilter
          ? _self.geocodingFilter
          : geocodingFilter // ignore: cast_nullable_to_non_nullable
              as NearbySearchFilter?,
      initialPosition: null == initialPosition
          ? _self.initialPosition
          : initialPosition // ignore: cast_nullable_to_non_nullable
              as LatLng,
      initialZoom: null == initialZoom
          ? _self.initialZoom
          : initialZoom // ignore: cast_nullable_to_non_nullable
              as double,
      initialMapType: null == initialMapType
          ? _self.initialMapType
          : initialMapType // ignore: cast_nullable_to_non_nullable
              as MapType,
      myLocationButtonEnabled: null == myLocationButtonEnabled
          ? _self.myLocationButtonEnabled
          : myLocationButtonEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      myLocationEnabled: null == myLocationEnabled
          ? _self.myLocationEnabled
          : myLocationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      zoomControlsEnabled: null == zoomControlsEnabled
          ? _self.zoomControlsEnabled
          : zoomControlsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      minMaxZoomPreference: null == minMaxZoomPreference
          ? _self.minMaxZoomPreference
          : minMaxZoomPreference // ignore: cast_nullable_to_non_nullable
              as MinMaxZoomPreference,
      onCameraMove: freezed == onCameraMove
          ? _self.onCameraMove
          : onCameraMove // ignore: cast_nullable_to_non_nullable
              as void Function(CameraPosition)?,
      padding: null == padding
          ? _self.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
      compassEnabled: null == compassEnabled
          ? _self.compassEnabled
          : compassEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      liteModeEnabled: null == liteModeEnabled
          ? _self.liteModeEnabled
          : liteModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      mapStyle: freezed == mapStyle
          ? _self.mapStyle
          : mapStyle // ignore: cast_nullable_to_non_nullable
              as String?,
      floatingControlsColor: freezed == floatingControlsColor
          ? _self.floatingControlsColor
          : floatingControlsColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      floatingControlsIconColor: freezed == floatingControlsIconColor
          ? _self.floatingControlsIconColor
          : floatingControlsIconColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      mapTypeIcon: freezed == mapTypeIcon
          ? _self.mapTypeIcon
          : mapTypeIcon // ignore: cast_nullable_to_non_nullable
              as IconData?,
      locationIcon: freezed == locationIcon
          ? _self.locationIcon
          : locationIcon // ignore: cast_nullable_to_non_nullable
              as IconData?,
      mainMarkerIcon: freezed == mainMarkerIcon
          ? _self.mainMarkerIcon
          : mainMarkerIcon // ignore: cast_nullable_to_non_nullable
              as BitmapDescriptor?,
      hideBottomCardOnKeyboard: null == hideBottomCardOnKeyboard
          ? _self.hideBottomCardOnKeyboard
          : hideBottomCardOnKeyboard // ignore: cast_nullable_to_non_nullable
              as bool,
      bottomCardTitle: null == bottomCardTitle
          ? _self.bottomCardTitle
          : bottomCardTitle // ignore: cast_nullable_to_non_nullable
              as String,
      bottomCardType: null == bottomCardType
          ? _self.bottomCardType
          : bottomCardType // ignore: cast_nullable_to_non_nullable
              as CardType,
      confirmButton: freezed == confirmButton
          ? _self.confirmButton
          : confirmButton // ignore: cast_nullable_to_non_nullable
              as ConfirmButtonBuilder,
      bottomCardBuilder: freezed == bottomCardBuilder
          ? _self.bottomCardBuilder
          : bottomCardBuilder // ignore: cast_nullable_to_non_nullable
              as BottomCardBuilder,
      searchBarBuilder: freezed == searchBarBuilder
          ? _self.searchBarBuilder
          : searchBarBuilder // ignore: cast_nullable_to_non_nullable
              as SearchBarBuilder,
      locationSettings: freezed == locationSettings
          ? _self.locationSettings
          : locationSettings // ignore: cast_nullable_to_non_nullable
              as LocationSettings?,
      onLocationError: freezed == onLocationError
          ? _self.onLocationError
          : onLocationError // ignore: cast_nullable_to_non_nullable
              as Function(dynamic error)?,
      hideMoreOptions: null == hideMoreOptions
          ? _self.hideMoreOptions
          : hideMoreOptions // ignore: cast_nullable_to_non_nullable
              as bool,
      mapTypeButton: freezed == mapTypeButton
          ? _self.mapTypeButton
          : mapTypeButton // ignore: cast_nullable_to_non_nullable
              as Widget?,
      locationButton: freezed == locationButton
          ? _self.locationButton
          : locationButton // ignore: cast_nullable_to_non_nullable
              as Widget?,
      fabTooltip: null == fabTooltip
          ? _self.fabTooltip
          : fabTooltip // ignore: cast_nullable_to_non_nullable
              as String,
      additionalMarkers: freezed == additionalMarkers
          ? _self._additionalMarkers
          : additionalMarkers // ignore: cast_nullable_to_non_nullable
              as Map<String, LatLng>?,
      customMarkerIcons: freezed == customMarkerIcons
          ? _self._customMarkerIcons
          : customMarkerIcons // ignore: cast_nullable_to_non_nullable
              as Map<String, BitmapDescriptor>?,
      customInfoWindows: freezed == customInfoWindows
          ? _self._customInfoWindows
          : customInfoWindows // ignore: cast_nullable_to_non_nullable
              as Map<String, InfoWindow>?,
      onMarkerTapped: freezed == onMarkerTapped
          ? _self._onMarkerTapped
          : onMarkerTapped // ignore: cast_nullable_to_non_nullable
              as Map<String, VoidCallback>?,
      onMapCreated: freezed == onMapCreated
          ? _self.onMapCreated
          : onMapCreated // ignore: cast_nullable_to_non_nullable
              as Function(GoogleMapController)?,
      onMapTypeChanged: freezed == onMapTypeChanged
          ? _self.onMapTypeChanged
          : onMapTypeChanged // ignore: cast_nullable_to_non_nullable
              as Function(MapType)?,
      onSuggestionSelected: freezed == onSuggestionSelected
          ? _self.onSuggestionSelected
          : onSuggestionSelected // ignore: cast_nullable_to_non_nullable
              as Function(Place?)?,
      onNext: freezed == onNext
          ? _self.onNext
          : onNext // ignore: cast_nullable_to_non_nullable
              as Function(Place?)?,
      onAddressDecoded: freezed == onAddressDecoded
          ? _self.onAddressDecoded
          : onAddressDecoded // ignore: cast_nullable_to_non_nullable
              as Function(Place?)?,
      onAddressSelected: freezed == onAddressSelected
          ? _self.onAddressSelected
          : onAddressSelected // ignore: cast_nullable_to_non_nullable
              as Function(Place)?,
      buildingsEnabled: null == buildingsEnabled
          ? _self.buildingsEnabled
          : buildingsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      cameraTargetBounds: null == cameraTargetBounds
          ? _self.cameraTargetBounds
          : cameraTargetBounds // ignore: cast_nullable_to_non_nullable
              as CameraTargetBounds,
      circles: null == circles
          ? _self._circles
          : circles // ignore: cast_nullable_to_non_nullable
              as Set<Circle>,
      cloudMapId: freezed == cloudMapId
          ? _self.cloudMapId
          : cloudMapId // ignore: cast_nullable_to_non_nullable
              as String?,
      fortyFiveDegreeImageryEnabled: null == fortyFiveDegreeImageryEnabled
          ? _self.fortyFiveDegreeImageryEnabled
          : fortyFiveDegreeImageryEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      gestureRecognizers: null == gestureRecognizers
          ? _self._gestureRecognizers
          : gestureRecognizers // ignore: cast_nullable_to_non_nullable
              as Set<Factory<OneSequenceGestureRecognizer>>,
      indoorViewEnabled: null == indoorViewEnabled
          ? _self.indoorViewEnabled
          : indoorViewEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      layoutDirection: freezed == layoutDirection
          ? _self.layoutDirection
          : layoutDirection // ignore: cast_nullable_to_non_nullable
              as TextDirection?,
      mapToolbarEnabled: null == mapToolbarEnabled
          ? _self.mapToolbarEnabled
          : mapToolbarEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      onCameraIdle: freezed == onCameraIdle
          ? _self.onCameraIdle
          : onCameraIdle // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
      onCameraMoveStarted: freezed == onCameraMoveStarted
          ? _self.onCameraMoveStarted
          : onCameraMoveStarted // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
      onLongPress: freezed == onLongPress
          ? _self.onLongPress
          : onLongPress // ignore: cast_nullable_to_non_nullable
              as ArgumentCallback<LatLng>?,
      polygons: null == polygons
          ? _self._polygons
          : polygons // ignore: cast_nullable_to_non_nullable
              as Set<Polygon>,
      polylines: null == polylines
          ? _self._polylines
          : polylines // ignore: cast_nullable_to_non_nullable
              as Set<Polyline>,
      rotateGesturesEnabled: null == rotateGesturesEnabled
          ? _self.rotateGesturesEnabled
          : rotateGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      scrollGesturesEnabled: null == scrollGesturesEnabled
          ? _self.scrollGesturesEnabled
          : scrollGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      tileOverlays: null == tileOverlays
          ? _self._tileOverlays
          : tileOverlays // ignore: cast_nullable_to_non_nullable
              as Set<TileOverlay>,
      tiltGesturesEnabled: null == tiltGesturesEnabled
          ? _self.tiltGesturesEnabled
          : tiltGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      trafficEnabled: null == trafficEnabled
          ? _self.trafficEnabled
          : trafficEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      webGestureHandling: freezed == webGestureHandling
          ? _self.webGestureHandling
          : webGestureHandling // ignore: cast_nullable_to_non_nullable
              as WebGestureHandling?,
      zoomGesturesEnabled: null == zoomGesturesEnabled
          ? _self.zoomGesturesEnabled
          : zoomGesturesEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      clusterManagers: null == clusterManagers
          ? _self._clusterManagers
          : clusterManagers // ignore: cast_nullable_to_non_nullable
              as Set<ClusterManager>,
      groundOverlays: null == groundOverlays
          ? _self._groundOverlays
          : groundOverlays // ignore: cast_nullable_to_non_nullable
              as Set<GroundOverlay>,
      heatmaps: null == heatmaps
          ? _self._heatmaps
          : heatmaps // ignore: cast_nullable_to_non_nullable
              as Set<Heatmap>,
      cardType: null == cardType
          ? _self.cardType
          : cardType // ignore: cast_nullable_to_non_nullable
              as CardType,
      cardColor: freezed == cardColor
          ? _self.cardColor
          : cardColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      cardRadius: freezed == cardRadius
          ? _self.cardRadius
          : cardRadius // ignore: cast_nullable_to_non_nullable
              as BorderRadiusGeometry?,
      cardBorder: freezed == cardBorder
          ? _self.cardBorder
          : cardBorder // ignore: cast_nullable_to_non_nullable
              as BoxBorder?,
      noAddressFoundText: null == noAddressFoundText
          ? _self.noAddressFoundText
          : noAddressFoundText // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on

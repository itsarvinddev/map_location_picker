import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../map_location_picker.dart' hide Circle;
import 'card.dart';

/// The visual treatment of the search bar and bottom card.
enum CardType {
  /// An opaque surface-coloured card.
  defaultCard,

  /// A translucent, blurred card that lets the map show through.
  liquidCard,
}

/// A full-screen Google Maps location picker.
///
/// Wraps [MapLocationPickerView] in a [Scaffold]. Push it as a route and read
/// the result from [MapLocationPickerConfig.onNext]:
///
/// ```dart
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => MapLocationPicker(
///     config: MapLocationPickerConfig(
///       apiKey: 'YOUR_API_KEY',
///       onNext: (result) => Navigator.pop(context, result),
///     ),
///   ),
/// ));
/// ```
///
/// To embed the picker inside a screen you already have — a sheet, a tab, a
/// sized box — use [MapLocationPickerView] instead, which omits the [Scaffold].
/// Nesting this widget inside a `Column` or `SingleChildScrollView` gives the
/// inner [Scaffold] unbounded constraints and renders it squashed into a
/// corner.
class MapLocationPicker extends StatelessWidget {
  /// Map, UI and callback configuration.
  final MapLocationPickerConfig config;

  /// Configuration for the search field. When null, one is derived from
  /// [config] so the API key is never lost.
  final SearchConfig? searchConfig;

  /// A geocoding client to use instead of the one derived from [config].
  final GeoCodingConfig? geoCodingConfig;

  /// Drives the picker. When null, one is created and disposed internally.
  final MapLocationPickerController? controller;

  /// Creates a full-screen picker.
  const MapLocationPicker({
    super.key,
    required this.config,
    this.searchConfig,
    this.geoCodingConfig,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: config.cardColor,
      body: MapLocationPickerView(
        config: config,
        searchConfig: searchConfig,
        geoCodingConfig: geoCodingConfig,
        controller: controller,
      ),
    );
  }
}

/// The picker without a [Scaffold], for embedding in an existing screen.
///
/// Must be given bounded constraints — put it in a [SizedBox], an [Expanded],
/// or a [Scaffold] body:
///
/// ```dart
/// SizedBox(
///   height: 420,
///   child: MapLocationPickerView(config: myConfig),
/// )
/// ```
class MapLocationPickerView extends HookWidget {
  /// Map, UI and callback configuration.
  final MapLocationPickerConfig config;

  /// Configuration for the search field. When null, one is derived from
  /// [config].
  final SearchConfig? searchConfig;

  /// A geocoding client to use instead of the one derived from [config].
  final GeoCodingConfig? geoCodingConfig;

  /// Drives the picker. When null, one is created and disposed internally.
  final MapLocationPickerController? controller;

  /// Creates an embeddable picker.
  const MapLocationPickerView({
    super.key,
    required this.config,
    this.searchConfig,
    this.geoCodingConfig,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // An internally-owned controller is created once and disposed with the
    // widget. A caller-supplied one is left alone.
    final ownedController = useMemoized(() {
      if (controller != null) return null;
      return MapLocationPickerController(
        config: config,
        geoCodingConfig: geoCodingConfig,
      );
    }, [controller]);
    useEffect(() => ownedController?.dispose, [ownedController]);

    final ctrl = controller ?? ownedController!;

    // Keep the controller's view of the config current without moving the pin.
    useEffect(() {
      ctrl.updateConfig(config, geoCodingConfig: geoCodingConfig);
      return null;
    }, [config, geoCodingConfig, ctrl]);

    // Resolve the initial address once. LatLng(0,0) is a legitimate coordinate
    // in the Gulf of Guinea, so `skipInitialGeocode` is the opt-out rather
    // than treating (0,0) as a magic "unset" value.
    useEffect(() {
      if (!config.skipInitialGeocode) {
        ctrl.refreshAddress();
      }
      return null;
    }, [ctrl]);

    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) => _buildContent(context, ctrl),
    );
  }

  Widget _buildContent(BuildContext context, MapLocationPickerController ctrl) {
    final theme = Theme.of(context);
    // sizeOf/viewInsetsOf subscribe to just that slice of MediaQuery, so an
    // unrelated change (text scale, orientation) does not rebuild the map.
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final showBottomCard =
        !isKeyboardVisible || !config.hideBottomCardOnKeyboard;

    // Built once per frame. Handing a Positioned to bottomCardBuilder used to
    // trip "Positioned widgets must be placed inside Stack widgets", and
    // calling the builder twice created two live search fields.
    final searchBar = _buildSearchBar(context, ctrl);

    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMap(context, ctrl),
        if (config.showSearchBar)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child:
                    config.searchBarBuilder?.call(context, searchBar) ??
                    searchBar,
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildControls(
            context,
            ctrl,
            theme,
            showBottomCard,
            searchBar,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    MapLocationPickerController ctrl,
  ) {
    // Inheriting apiKey/placesApi means supplying a searchConfig no longer
    // silently blanks the key and leaves autocomplete permanently empty.
    final effectiveSearchConfig = searchConfig == null
        ? SearchConfig(apiKey: config.apiKey, placesApi: config.placesApi)
        : searchConfig!.copyWith(
            apiKey: searchConfig!.apiKey.isEmpty
                ? config.apiKey
                : searchConfig!.apiKey,
            placesApi: searchConfig!.placesApi ?? config.placesApi,
          );

    return PlacesAutocomplete(
      cardType: config.cardType,
      cardColor: config.cardColor,
      cardRadius: config.cardRadius,
      cardBorder: config.cardBorder,
      initialValue: effectiveSearchConfig.initialValue,
      config: effectiveSearchConfig,
      onError: config.onError,
      onGetDetails: ctrl.selectPlace,
    );
  }

  Widget _buildMap(BuildContext context, MapLocationPickerController ctrl) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: config.initialPosition,
        zoom: config.initialZoom,
      ),
      onTap: (latLng) =>
          ctrl.moveTo(latLng, reason: PositionChangeReason.mapTap),
      onMapCreated: ctrl.attachMap,
      minMaxZoomPreference: config.minMaxZoomPreference,
      onCameraMove: config.onCameraMove,
      markers: _createMarkers(ctrl),
      myLocationButtonEnabled: config.myLocationButtonEnabled,
      myLocationEnabled: config.myLocationEnabled,
      zoomControlsEnabled: config.zoomControlsEnabled,
      // Keeps the Google logo and the "terms" link clear of the bottom card,
      // which is a Maps Platform terms-of-service requirement.
      padding: config.padding == EdgeInsets.zero
          ? EdgeInsets.only(bottom: config.mapBottomInset)
          : config.padding,
      compassEnabled: config.compassEnabled,
      liteModeEnabled: config.liteModeEnabled,
      mapType: ctrl.mapType,
      style: config.mapStyle,
      buildingsEnabled: config.buildingsEnabled,
      cameraTargetBounds: config.cameraTargetBounds,
      circles: config.circles,
      // `mapId` only exists from google_maps_flutter 2.15, and the dependency
      // range deliberately reaches back to 2.13.1 so apps on older Flutter can
      // still resolve this package. Revisit when that floor is raised.
      // ignore: deprecated_member_use
      cloudMapId: config.cloudMapId,
      fortyFiveDegreeImageryEnabled: config.fortyFiveDegreeImageryEnabled,
      gestureRecognizers: config.gestureRecognizers,
      indoorViewEnabled: config.indoorViewEnabled,
      layoutDirection: config.layoutDirection,
      mapToolbarEnabled: config.mapToolbarEnabled,
      onCameraIdle: config.onCameraIdle,
      onCameraMoveStarted: config.onCameraMoveStarted,
      onLongPress: config.onLongPress,
      polygons: config.polygons,
      polylines: config.polylines,
      rotateGesturesEnabled: config.rotateGesturesEnabled,
      scrollGesturesEnabled: config.scrollGesturesEnabled,
      tileOverlays: config.tileOverlays,
      tiltGesturesEnabled: config.tiltGesturesEnabled,
      trafficEnabled: config.trafficEnabled,
      webGestureHandling: config.webGestureHandling,
      zoomGesturesEnabled: config.zoomGesturesEnabled,
      clusterManagers: config.clusterManagers,
      groundOverlays: config.groundOverlays,
      heatmaps: config.heatmaps,
    );
  }

  Widget _buildControls(
    BuildContext context,
    MapLocationPickerController ctrl,
    ThemeData theme,
    bool showBottomCard,
    Widget searchBar,
  ) {
    final strings = config.strings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (config.showMapTypeButton)
                config.mapTypeButton ??
                    Semantics(
                      button: true,
                      label: strings.mapTypeTooltip,
                      child: FloatingActionButton(
                        heroTag: 'map_location_picker_map_type',
                        mini: true,
                        elevation: 0,
                        tooltip: strings.mapTypeTooltip,
                        backgroundColor:
                            config.floatingControlsColor ??
                            theme.colorScheme.primary,
                        foregroundColor:
                            config.floatingControlsIconColor ??
                            theme.colorScheme.onPrimary,
                        onPressed: () => _showMapTypeSelector(context, ctrl),
                        child: Icon(config.mapTypeIcon ?? Icons.layers),
                      ),
                    ),
              if (config.showMapTypeButton && config.showMyLocationButton)
                const SizedBox(height: 8),
              if (config.showMyLocationButton)
                config.locationButton ??
                    Semantics(
                      button: true,
                      label: config.fabTooltip,
                      child: FloatingActionButton(
                        heroTag: 'map_location_picker_my_location',
                        mini: true,
                        elevation: 0,
                        tooltip: config.fabTooltip,
                        backgroundColor:
                            config.floatingControlsColor ??
                            theme.colorScheme.primary,
                        foregroundColor:
                            config.floatingControlsIconColor ??
                            theme.colorScheme.onPrimary,
                        onPressed: ctrl.goToCurrentLocation,
                        child: Icon(config.locationIcon ?? Icons.my_location),
                      ),
                    ),
            ],
          ),
        ),
        if (showBottomCard)
          config.bottomCardBuilder?.call(
                context,
                ctrl.result,
                ctrl.results,
                ctrl.address,
                ctrl.isLoading,
                ctrl.confirm,
                searchBar,
              ) ??
              defaultBottomCard(
                context,
                ctrl.result,
                ctrl.address,
                ctrl.isLoading,
                ctrl.results,
                config,
                ctrl.confirm,
                onResultSelected: ctrl.selectResult,
              ),
      ],
    );
  }

  Set<Marker> _createMarkers(MapLocationPickerController ctrl) {
    const mainId = MarkerId('main');
    final markers = <Marker>{
      Marker(
        markerId: mainId,
        position: ctrl.position,
        icon: config.mainMarkerIcon ?? BitmapDescriptor.defaultMarker,
        draggable: config.draggableMarker,
        onDragEnd: config.draggableMarker
            ? (latLng) =>
                  ctrl.moveTo(latLng, reason: PositionChangeReason.markerDrag)
            : null,
      ),
    };

    for (final entry
        in (config.additionalMarkers ?? const <String, LatLng>{}).entries) {
      // google_maps_flutter asserts on duplicate ids, so a caller using "main"
      // would otherwise crash the map.
      if (entry.key == 'main') continue;
      markers.add(
        Marker(
          markerId: MarkerId(entry.key),
          position: entry.value,
          icon:
              config.customMarkerIcons?[entry.key] ??
              BitmapDescriptor.defaultMarker,
          infoWindow: config.customInfoWindows?[entry.key] ?? InfoWindow.noText,
          onTap: config.onMarkerTapped?[entry.key],
        ),
      );
    }

    return markers;
  }

  void _showMapTypeSelector(
    BuildContext context,
    MapLocationPickerController ctrl,
  ) {
    final strings = config.strings;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black38,
      builder: (sheetContext) => Material(
        type: MaterialType.transparency,
        child: CupertinoActionSheet(
          title: Text(strings.mapTypeTitle),
          message: Text(strings.mapTypeMessage),
          actions: MapType.values
              .where((type) => type != MapType.none)
              .map(
                (type) => CupertinoActionSheetAction(
                  onPressed: () {
                    ctrl.setMapType(type);
                    Navigator.pop(sheetContext);
                  },
                  child: CupertinoListTile(
                    padding: EdgeInsets.zero,
                    leading: Icon(_mapTypeIcon(type), size: 20),
                    title: Text(
                      strings.mapTypeName(type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: ctrl.mapType == type
                        ? const Icon(Icons.check, size: 20)
                        : null,
                  ),
                ),
              )
              .toList(),
          cancelButton: CupertinoButton(
            minimumSize: const Size(double.infinity, 40),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: () => Navigator.pop(sheetContext),
            child: Text(strings.cancel),
          ),
        ),
      ),
    );
  }

  IconData _mapTypeIcon(MapType type) => switch (type) {
    MapType.normal => Icons.map_outlined,
    MapType.satellite => Icons.satellite_outlined,
    MapType.terrain => Icons.terrain_outlined,
    MapType.hybrid => CupertinoIcons.layers,
    _ => Icons.map_outlined,
  };
}

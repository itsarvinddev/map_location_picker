import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webapi/geocoding.dart';
import 'package:google_maps_webapi/places.dart';
import 'package:http/http.dart';

import 'autocomplete_view.dart';
import 'geocoding_service.dart';
import 'logger.dart';

/// Default radius for the map location picker.
const _radius = 16.0;

/// The main widget for the map location picker.
class MapLocationPicker extends HookWidget {
  /// The configuration for the map location picker.
  final MapLocationPickerConfig config;

  /// The configuration for the search autocomplete.
  final SearchConfig? searchConfig;

  /// The geocoding service to use for the map location picker.
  final GeoCodingConfig? geoCodingConfig;

  const MapLocationPicker({
    super.key,
    required this.config,
    this.searchConfig,
    this.geoCodingConfig,
  });

  @override
  Widget build(BuildContext context) {
    /// State management
    final position = useState(config.initialPosition);
    final address = useState("");
    final isLoading = useState(false);
    final mapControllerCompleter =
        useMemoized(() => Completer<GoogleMapController>());
    final markers = useState<Set<Marker>>({});
    final geoCodingResult = useState<GeocodingResult?>(null);
    final geoCodingResults = useState<List<GeocodingResult>>([]);
    final mapType = useState(config.initialMapType);

    final effectiveGeoCodingService = useMemoized(
      () =>
          geoCodingConfig ??
          GeoCodingConfig(
            apiKey: config.apiKey,
            httpClient: config.baseClient,
            apiHeaders: config.baseApiHeaders,
            baseUrl: config.baseUrl,
          ),
    );

    /// Initialize map
    useEffect(() {
      Future.microtask(() {
        markers.value = _createMarkers(position.value);
        if (config.initialPosition != const LatLng(0, 0)) {
          _getAddressForPosition(position.value, effectiveGeoCodingService,
              address, isLoading, geoCodingResult, geoCodingResults);
        }
      });
      return null;
    }, const []);

    final theme = Theme.of(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final shouldShowBottomCard =
        (!isKeyboardVisible || !config.hideBottomCardOnKeyboard);

    Widget buildSearchView() {
      Widget searchBar = PlacesAutocomplete(
        config: searchConfig ??
            SearchConfig(
              apiKey: config.apiKey,
              baseClient: config.baseClient,
              baseApiHeaders: config.baseApiHeaders,
              baseBaseUrl: config.baseUrl,
            ),
        onGetDetails: (details) => _handlePlaceDetails(
          details,
          context,
          position,
          mapControllerCompleter,
          address,
          effectiveGeoCodingService,
          isLoading,
          geoCodingResult,
          markers,
        ),
      );

      /// Search Bar
      return config.searchBarBuilder?.call(context, searchBar) ??
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: searchBar,
              ),
            ),
          );
    }

    Widget buildFloatingControls() {
      /// Floating Controls
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: false,
          removeTop: true,
          removeLeft: true,
          removeRight: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    /// Map Type Button
                    config.mapTypeButton ??
                        FloatingActionButton(
                          heroTag: "map_type_button",
                          mini: true,
                          elevation: 0,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              showDragHandle: true,
                              enableDrag: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(_radius),
                                  topRight: Radius.circular(_radius),
                                ),
                              ),
                              builder: (context) =>
                                  _buildMapTypeSelector(context, mapType),
                            );
                          },
                          tooltip: 'Map Type',
                          backgroundColor: config.floatingControlsColor ??
                              theme.colorScheme.primary,
                          foregroundColor: config.floatingControlsIconColor ??
                              theme.colorScheme.onPrimary,
                          child: Icon(config.mapTypeIcon ?? Icons.layers),
                        ),
                    const SizedBox(height: 8),

                    /// Location Button
                    config.locationButton ??
                        FloatingActionButton(
                          heroTag: "location_button",
                          mini: true,
                          elevation: 0,
                          tooltip: config.fabTooltip,
                          backgroundColor: config.floatingControlsColor ??
                              theme.colorScheme.primary,
                          foregroundColor: config.floatingControlsIconColor ??
                              theme.colorScheme.onPrimary,
                          onPressed: () => _getCurrentLocation(
                            position,
                            mapControllerCompleter,
                            effectiveGeoCodingService,
                            address,
                            isLoading,
                            geoCodingResult,
                            geoCodingResults,
                            markers,
                          ),
                          child: Icon(config.locationIcon ?? Icons.my_location),
                        ),
                  ],
                ),
              ),

              /// Bottom Card
              if (shouldShowBottomCard)
                config.bottomCardBuilder?.call(
                      context,
                      geoCodingResult.value,
                      address.value,
                      isLoading.value,
                      () => _handleNext(context, geoCodingResult.value),
                      buildSearchView(),
                    ) ??
                    _defaultBottomCard(
                      context,
                      geoCodingResult.value,
                      address.value,
                      isLoading.value,
                      geoCodingResults.value,
                      config,
                      () => _handleNext(context, geoCodingResult.value),
                    ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: CupertinoColors.systemBackground,
      body: Stack(
        children: [
          /// Google Map View
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position.value,
              zoom: config.initialZoom,
            ),
            onTap: (latLng) => _handleMapTap(
              latLng,
              mapControllerCompleter,
              position,
              effectiveGeoCodingService,
              address,
              isLoading,
              geoCodingResult,
              geoCodingResults,
              markers,
            ),
            onMapCreated: (controller) {
              mapControllerCompleter.complete(controller);
              config.onMapCreated?.call(controller);
            },
            minMaxZoomPreference: config.minMaxZoomPreference,
            onCameraMove: config.onCameraMove,
            markers: markers.value,
            myLocationButtonEnabled: config.myLocationButtonEnabled,
            myLocationEnabled: config.myLocationEnabled,
            zoomControlsEnabled: config.zoomControlsEnabled,
            padding: config.padding,
            compassEnabled: config.compassEnabled,
            liteModeEnabled: config.liteModeEnabled,
            mapType: mapType.value,
            style: config.mapStyle,
            buildingsEnabled: config.buildingsEnabled,
            cameraTargetBounds: config.cameraTargetBounds,
            circles: config.circles,
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
          ),

          /// Search view
          buildSearchView(),

          /// Floating controls
          buildFloatingControls(),
        ],
      ),
    );
  }

  Set<Marker> _createMarkers(LatLng position) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId("main"),
        position: position,
        icon: config.mainMarkerIcon ?? BitmapDescriptor.defaultMarker,
      ),
    };

    // Add additional markers
    if (config.additionalMarkers != null) {
      for (final entry in config.additionalMarkers!.entries) {
        markers.add(
          Marker(
            markerId: MarkerId(entry.key),
            position: entry.value,
            icon: config.customMarkerIcons?[entry.key] ??
                BitmapDescriptor.defaultMarker,
            infoWindow:
                config.customInfoWindows?[entry.key] ?? InfoWindow.noText,
            onTap: config.onMarkerTapped?[entry.key],
          ),
        );
      }
    }

    return markers;
  }

  Widget _buildMapTypeSelector(
      BuildContext context, ValueNotifier<MapType> mapType) {
    final mapTypeValues = MapType.values.where((type) => type != MapType.none);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: mapTypeValues.map((type) {
          final index = mapTypeValues.toList().indexOf(type);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: _buildBoxDecoration(
                context, index, index == mapTypeValues.length - 1),
            child: ListTile(
              selected: mapType.value == type,
              leading: Icon(_mapTypeIcon(type)),
              title: Text(_mapTypeName(type)),
              onTap: () {
                mapType.value = type;
                config.onMapTypeChanged?.call(type);
                Navigator.pop(context);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _mapTypeIcon(MapType type) {
    switch (type) {
      case MapType.normal:
        return Icons.map_outlined;
      case MapType.satellite:
        return Icons.satellite_outlined;
      case MapType.terrain:
        return Icons.terrain_outlined;
      case MapType.hybrid:
        return CupertinoIcons.layers;
      default:
        return Icons.map_outlined;
    }
  }

  String _mapTypeName(MapType type) {
    switch (type) {
      case MapType.normal:
        return 'Standard Map';
      case MapType.satellite:
        return 'Satellite Map';
      case MapType.terrain:
        return 'Terrain Map';
      case MapType.hybrid:
        return 'Hybrid Map';
      default:
        return 'Standard Map';
    }
  }

  Widget _defaultBottomCard(
    BuildContext context,
    GeocodingResult? result,
    String address,
    bool isLoading,
    List<GeocodingResult> results,
    MapLocationPickerConfig config,
    VoidCallback onNext,
  ) {
    final theme = Theme.of(context);
    return CupertinoActionSheet(
      title: config.bottomCardTitle.isNotEmpty
          ? Text(config.bottomCardTitle)
          : null,
      actions: [
        if (isLoading)
          CupertinoActionSheetAction(
            child: Text("Loading address..."),
            onPressed: () {},
          )
        else
          CupertinoActionSheetAction(
            child: Text(address),
            onPressed: onNext,
            isDefaultAction: true,
          ),
        if (results.isNotEmpty && !config.hideMoreOptions)
          CupertinoActionSheetAction(
            child: Text(
              "Show ${results.length} more options",
              style: theme.textTheme.bodySmall,
            ),
            onPressed: () => _showAddressOptions(context, results, config),
          ),
      ],
    );
  }

  BoxDecoration _buildBoxDecoration(
    BuildContext context,
    int index,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: CupertinoColors.systemFill,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(index == 0 ? _radius : 0),
        topRight: Radius.circular(index == 0 ? _radius : 0),
        bottomLeft: Radius.circular(isLast ? _radius : 0),
        bottomRight: Radius.circular(isLast ? _radius : 0),
      ),
      border: Border(
        bottom: isLast
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
      ),
    );
  }

  void _showAddressOptions(
    BuildContext context,
    List<GeocodingResult> results,
    MapLocationPickerConfig config,
  ) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      enableDrag: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_radius + 8),
          topRight: Radius.circular(_radius + 8),
        ),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: results.map((result) {
              final index = results.indexOf(result);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: _buildBoxDecoration(
                    context, index, index == results.length - 1),
                child: ListTile(
                  title: Text(
                    result.formattedAddress ?? "",
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  onTap: () {
                    config.onAddressSelected?.call(result);
                    _handleNext(context, result);
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation(
    ValueNotifier<LatLng> position,
    Completer<GoogleMapController> mapControllerCompleter,
    GeoCodingConfig geoCodingService,
    ValueNotifier<String> address,
    ValueNotifier<bool> isLoading,
    ValueNotifier<GeocodingResult?> geoCodingResult,
    ValueNotifier<List<GeocodingResult>> geoCodingResults,
    ValueNotifier<Set<Marker>> markers,
  ) async {
    try {
      isLoading.value = true;
      if (config.hasLocationPermission) {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          final newPermission = await Geolocator.requestPermission();
          if (newPermission != LocationPermission.whileInUse &&
              newPermission != LocationPermission.always) {
            return;
          }
        }

        final currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: config.locationSettings,
        );

        final newPosition =
            LatLng(currentPosition.latitude, currentPosition.longitude);

        position.value = newPosition;
        markers.value = _createMarkers(newPosition);

        final controller = await mapControllerCompleter.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newPosition,
              zoom: config.initialZoom,
            ),
          ),
        );

        await _getAddressForPosition(
          newPosition,
          geoCodingService,
          address,
          isLoading,
          geoCodingResult,
          geoCodingResults,
        );
      }
    } catch (e) {
      mapLogger.e("Error getting current location: $e");
      if (config.onLocationError != null) {
        config.onLocationError!(e);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleMapTap(
    LatLng latLng,
    Completer<GoogleMapController> mapControllerCompleter,
    ValueNotifier<LatLng> position,
    GeoCodingConfig geoCodingService,
    ValueNotifier<String> address,
    ValueNotifier<bool> isLoading,
    ValueNotifier<GeocodingResult?> geoCodingResult,
    ValueNotifier<List<GeocodingResult>> geoCodingResults,
    ValueNotifier<Set<Marker>> markers,
  ) async {
    try {
      position.value = latLng;
      markers.value = _createMarkers(latLng);

      final controller = await mapControllerCompleter.future;
      controller.animateCamera(CameraUpdate.newLatLng(latLng));

      await _getAddressForPosition(
        latLng,
        geoCodingService,
        address,
        isLoading,
        geoCodingResult,
        geoCodingResults,
      );
    } catch (e) {
      mapLogger.e("Error handling map tap: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getAddressForPosition(
    LatLng position,
    GeoCodingConfig geoCodingService,
    ValueNotifier<String> address,
    ValueNotifier<bool> isLoading,
    ValueNotifier<GeocodingResult?> geoCodingResult,
    ValueNotifier<List<GeocodingResult>> geoCodingResults,
  ) async {
    isLoading.value = true;
    try {
      final response = await geoCodingService.reverseGeocode(position);
      final result = response.$1;
      final results = response.$2;

      if (result != null) {
        address.value = result.formattedAddress ?? "Address not found";
        geoCodingResult.value = result;
        geoCodingResults.value = results;
        config.onAddressDecoded?.call(result);
      } else {
        address.value = "Address not found";
      }
    } catch (e) {
      mapLogger.e("Geocoding error: $e");
      address.value = "Error fetching address";
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePlaceDetails(
    PlacesDetailsResponse? details,
    BuildContext context,
    ValueNotifier<LatLng> position,
    Completer<GoogleMapController> mapControllerCompleter,
    ValueNotifier<String> address,
    GeoCodingConfig geoCodingService,
    ValueNotifier<bool> isLoading,
    ValueNotifier<GeocodingResult?> geoCodingResult,
    ValueNotifier<Set<Marker>> markers,
  ) {
    try {
      isLoading.value = true;
      if (details == null) return;
      final location = details.result.geometry?.location;
      if (location != null) {
        final newPosition = LatLng(location.lat, location.lng);
        position.value = newPosition;
        address.value = details.result.formattedAddress ?? "";

        // Update the map position
        mapControllerCompleter.future.then((controller) {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newPosition,
                zoom: config.initialZoom,
              ),
            ),
          );
          markers.value = _createMarkers(newPosition);
        });

        // Create a geocoding result from place details
        final result = GeocodingResult(
          geometry: details.result.geometry!,
          formattedAddress: details.result.formattedAddress,
          placeId: details.result.placeId,
          types: details.result.types,
        );

        geoCodingResult.value = result;
        config.onSuggestionSelected?.call(details);
      }
    } catch (e) {
      mapLogger.e("Error handling place details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _handleNext(BuildContext context, GeocodingResult? result) {
    config.onNext?.call(result);
  }
}

class MapLocationPickerConfig {
  // Core configuration
  final String apiKey;
  final Client? baseClient;
  final Map<String, String>? baseApiHeaders;
  final String? baseUrl;
  final LatLng initialPosition;
  final double initialZoom;
  final MapType initialMapType;

  // Visual customization
  final bool myLocationButtonEnabled;
  final bool myLocationEnabled;
  final bool zoomControlsEnabled;
  final MinMaxZoomPreference minMaxZoomPreference;
  final Function(CameraPosition)? onCameraMove;
  final EdgeInsets padding;
  final bool compassEnabled;
  final bool liteModeEnabled;
  final String? mapStyle;
  final Color? floatingControlsColor;
  final Color? floatingControlsIconColor;
  final IconData? mapTypeIcon;
  final IconData? locationIcon;
  final BitmapDescriptor? mainMarkerIcon;

  final bool hideBottomCardOnKeyboard;
  final String bottomCardTitle;
  final Widget Function(
    BuildContext context,
    GeocodingResult? result,
    String address,
    bool isLoading,
    VoidCallback onNext,
    Widget searchBar,
  )? bottomCardBuilder;

  final Widget Function(
    BuildContext context,
    Widget searchBar,
  )? searchBarBuilder;

  // Location services
  final bool hasLocationPermission;
  final LocationSettings? locationSettings;
  final Function(dynamic error)? onLocationError;

  // Behavior flags
  final bool hideMoreOptions;
  final Widget? mapTypeButton;
  final Widget? locationButton;
  final String fabTooltip;

  // Additional markers
  final Map<String, LatLng>? additionalMarkers;
  final Map<String, BitmapDescriptor>? customMarkerIcons;
  final Map<String, InfoWindow>? customInfoWindows;
  final Map<String, VoidCallback>? onMarkerTapped;

  // Callbacks
  final Function(GoogleMapController)? onMapCreated;
  final Function(MapType)? onMapTypeChanged;
  final Function(PlacesDetailsResponse?)? onSuggestionSelected;
  final Function(GeocodingResult?)? onNext;
  final Function(GeocodingResult?)? onAddressDecoded;
  final Function(GeocodingResult)? onAddressSelected;

  // Google Maps advanced properties
  final bool buildingsEnabled;
  final CameraTargetBounds cameraTargetBounds;
  final Set<Circle> circles;
  final String? cloudMapId;
  final bool fortyFiveDegreeImageryEnabled;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers;
  final bool indoorViewEnabled;
  final TextDirection? layoutDirection;
  final bool mapToolbarEnabled;
  final VoidCallback? onCameraIdle;
  final VoidCallback? onCameraMoveStarted;
  final ArgumentCallback<LatLng>? onLongPress;
  final Set<Polygon> polygons;
  final Set<Polyline> polylines;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final Set<TileOverlay> tileOverlays;
  final bool tiltGesturesEnabled;
  final bool trafficEnabled;
  final WebGestureHandling? webGestureHandling;
  final bool zoomGesturesEnabled;
  final Set<ClusterManager> clusterManagers;
  final Set<GroundOverlay> groundOverlays;
  final Set<Heatmap> heatmaps;

  const MapLocationPickerConfig({
    required this.apiKey,
    this.bottomCardBuilder,
    this.searchBarBuilder,
    this.baseClient,
    this.baseApiHeaders,
    this.baseUrl,
    this.initialPosition = const LatLng(28.8993468, 76.6250249),
    this.initialZoom = 14.0,
    this.initialMapType = MapType.normal,
    this.myLocationButtonEnabled = false,
    this.myLocationEnabled = false,
    this.zoomControlsEnabled = false,
    this.minMaxZoomPreference = MinMaxZoomPreference.unbounded,
    this.onCameraMove,
    this.padding = EdgeInsets.zero,
    this.compassEnabled = true,
    this.liteModeEnabled = false,
    this.mapStyle,
    this.hideBottomCardOnKeyboard = true,
    this.hasLocationPermission = true,
    this.locationSettings,
    this.onLocationError,
    this.hideMoreOptions = false,
    this.mapTypeButton,
    this.locationButton,
    this.fabTooltip = 'My Location',
    this.bottomCardTitle = 'Select your location',
    this.additionalMarkers,
    this.customMarkerIcons,
    this.customInfoWindows,
    this.onMarkerTapped,
    this.floatingControlsColor,
    this.floatingControlsIconColor,
    this.mapTypeIcon = CupertinoIcons.layers,
    this.locationIcon = Icons.my_location_outlined,
    this.mainMarkerIcon,
    this.onMapCreated,
    this.onMapTypeChanged,
    this.onSuggestionSelected,
    this.onNext,
    this.onAddressDecoded,
    this.onAddressSelected,
    this.buildingsEnabled = true,
    this.cameraTargetBounds = CameraTargetBounds.unbounded,
    this.circles = const <Circle>{},
    this.cloudMapId,
    this.fortyFiveDegreeImageryEnabled = false,
    this.gestureRecognizers = const <Factory<OneSequenceGestureRecognizer>>{},
    this.indoorViewEnabled = false,
    this.layoutDirection,
    this.mapToolbarEnabled = true,
    this.onCameraIdle,
    this.onCameraMoveStarted,
    this.onLongPress,
    this.polygons = const <Polygon>{},
    this.polylines = const <Polyline>{},
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.tileOverlays = const <TileOverlay>{},
    this.tiltGesturesEnabled = true,
    this.trafficEnabled = false,
    this.webGestureHandling,
    this.zoomGesturesEnabled = true,
    this.clusterManagers = const <ClusterManager>{},
    this.groundOverlays = const <GroundOverlay>{},
    this.heatmaps = const <Heatmap>{},
  });

  MapLocationPickerConfig copyWith({
    // Core configuration
    String? apiKey,
    Client? baseClient,
    Map<String, String>? baseApiHeaders,
    String? baseUrl,
    LatLng? initialPosition,
    double? initialZoom,
    MapType? initialMapType,

    // Visual customization
    bool? myLocationButtonEnabled,
    bool? myLocationEnabled,
    bool? zoomControlsEnabled,
    MinMaxZoomPreference? minMaxZoomPreference,
    Function(CameraPosition)? onCameraMove,
    EdgeInsets? padding,
    bool? compassEnabled,
    bool? liteModeEnabled,
    String? mapStyle,
    Color? floatingControlsColor,
    Color? floatingControlsIconColor,
    IconData? mapTypeIcon,
    IconData? locationIcon,
    BitmapDescriptor? mainMarkerIcon,

    // Search bar options
    bool? hideSearchBar,
    EdgeInsetsGeometry? topCardMargin,
    Color? topCardColor,
    ShapeBorder? topCardShape,
    BorderRadiusGeometry? borderRadius,

    // Bottom card options
    bool? hideBottomCard,
    bool? hideBottomCardOnKeyboard,
    ShapeBorder? bottomCardShape,
    EdgeInsetsGeometry? bottomCardMargin,
    Icon? bottomCardIcon,
    String? bottomCardTooltip,
    Color? bottomCardColor,
    TextStyle? bottomCardTextStyle,
    Widget Function(
      BuildContext context,
      GeocodingResult? result,
      String address,
      bool isLoading,
      VoidCallback onNext,
      Widget searchBar,
    )? bottomCardBuilder,

    // Search bar options
    Widget Function(
      BuildContext context,
      Widget searchBar,
    )? searchBarBuilder,

    // Location services
    bool? hasLocationPermission,
    LocationSettings? locationSettings,
    Function(dynamic error)? onLocationError,

    // Behavior flags
    bool? hideBackButton,
    bool? popOnNext,
    bool? hideMoreOptions,
    Widget? mapTypeButton,
    Widget? locationButton,
    String? fabTooltip,
    String? bottomCardTitle,

    // Additional markers
    Map<String, LatLng>? additionalMarkers,
    Map<String, BitmapDescriptor>? customMarkerIcons,
    Map<String, InfoWindow>? customInfoWindows,
    Map<String, VoidCallback>? onMarkerTapped,

    // Safe area
    bool? safeAreaBottom,
    bool? safeAreaLeft,
    bool? safeAreaMaintainBottomViewPadding,
    EdgeInsets? safeAreaMinimum,
    bool? safeAreaRight,
    bool? safeAreaTop,

    // Callbacks
    Function(GoogleMapController)? onMapCreated,
    Function(MapType)? onMapTypeChanged,
    Function(PlacesDetailsResponse?)? onSuggestionSelected,
    Function(GeocodingResult?)? onNext,
    Function(GeocodingResult?)? onAddressDecoded,
    Function(GeocodingResult)? onAddressSelected,

    // Google Maps advanced properties
    bool? buildingsEnabled,
    CameraTargetBounds? cameraTargetBounds,
    Set<Circle>? circles,
    String? cloudMapId,
    bool? fortyFiveDegreeImageryEnabled,
    Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers,
    bool? indoorViewEnabled,
    TextDirection? layoutDirection,
    bool? mapToolbarEnabled,
    VoidCallback? onCameraIdle,
    VoidCallback? onCameraMoveStarted,
    ArgumentCallback<LatLng>? onLongPress,
    Set<Polygon>? polygons,
    Set<Polyline>? polylines,
    bool? rotateGesturesEnabled,
    bool? scrollGesturesEnabled,
    Set<TileOverlay>? tileOverlays,
    bool? tiltGesturesEnabled,
    bool? trafficEnabled,
    WebGestureHandling? webGestureHandling,
    bool? zoomGesturesEnabled,
    Set<ClusterManager>? clusterManagers,
    Set<GroundOverlay>? groundOverlays,
    Set<Heatmap>? heatmaps,
  }) {
    return MapLocationPickerConfig(
      apiKey: apiKey ?? this.apiKey,
      baseClient: baseClient ?? this.baseClient,
      baseApiHeaders: baseApiHeaders ?? this.baseApiHeaders,
      baseUrl: baseUrl ?? this.baseUrl,
      initialPosition: initialPosition ?? this.initialPosition,
      initialZoom: initialZoom ?? this.initialZoom,
      initialMapType: initialMapType ?? this.initialMapType,
      myLocationButtonEnabled:
          myLocationButtonEnabled ?? this.myLocationButtonEnabled,
      myLocationEnabled: myLocationEnabled ?? this.myLocationEnabled,
      zoomControlsEnabled: zoomControlsEnabled ?? this.zoomControlsEnabled,
      minMaxZoomPreference: minMaxZoomPreference ?? this.minMaxZoomPreference,
      onCameraMove: onCameraMove ?? this.onCameraMove,
      padding: padding ?? this.padding,
      compassEnabled: compassEnabled ?? this.compassEnabled,
      liteModeEnabled: liteModeEnabled ?? this.liteModeEnabled,
      mapStyle: mapStyle ?? this.mapStyle,
      hideBottomCardOnKeyboard:
          hideBottomCardOnKeyboard ?? this.hideBottomCardOnKeyboard,
      bottomCardBuilder: bottomCardBuilder ?? this.bottomCardBuilder,
      searchBarBuilder: searchBarBuilder ?? this.searchBarBuilder,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      locationSettings: locationSettings ?? this.locationSettings,
      onLocationError: onLocationError ?? this.onLocationError,
      hideMoreOptions: hideMoreOptions ?? this.hideMoreOptions,
      mapTypeButton: mapTypeButton ?? this.mapTypeButton,
      locationButton: locationButton ?? this.locationButton,
      fabTooltip: fabTooltip ?? this.fabTooltip,
      bottomCardTitle: bottomCardTitle ?? this.bottomCardTitle,
      mapTypeIcon: mapTypeIcon ?? this.mapTypeIcon,
      locationIcon: locationIcon ?? this.locationIcon,
      mainMarkerIcon: mainMarkerIcon ?? this.mainMarkerIcon,
      floatingControlsColor:
          floatingControlsColor ?? this.floatingControlsColor,
      floatingControlsIconColor:
          floatingControlsIconColor ?? this.floatingControlsIconColor,
      onMapCreated: onMapCreated ?? this.onMapCreated,
      onMapTypeChanged: onMapTypeChanged ?? this.onMapTypeChanged,
      additionalMarkers: additionalMarkers ?? this.additionalMarkers,
      customMarkerIcons: customMarkerIcons ?? this.customMarkerIcons,
      customInfoWindows: customInfoWindows ?? this.customInfoWindows,
      onMarkerTapped: onMarkerTapped ?? this.onMarkerTapped,
      onSuggestionSelected: onSuggestionSelected ?? this.onSuggestionSelected,
      onAddressDecoded: onAddressDecoded ?? this.onAddressDecoded,
      onAddressSelected: onAddressSelected ?? this.onAddressSelected,
      onNext: onNext ?? this.onNext,
    );
  }
}

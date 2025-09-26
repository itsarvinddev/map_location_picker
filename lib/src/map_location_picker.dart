import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_maps_apis/places_new.dart' hide LatLng, Circle;

import '../map_location_picker.dart' hide Circle;
import 'card.dart';
import 'logger.dart';

enum CardType {
  defaultCard,
  liquidCard,
}

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
    final geoCodingResult = useState<Place?>(null);
    final geoCodingResults = useState<List<Place>>([]);
    final mapType = useState(config.initialMapType);

    final effectiveGeoCodingService = useMemoized(
      () =>
          geoCodingConfig ??
          GeoCodingConfig(
            apiKey: config.apiKey,
            placesApi: config.placesApi,
          ),
    );

    /// Initialize map
    useEffect(() {
      if (!context.mounted) return;
      if (config.initialPosition == const LatLng(0, 0)) return;
      Future.microtask(() {
        markers.value = _createMarkers(position.value);
        _getAddressForPosition(
          position.value,
          effectiveGeoCodingService,
          address,
          isLoading,
          geoCodingResult,
          geoCodingResults,
          context,
        );
      });
      return;
    }, const []);

    final theme = Theme.of(context);
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final shouldShowBottomCard =
        (!isKeyboardVisible || !config.hideBottomCardOnKeyboard);

    Widget buildSearchView() {
      Widget searchBar = PlacesAutocomplete(
        cardType: config.cardType,
        cardColor: config.cardColor,
        cardRadius: config.cardRadius,
        cardBorder: config.cardBorder,
        initialValue: searchConfig?.initialValue,
        config: searchConfig ??
            SearchConfig(
              apiKey: config.apiKey,
              placesApi: config.placesApi,
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
          geoCodingResults,
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
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black38,
                              builder: (context) => _buildMapTypeSelector(
                                context,
                                mapType,
                              ),
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
                            context,
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
                      geoCodingResults.value,
                      address.value,
                      isLoading.value,
                      () => _handleNext(context, geoCodingResult.value),
                      buildSearchView(),
                    ) ??
                    defaultBottomCard(
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

    final hasFocus = FocusManager.instance.primaryFocus?.hasFocus ?? false;
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: config.cardColor,
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
              context,
            ),
            onMapCreated: (controller) {
              mapControllerCompleter.complete(controller);
              config.onMapCreated?.call(controller);
              if (hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
            minMaxZoomPreference: config.minMaxZoomPreference,
            onCameraMove: (position) {
              config.onCameraMove?.call(position);
              if (hasFocus) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
            },
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
    BuildContext context,
    ValueNotifier<MapType> mapType,
  ) {
    final mapTypeValues = MapType.values.where((type) => type != MapType.none);
    return Material(
      type: MaterialType.transparency,
      elevation: 0,
      borderRadius:
          config.cardRadius ?? BorderRadius.circular(CustomMapCard.kRadius),
      child: CupertinoActionSheet(
        title: Text("Map type"),
        message: Text("Select the map type you want to see."),
        actions: mapTypeValues.map((type) {
          return CupertinoActionSheetAction(
            child: CupertinoListTile(
              padding: EdgeInsets.zero,
              leading: Icon(_mapTypeIcon(type), size: 20),
              title: Text(
                _mapTypeName(type),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                // style: theme.textTheme.titleMedium,
              ),
              trailing:
                  mapType.value == type ? Icon(Icons.check, size: 20) : null,
            ),
            onPressed: () {
              mapType.value = type;
              config.onMapTypeChanged?.call(type);
              Navigator.pop(context);
            },
          );
        }).toList(),
        cancelButton: CupertinoButton(
          child: Text("Cancel"),
          minimumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: () => Navigator.pop(context),
        ),
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

  Future<void> _getCurrentLocation(
    ValueNotifier<LatLng> position,
    Completer<GoogleMapController> mapControllerCompleter,
    GeoCodingConfig geoCodingService,
    ValueNotifier<String> address,
    ValueNotifier<bool> isLoading,
    ValueNotifier<Place?> geoCodingResult,
    ValueNotifier<List<Place>> geoCodingResults,
    ValueNotifier<Set<Marker>> markers,
    BuildContext context,
  ) async {
    try {
      isLoading.value = true;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        mapLogger.i("Location service is not enabled");
        return;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final newPermission = await Geolocator.requestPermission();
        if (newPermission != LocationPermission.whileInUse &&
            newPermission != LocationPermission.always) {
          mapLogger.i("Location permission is not while in use or always");
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
        context,
      );
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
    ValueNotifier<Place?> geoCodingResult,
    ValueNotifier<List<Place>> geoCodingResults,
    ValueNotifier<Set<Marker>> markers,
    BuildContext context,
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
        context,
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
    ValueNotifier<Place?> geoCodingResult,
    ValueNotifier<List<Place>> geoCodingResults,
    BuildContext context,
  ) async {
    isLoading.value = true;
    try {
      final response = await geoCodingService.reverseGeocode(
        position: position,
        radius: config.geocodingRadius,
      );
      if (!context.mounted) return;
      final result = response.$1;
      final results = response.$2;

      if (result != null) {
        address.value = result.formattedAddress ??
            result.adrFormatAddress ??
            config.noAddressFoundText;
        geoCodingResult.value = result;
        geoCodingResults.value = results;
        config.onAddressDecoded?.call(result);
      } else if (results.isNotEmpty) {
        address.value = results.first.formattedAddress ??
            results.first.adrFormatAddress ??
            config.noAddressFoundText;
        geoCodingResult.value = results.first;
        geoCodingResults.value = results;
        config.onAddressDecoded?.call(results.first);
      } else {
        address.value = config.noAddressFoundText;
        geoCodingResult.value = null;
        geoCodingResults.value = [];
        mapLogger.i(
          "No address found, position: $position, You can try with larger radius.",
        );
      }
    } catch (e) {
      mapLogger.e("Geocoding error: $e");
      if (!context.mounted) return;
      address.value = config.noAddressFoundText;
      geoCodingResult.value = null;
      geoCodingResults.value = [];
    } finally {
      if (context.mounted) {
        isLoading.value = false;
      }
    }
  }

  void _handlePlaceDetails(
    Place? details,
    BuildContext context,
    ValueNotifier<LatLng> position,
    Completer<GoogleMapController> mapControllerCompleter,
    ValueNotifier<String> address,
    GeoCodingConfig geoCodingService,
    ValueNotifier<bool> isLoading,
    ValueNotifier<Place?> geoCodingResult,
    ValueNotifier<List<Place>> geoCodingResults,
    ValueNotifier<Set<Marker>> markers,
  ) async {
    try {
      isLoading.value = true;
      if (details == null) return;
      final location = details.location;
      if (location != null) {
        if (location.latitude == null || location.longitude == null) return;
        final newPosition = LatLng(location.latitude!, location.longitude!);
        position.value = newPosition;
        address.value = details.formattedAddress ?? "";

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
        config.onSuggestionSelected?.call(details);
        await _getAddressForPosition(
          newPosition,
          geoCodingService,
          address,
          isLoading,
          geoCodingResult,
          geoCodingResults,
          context,
        );
      }
    } catch (e) {
      mapLogger.e("Error handling place details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _handleNext(BuildContext context, Place? result) {
    config.onNext?.call(result);
  }
}

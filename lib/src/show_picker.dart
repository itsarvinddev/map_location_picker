import 'package:flutter/material.dart';

import 'configs/map_config.dart';
import 'configs/search_config.dart';
import 'geocoding_service.dart';
import 'map_location_picker.dart';
import 'map_location_picker_controller.dart';
import 'picked_place.dart';

/// Pushes the picker and returns what the user chose, or null if they backed
/// out.
///
/// This replaces the boilerplate every consumer used to write by hand — a
/// `Navigator.push`, a `config.copyWith(onNext: ...)`, and a `Navigator.pop`
/// wired through a callback:
///
/// ```dart
/// final picked = await showMapLocationPicker(
///   context,
///   config: const MapLocationPickerConfig(apiKey: 'YOUR_API_KEY'),
/// );
/// if (picked != null) {
///   print(picked.latLng);
///   print(picked.formattedAddress);
/// }
/// ```
///
/// Any `onNext` already on [config] still fires, before the route pops.
///
/// Set [fullscreenDialog] for a modal presentation (a downward-close
/// transition on iOS). Pass [controller] to keep driving the picker while it is
/// open.
Future<PickedPlace?> showMapLocationPicker(
  BuildContext context, {
  required MapLocationPickerConfig config,
  SearchConfig? searchConfig,
  GeoCodingConfig? geoCodingConfig,
  MapLocationPickerController? controller,
  bool fullscreenDialog = false,
  RouteSettings? routeSettings,
  bool useRootNavigator = false,
}) async {
  // Set when the user confirms, before any caller-supplied onNext runs.
  PickedPlace? confirmed;

  // Typed Object? on purpose. A 3.x config very likely carries
  // `onNext: (r) => Navigator.pop(context, r)`, which pops this route with a
  // GeocodingResult. A MaterialPageRoute<PickedPlace> rejects that with an
  // assertion in debug and a TypeError in release, so accept anything and
  // translate below.
  final popped = await Navigator.of(context, rootNavigator: useRootNavigator)
      .push<Object?>(
        MaterialPageRoute<Object?>(
          fullscreenDialog: fullscreenDialog,
          settings: routeSettings,
          builder: (routeContext) => _PickerRoute(
            config: config,
            searchConfig: searchConfig,
            geoCodingConfig: geoCodingConfig,
            controller: controller,
            onConfirmed: (place) => confirmed = place,
          ),
        ),
      );

  if (popped is PickedPlace) return popped;
  // The caller's onNext popped with its own value -- a GeocodingResult, null,
  // anything. The user did confirm, so return what they picked.
  return confirmed;
}

/// Owns the controller so the route can read the final position even when
/// geocoding produced nothing.
class _PickerRoute extends StatefulWidget {
  const _PickerRoute({
    required this.config,
    this.searchConfig,
    this.geoCodingConfig,
    this.controller,
    required this.onConfirmed,
  });

  final MapLocationPickerConfig config;
  final SearchConfig? searchConfig;
  final GeoCodingConfig? geoCodingConfig;
  final MapLocationPickerController? controller;

  /// Receives the pick the moment the user confirms, so it survives even if a
  /// caller-supplied onNext pops the route with a value of its own.
  final ValueChanged<PickedPlace> onConfirmed;

  @override
  State<_PickerRoute> createState() => _PickerRouteState();
}

class _PickerRouteState extends State<_PickerRoute> {
  late final MapLocationPickerController _controller =
      widget.controller ??
      MapLocationPickerController(
        config: widget.config,
        geoCodingConfig: widget.geoCodingConfig,
      );

  bool get _ownsController => widget.controller == null;

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MapLocationPicker(
      controller: _controller,
      searchConfig: widget.searchConfig,
      geoCodingConfig: widget.geoCodingConfig,
      config: widget.config.copyWith(
        onNext: (result) {
          // Honour a caller-supplied onNext first, then pop with the result.
          // A 3.x config very likely still carries
          // `onNext: (r) => Navigator.pop(context, r)`, so capture this route
          // before handing control over and only pop if it is still the one on
          // top -- otherwise we would pop the caller's screen out from under
          // them. `mounted` is no guard here: the route stays mounted for the
          // whole exit transition.
          final navigator = Navigator.of(context);
          final route = ModalRoute.of(context);
          // Capture before handing over: the caller may pop, after which this
          // route's controller is on its way to being disposed.
          final picked = PickedPlace.from(
            latLng: _controller.position,
            result: result,
            place: _controller.lastSelectedPlace,
          );
          widget.onConfirmed(picked);
          widget.config.onNext?.call(result);
          if (!mounted) return;
          if (route != null && !route.isCurrent) return;
          navigator.pop(picked);
        },
      ),
    );
  }
}

// Screenshot harness for the README and pub.dev gallery.
//
// Renders the REAL package widgets with Flutter's own renderer. Only the
// native Google Maps view is replaced -- by [FakeMapsPlatform], which paints an
// illustrated map and draws the markers the package hands it -- because the
// platform view cannot initialise inside a test and real tiles need an API key.
//
// Run: flutter test tool/screenshots/generate_test.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Loads real fonts so text renders as glyphs instead of test boxes.
///
/// Roboto and Material Icons ship inside the Flutter SDK (Apache 2.0). Cupertino
/// widgets ask for 'CupertinoSystemText'/'CupertinoSystemDisplay'; those map to
/// Roboto here, since San Francisco cannot be redistributed.
Future<void> loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final f in files) {
      final bytes = File(f).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  final roboto = [
    '$fonts/Roboto-Regular.ttf',
    '$fonts/Roboto-Medium.ttf',
    '$fonts/Roboto-Bold.ttf',
    '$fonts/Roboto-Light.ttf',
  ];
  await load('Roboto', roboto);
  await load('CupertinoSystemText', roboto);
  await load('CupertinoSystemDisplay', roboto);
  await load('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);

  final cupertino = _packagePath('cupertino_icons');
  if (cupertino != null) {
    await load('packages/cupertino_icons/CupertinoIcons', [
      '$cupertino/assets/CupertinoIcons.ttf',
    ]);
    await load('CupertinoIcons', ['$cupertino/assets/CupertinoIcons.ttf']);
  }
}

String? _packagePath(String name) {
  final config = File('.dart_tool/package_config.json');
  if (!config.existsSync()) return null;
  final json = jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
  for (final p in (json['packages'] as List).cast<Map<String, dynamic>>()) {
    if (p['name'] == name) {
      final root = p['rootUri'] as String;
      return Uri.parse(root).isAbsolute
          ? Uri.parse(root).toFilePath()
          : File('.dart_tool/$root').absolute.path;
    }
  }
  return null;
}

/// Renders the widget tree under [key] to a PNG at [path].
Future<void> capture(WidgetTester tester, GlobalKey key, String path) async {
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(
      pixelRatio: tester.view.devicePixelRatio,
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

/// A stand-in for the native map that paints [painter] and the package's
/// markers on top of it.
class FakeMapsPlatform extends GoogleMapsFlutterPlatform {
  FakeMapsPlatform({required this.painterFor});

  /// Builds the map artwork for a camera position.
  final CustomPainter Function(
    CameraPosition camera,
    Set<Marker> markers,
    MapConfiguration configuration,
  )
  painterFor;

  final Map<int, ValueNotifier<Set<Marker>>> _markers = {};
  final Map<int, CameraPosition> _cameras = {};
  final Set<int> _created = {};
  final Map<int, ValueNotifier<MapConfiguration>> _configs = {};

  @override
  Future<void> init(int mapId) async {}

  @override
  Widget buildViewWithConfiguration(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    required MapWidgetConfiguration widgetConfiguration,
    MapConfiguration mapConfiguration = const MapConfiguration(),
    MapObjects mapObjects = const MapObjects(),
  }) {
    final markers = _markers.putIfAbsent(
      creationId,
      () => ValueNotifier(mapObjects.markers),
    );
    _cameras[creationId] = widgetConfiguration.initialCameraPosition;
    final config = _configs.putIfAbsent(
      creationId,
      () => ValueNotifier(mapConfiguration),
    );
    // The framework calls this on every rebuild of GoogleMap, but a real
    // platform view is created once.
    if (_created.add(creationId)) {
      scheduleMicrotask(() => onPlatformViewCreated(creationId));
    }
    return ListenableBuilder(
      listenable: Listenable.merge([markers, config]),
      builder: (context, _) => CustomPaint(
        size: Size.infinite,
        painter: painterFor(
          widgetConfiguration.initialCameraPosition,
          markers.value,
          config.value,
        ),
      ),
    );
  }

  @override
  Future<void> updateMarkers(
    MarkerUpdates markerUpdates, {
    required int mapId,
  }) async {
    final notifier = _markers[mapId];
    if (notifier == null) return;
    final next = {...notifier.value};
    next.removeWhere(
      (m) =>
          markerUpdates.markerIdsToRemove.contains(m.markerId) ||
          markerUpdates.markersToChange.any((c) => c.markerId == m.markerId),
    );
    next
      ..addAll(markerUpdates.markersToAdd)
      ..addAll(markerUpdates.markersToChange);
    notifier.value = next;
  }

  @override
  Future<void> updateMapConfiguration(
    MapConfiguration configuration, {
    required int mapId,
  }) async {
    final notifier = _configs[mapId];
    if (notifier == null) return;
    // Updates carry only the changed fields; merge onto what we have.
    notifier.value = notifier.value.applyDiff(configuration);
  }

  @override
  Future<void> updatePolygons(PolygonUpdates u, {required int mapId}) async {}
  @override
  Future<void> updatePolylines(PolylineUpdates u, {required int mapId}) async {}
  @override
  Future<void> updateCircles(CircleUpdates u, {required int mapId}) async {}
  @override
  Future<void> updateHeatmaps(HeatmapUpdates u, {required int mapId}) async {}
  @override
  Future<void> updateTileOverlays({
    required Set<TileOverlay> newTileOverlays,
    required int mapId,
  }) async {}
  @override
  Future<void> updateClusterManagers(
    ClusterManagerUpdates u, {
    required int mapId,
  }) async {}
  @override
  Future<void> updateGroundOverlays(
    GroundOverlayUpdates u, {
    required int mapId,
  }) async {}
  @override
  Future<void> animateCamera(CameraUpdate u, {required int mapId}) async {}
  @override
  Future<void> moveCamera(CameraUpdate u, {required int mapId}) async {}
  @override
  Future<double> getZoomLevel({required int mapId}) async =>
      _cameras[mapId]?.zoom ?? 14;

  @override
  Stream<CameraMoveStartedEvent> onCameraMoveStarted({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CameraMoveEvent> onCameraMove({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CameraIdleEvent> onCameraIdle({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerTapEvent> onMarkerTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<InfoWindowTapEvent> onInfoWindowTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragStartEvent> onMarkerDragStart({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragEvent> onMarkerDrag({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MarkerDragEndEvent> onMarkerDragEnd({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<PolylineTapEvent> onPolylineTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<PolygonTapEvent> onPolygonTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<CircleTapEvent> onCircleTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<MapTapEvent> onTap({required int mapId}) => const Stream.empty();
  @override
  Stream<MapLongPressEvent> onLongPress({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<ClusterTapEvent> onClusterTap({required int mapId}) =>
      const Stream.empty();
  @override
  Stream<GroundOverlayTapEvent> onGroundOverlayTap({required int mapId}) =>
      const Stream.empty();

  @override
  void dispose({required int mapId}) {
    _markers.remove(mapId)?.dispose();
    _configs.remove(mapId)?.dispose();
  }
}

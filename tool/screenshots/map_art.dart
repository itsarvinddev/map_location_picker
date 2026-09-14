// An illustrated city map for the screenshot harness.
//
// Deliberately stylised rather than a copy of any real map: the README says the
// map layer is illustrative, and real Google tiles need an API key. The layout
// is deterministic so re-running the generator produces identical images.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Colours for one map style.
class MapPalette {
  const MapPalette({
    required this.land,
    required this.block,
    required this.water,
    required this.waterEdge,
    required this.park,
    required this.road,
    required this.roadCasing,
    required this.arterial,
    required this.arterialCasing,
    required this.highway,
    required this.highwayCasing,
    required this.label,
    required this.districtLabel,
    required this.waterLabel,
    required this.halo,
  });

  final Color land;
  final Color block;
  final Color water;
  final Color waterEdge;
  final Color park;
  final Color road;
  final Color roadCasing;
  final Color arterial;
  final Color arterialCasing;
  final Color highway;
  final Color highwayCasing;
  final Color label;
  final Color districtLabel;
  final Color waterLabel;
  final Color halo;

  static const light = MapPalette(
    land: Color(0xFFF2F3F1),
    block: Color(0xFFE9EBE7),
    water: Color(0xFF9FD6EE),
    waterEdge: Color(0xFF8CCBE6),
    park: Color(0xFFC9E7C3),
    road: Color(0xFFFFFFFF),
    roadCasing: Color(0xFFDCDFE3),
    arterial: Color(0xFFFFFFFF),
    arterialCasing: Color(0xFFC6CBD2),
    highway: Color(0xFFFBDC8E),
    highwayCasing: Color(0xFFE2B85C),
    label: Color(0xFF6B7178),
    districtLabel: Color(0xFF454B52),
    waterLabel: Color(0xFF4E8FB0),
    halo: Color(0xE6FFFFFF),
  );

  static const dark = MapPalette(
    land: Color(0xFF1B222C),
    block: Color(0xFF212A35),
    water: Color(0xFF0D1520),
    waterEdge: Color(0xFF0A111A),
    park: Color(0xFF1A2E24),
    road: Color(0xFF2E3947),
    roadCasing: Color(0xFF161C24),
    arterial: Color(0xFF384556),
    arterialCasing: Color(0xFF161C24),
    highway: Color(0xFF6B5A36),
    highwayCasing: Color(0xFF2A241A),
    label: Color(0xFF8B96A3),
    districtLabel: Color(0xFFA9B3BF),
    waterLabel: Color(0xFF4E6E86),
    halo: Color(0xCC11161D),
  );
}

/// The text drawn on the map, so a localized screenshot is not French UI over
/// an English map.
class MapLabels {
  const MapLabels({
    required this.oldTown,
    required this.docks,
    required this.southMarket,
    required this.bay,
    required this.marketAvenue,
    required this.harborWay,
    required this.pine,
    required this.third,
    required this.freeway,
    required this.pois,
  });

  final String oldTown;
  final String docks;
  final String southMarket;
  final String bay;
  final String marketAvenue;
  final String harborWay;
  final String pine;
  final String third;
  final String freeway;

  /// Museum, market, bistro, station, park, café.
  final List<String> pois;

  static const en = MapLabels(
    oldTown: 'OLD TOWN',
    docks: 'THE DOCKS',
    southMarket: 'SOUTH MARKET',
    bay: 'Bay Harbor',
    marketAvenue: 'Market Avenue',
    harborWay: 'Harbor Way',
    pine: 'Pine St',
    third: '3rd St',
    freeway: 'Bayshore Fwy',
    pois: [
      'City Museum',
      'Harbor Market',
      'Corner Bistro',
      'Central Station',
      'Riverside Park',
      'Roast & Co.',
    ],
  );

  static const fr = MapLabels(
    oldTown: 'VIEILLE VILLE',
    docks: 'LES DOCKS',
    southMarket: 'MARCHÉ SUD',
    bay: 'Baie du Port',
    marketAvenue: 'Avenue du Marché',
    harborWay: 'Rue du Port',
    pine: 'Rue des Pins',
    third: 'Rue 3',
    freeway: 'Périphérique',
    pois: [
      'Musée de la Ville',
      'Marché du Port',
      'Le Bistrot',
      'Gare Centrale',
      'Parc de la Rivière',
      'Café Torréfié',
    ],
  );
}

/// A point of interest drawn on the map.
class _Poi {
  const _Poi(this.at, this.name, this.icon, this.color);
  final Offset at; // fractions of the viewport
  final String name;
  final IconData icon;
  final Color color;
}

/// Paints the city, then every marker the package handed to the platform.
class IllustratedMapPainter extends CustomPainter {
  IllustratedMapPainter({
    required this.palette,
    required this.camera,
    required this.markers,
    this.padding = EdgeInsets.zero,
    this.showPois = true,
    this.labels = MapLabels.en,
    this.viewScale = 1,
    this.viewOffset = Offset.zero,
    this.labelTop = 118,
    this.labelBottomFraction = 0.78,
  });

  final MapPalette palette;
  final CameraPosition camera;
  final Set<Marker> markers;

  /// The map padding the package requested. As on Android and iOS, the camera
  /// target sits at the centre of the padded region, so markers are projected
  /// from there.
  final EdgeInsets padding;
  final bool showPois;
  final MapLabels labels;

  /// Zooms the artwork about the screen centre, so scenes do not all show an
  /// identical map. Kept >= 1 so the edges of the drawing never come into view.
  final double viewScale;

  /// Pans the artwork, clamped to the margin [viewScale] creates.
  final Offset viewOffset;

  /// Labels above this y (the status bar and search field) are culled.
  final double labelTop;

  /// Labels below this fraction of the height (the bottom card) are culled.
  final double labelBottomFraction;

  // Set at the start of paint() so label culling can map art space to screen.
  double _s = 1;
  Offset _pan = Offset.zero;
  Size _size = Size.zero;

  static const _pois = [
    _Poi(Offset(0.28, 0.23), 'City Museum', Icons.museum, Color(0xFF8E44D8)),
    _Poi(
      Offset(0.68, 0.39),
      'Harbor Market',
      Icons.storefront,
      Color(0xFF1A73E8),
    ),
    _Poi(
      Offset(0.11, 0.37),
      'Corner Bistro',
      Icons.restaurant,
      Color(0xFFE8710A),
    ),
    _Poi(Offset(0.57, 0.60), 'Central Station', Icons.train, Color(0xFF1A73E8)),
    _Poi(Offset(0.24, 0.70), 'Riverside Park', Icons.park, Color(0xFF188038)),
    _Poi(
      Offset(0.13, 0.63),
      'Roast & Co.',
      Icons.local_cafe,
      Color(0xFFE8710A),
    ),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.land);

    final s = math.max(1.0, viewScale);
    final margin = Offset((s - 1) * w / 2, (s - 1) * h / 2);
    final pan = Offset(
      viewOffset.dx.clamp(-margin.dx, margin.dx),
      viewOffset.dy.clamp(-margin.dy, margin.dy),
    );
    _s = s;
    _pan = pan;
    _size = size;
    canvas.save();
    canvas.translate(w / 2 + pan.dx, h / 2 + pan.dy);
    canvas.scale(s);
    canvas.translate(-w / 2, -h / 2);

    final water = _waterPath(w, h);
    final land = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      water,
    );

    // Northern grid, then the rotated southern grid below the main avenue.
    canvas.save();
    canvas.clipPath(land);
    final divider = _avenueLine(w, h);
    _grid(
      canvas,
      size,
      angle: -0.10,
      spacing: 38,
      clip: Path.combine(
        PathOperation.intersect,
        land,
        _aboveLine(divider, size),
      ),
      major: 4,
    );
    _grid(
      canvas,
      size,
      angle: 0.62,
      spacing: 46,
      clip: Path.combine(
        PathOperation.intersect,
        land,
        _belowLine(divider, size),
      ),
      major: 3,
    );
    _parks(canvas, w, h);
    _road(
      canvas,
      _avenuePath(w, h),
      9,
      palette.arterial,
      palette.arterialCasing,
    );
    _road(
      canvas,
      _secondAvenue(w, h),
      7.5,
      palette.arterial,
      palette.arterialCasing,
    );
    _road(
      canvas,
      _highwayPath(w, h),
      12,
      palette.highway,
      palette.highwayCasing,
    );
    canvas.restore();

    // Water on top of the road stubs so the coast reads cleanly.
    canvas.drawPath(water, Paint()..color = palette.water);
    canvas.drawPath(
      water,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = palette.waterEdge,
    );

    _labels(canvas, w, h);
    if (showPois) _drawPois(canvas, size);
    canvas.restore();

    // Markers are placed by projection, so they stay out of the view transform.
    _drawMarkers(canvas, size);
  }

  // --- geometry ------------------------------------------------------------

  Path _waterPath(double w, double h) => Path()
    ..moveTo(w * 0.50, -10)
    ..cubicTo(w * 0.62, h * 0.10, w * 0.80, h * 0.12, w * 0.88, h * 0.24)
    ..cubicTo(w * 0.97, h * 0.37, w * 0.90, h * 0.50, w + 10, h * 0.60)
    ..lineTo(w + 10, -10)
    ..close();

  List<Offset> _avenueLine(double w, double h) => [
    Offset(-20, h * 0.66),
    Offset(w * 0.86, h * 0.16),
  ];

  Path _aboveLine(List<Offset> line, Size s) => Path()
    ..moveTo(line[0].dx, line[0].dy)
    ..lineTo(line[1].dx, line[1].dy)
    ..lineTo(s.width + 40, line[1].dy)
    ..lineTo(s.width + 40, -40)
    ..lineTo(-40, -40)
    ..close();

  Path _belowLine(List<Offset> line, Size s) => Path()
    ..moveTo(line[0].dx, line[0].dy)
    ..lineTo(line[1].dx, line[1].dy)
    ..lineTo(s.width + 40, line[1].dy)
    ..lineTo(s.width + 40, s.height + 40)
    ..lineTo(-40, s.height + 40)
    ..close();

  Path _avenuePath(double w, double h) {
    final l = _avenueLine(w, h);
    return Path()
      ..moveTo(l[0].dx, l[0].dy)
      ..lineTo(l[1].dx, l[1].dy);
  }

  Path _secondAvenue(double w, double h) => Path()
    ..moveTo(w * 0.05, -20)
    ..quadraticBezierTo(w * 0.20, h * 0.40, w * 0.12, h + 20);

  Path _highwayPath(double w, double h) => Path()
    ..moveTo(-30, h * 0.80)
    ..cubicTo(w * 0.35, h * 0.77, w * 0.62, h * 0.70, w + 30, h * 0.58);

  void _grid(
    Canvas canvas,
    Size size, {
    required double angle,
    required double spacing,
    required Path clip,
    required int major,
  }) {
    canvas.save();
    canvas.clipPath(clip);
    final diag = size.longestSide * 1.6;
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(angle);

    // City blocks read as a faint tint between streets.
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: diag, height: diag),
      Paint()..color = palette.block,
    );

    final n = (diag / spacing).ceil();
    for (final vertical in [true, false]) {
      for (var i = -n; i <= n; i++) {
        final isMajor = i % major == 0;
        final d = i * spacing;
        final a = vertical ? Offset(d, -diag) : Offset(-diag, d);
        final b = vertical ? Offset(d, diag) : Offset(diag, d);
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = palette.roadCasing
            ..strokeWidth = isMajor ? 6.5 : 4,
        );
        canvas.drawLine(
          a,
          b,
          Paint()
            ..color = palette.road
            ..strokeWidth = isMajor ? 5 : 2.6,
        );
      }
    }
    canvas.restore();
  }

  void _road(Canvas canvas, Path path, double width, Color fill, Color casing) {
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width + 3
        ..color = casing,
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width
        ..color = fill,
    );
  }

  void _parks(Canvas canvas, double w, double h) {
    final paint = Paint()..color = palette.park;
    void park(Offset c, double pw, double ph, double rot, double r) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(rot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: pw, height: ph),
          Radius.circular(r),
        ),
        paint,
      );
      canvas.restore();
    }

    park(Offset(w * 0.28, h * 0.66), w * 0.30, h * 0.06, 0.62, 10);
    park(Offset(w * 0.22, h * 0.33), w * 0.17, h * 0.07, -0.10, 8);
    park(Offset(w * 0.46, h * 0.345), w * 0.12, h * 0.045, -0.10, 6);
    park(Offset(w * 0.86, h * 0.92), w * 0.30, h * 0.06, 0.62, 10);
  }

  // --- text ------------------------------------------------------------------

  /// Whether an art-space box would land fully on screen and clear of the top
  /// chrome and the bottom card. Real map renderers cull labels rather than
  /// slicing them at the edge; this does the same.
  bool _visible(Rect art, {double rotation = 0}) {
    final c = Offset(_size.width / 2, _size.height / 2);
    Offset toScreen(Offset p) => (p - c) * _s + c + _pan;
    final Rect screen;
    if (rotation.abs() < 0.01) {
      screen = Rect.fromPoints(
        toScreen(art.topLeft),
        toScreen(art.bottomRight),
      );
    } else {
      final r = art.shortestSide / 2 + art.longestSide / 2;
      screen = Rect.fromCircle(
        center: toScreen(art.center),
        radius: r * _s / 2,
      );
    }
    final safe = Rect.fromLTRB(
      6,
      labelTop,
      _size.width - 6,
      _size.height * labelBottomFraction,
    );
    // The floating buttons occupy the lower-right corner of every screen.
    final fabs = Rect.fromLTRB(
      _size.width - 64,
      _size.height * 0.58,
      _size.width,
      _size.height,
    );
    return safe.contains(screen.topLeft) &&
        safe.contains(screen.bottomRight) &&
        !fabs.overlaps(screen);
  }

  void _text(
    Canvas canvas,
    String text,
    Offset centre, {
    required TextStyle style,
    double rotation = 0,
    bool halo = true,
  }) {
    TextPainter build(TextStyle s) => TextPainter(
      text: TextSpan(text: text, style: s),
      textDirection: TextDirection.ltr,
    )..layout();

    final probe = build(style);
    if (!_visible(
      Rect.fromCenter(center: centre, width: probe.width, height: probe.height),
      rotation: rotation,
    )) {
      return;
    }

    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(rotation);
    if (halo) {
      final h = build(
        style.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeJoin = StrokeJoin.round
            ..color = palette.halo,
        ),
      );
      h.paint(canvas, Offset(-h.width / 2, -h.height / 2));
    }
    final t = build(style);
    t.paint(canvas, Offset(-t.width / 2, -t.height / 2));
    canvas.restore();
  }

  void _labels(Canvas canvas, double w, double h) {
    TextStyle district(double size) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: size,
      fontWeight: FontWeight.w500,
      letterSpacing: 2.2,
      color: palette.districtLabel,
    );
    final street = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 10.5,
      color: palette.label,
    );

    _text(
      canvas,
      labels.oldTown,
      Offset(w * 0.30, h * 0.16),
      style: district(12),
    );
    _text(
      canvas,
      labels.docks,
      Offset(w * 0.38, h * 0.555),
      style: district(11),
    );

    _text(
      canvas,
      labels.marketAvenue,
      Offset(w * 0.63, h * 0.29),
      style: street,
      rotation: -0.63,
    );
    _text(
      canvas,
      labels.harborWay,
      Offset(w * 0.115, h * 0.52),
      style: street,
      rotation: 1.50,
    );
    _text(
      canvas,
      labels.pine,
      Offset(w * 0.38, h * 0.27),
      style: street,
      rotation: -0.10,
    );
    _text(
      canvas,
      labels.third,
      Offset(w * 0.72, h * 0.57),
      style: street,
      rotation: 0.62,
    );
    _text(
      canvas,
      labels.freeway,
      Offset(w * 0.36, h * 0.745),
      style: street,
      rotation: -0.12,
    );
  }

  void _drawPois(Canvas canvas, Size size) {
    for (var i = 0; i < _pois.length; i++) {
      final poi = _pois[i];
      final label = labels.pois[i];
      final probe = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontFamily: 'Roboto', fontSize: 11.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final c0 = Offset(size.width * poi.at.dx, size.height * poi.at.dy);
      if (!_visible(
        Rect.fromLTRB(
          c0.dx - 12,
          c0.dy - 12,
          c0.dx + 16 + probe.width,
          c0.dy + 12,
        ),
      )) {
        continue;
      }
      final c = Offset(size.width * poi.at.dx, size.height * poi.at.dy);
      canvas.drawCircle(c, 11.5, Paint()..color = palette.halo);
      canvas.drawCircle(c, 10, Paint()..color = poi.color);
      final icon = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(poi.icon.codePoint),
          style: TextStyle(
            fontFamily: poi.icon.fontFamily,
            fontSize: 12,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      icon.paint(canvas, c - Offset(icon.width / 2, icon.height / 2));
      final name = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: poi.color,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final at = c + Offset(15, -name.height / 2);
      final halo = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = palette.halo,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      halo.paint(canvas, at);
      name.paint(canvas, at);
    }
  }

  // --- markers ---------------------------------------------------------------

  /// Where the camera target lands on screen: the centre of the padded region.
  Offset _targetOnScreen(Size size) => Offset(
    padding.left + (size.width - padding.horizontal) / 2,
    padding.top + (size.height - padding.vertical) / 2,
  );

  Offset _project(LatLng p, Size size) {
    const tile = 256.0;
    final scale = tile * math.pow(2, camera.zoom);
    double x(double lng) => (lng + 180) / 360 * scale;
    double y(double lat) {
      final s = math.sin(lat * math.pi / 180);
      return (0.5 - math.log((1 + s) / (1 - s)) / (4 * math.pi)) * scale;
    }

    final origin = _targetOnScreen(size);
    return origin +
        Offset(
          x(p.longitude) - x(camera.target.longitude),
          y(p.latitude) - y(camera.target.latitude),
        );
  }

  void _drawMarkers(Canvas canvas, Size size) {
    for (final m in markers) {
      final json = m.icon.toJson();
      var color = const Color(0xFFEA4335);
      if (json is List && json.length > 1 && json[0] == 'defaultMarker') {
        color = HSVColor.fromAHSV(
          1,
          (json[1] as num).toDouble(),
          0.78,
          0.92,
        ).toColor();
      }
      drawPin(canvas, _project(m.position, size), color: color);
    }
  }

  @override
  bool shouldRepaint(covariant IllustratedMapPainter old) =>
      old.markers != markers ||
      old.palette != palette ||
      old.padding != padding ||
      old.labels != labels ||
      old.viewScale != viewScale ||
      old.viewOffset != viewOffset ||
      old.labelTop != labelTop ||
      old.labelBottomFraction != labelBottomFraction ||
      old.camera != camera;
}

/// A classic map pin whose tip touches [tip].
void drawPin(
  Canvas canvas,
  Offset tip, {
  Color color = const Color(0xFFEA4335),
  double scale = 1,
}) {
  final r = 13.0 * scale;
  final head = tip - Offset(0, 30 * scale);

  canvas.drawOval(
    Rect.fromCenter(
      center: tip + const Offset(0, 1.5),
      width: 16 * scale,
      height: 5 * scale,
    ),
    Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
  );

  final path = Path()
    ..moveTo(tip.dx, tip.dy)
    ..cubicTo(
      tip.dx - r * 0.35,
      tip.dy - r * 0.9,
      head.dx - r,
      head.dy + r * 0.75,
      head.dx - r,
      head.dy,
    )
    ..arcToPoint(Offset(head.dx + r, head.dy), radius: Radius.circular(r))
    ..cubicTo(
      head.dx + r,
      head.dy + r * 0.75,
      tip.dx + r * 0.35,
      tip.dy - r * 0.9,
      tip.dx,
      tip.dy,
    )
    ..close();

  canvas.drawShadow(path, const Color(0xFF000000), 3, false);
  canvas.drawPath(path, Paint()..color = color);
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Color.lerp(color, Colors.black, 0.25)!,
  );
  canvas.drawCircle(
    head,
    r * 0.38,
    Paint()..color = Color.lerp(color, Colors.black, 0.45)!,
  );
}

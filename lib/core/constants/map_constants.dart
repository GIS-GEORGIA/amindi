import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

abstract final class MapConstants {
  static const LatLng georgiaCenter = LatLng(42.0, 43.5);

  static final LatLngBounds georgiaBounds = LatLngBounds(
    const LatLng(41.0, 40.0), // SW
    const LatLng(43.6, 46.8), // NE
  );

  static const double initialZoom = 7.0;
  static const double minZoom = 6.5;
  static const double maxZoom = 17.0;

  // Public tile servers — acceptable for development only. Before production
  // switch to an own proxy or MapTiler (see README, Phase 1 decision).
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String openTopoTileUrl = 'https://tile.opentopomap.org/{z}/{x}/{y}.png';

  // MET Norway requires an identifying User-Agent; reused for tile requests too.
  static const String userAgentPackageName = 'ge.gisgeorgia.amindi';
}

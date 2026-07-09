import 'package:latlong2/latlong.dart';

/// A Georgian city/town for search. Coordinates are bundled so search works
/// offline and the app's own forecast (Open-Meteo + YR) can be shown for it —
/// meteo.gov.ge's village list has no coordinates and its per-city page is a
/// stateful JS flow, so we keep a curated list here.
class GeorgianCity {
  const GeorgianCity({
    required this.name,
    required this.nameEn,
    required this.region,
    required this.lat,
    required this.lon,
  });

  final String name; // ქართული
  final String nameEn; // Latin (for en locale + latin-typed search)
  final String region; // ქართული რეგიონი
  final double lat;
  final double lon;

  LatLng get location => LatLng(lat, lon);
}

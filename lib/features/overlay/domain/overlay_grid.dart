/// Gridded forecast over Georgia for overlay rendering.
///
/// Rows go north → south (image row order), columns west → east.
/// Values are flattened per frame: `values[timeIndex][row * cols + col]`.
class OverlayGrid {
  const OverlayGrid({
    required this.lats,
    required this.lons,
    required this.times,
    required this.temperature,
    required this.precipitation,
  });

  final List<double> lats;
  final List<double> lons;
  final List<DateTime> times;
  final List<List<double?>> temperature;
  final List<List<double?>> precipitation;

  int get rows => lats.length;
  int get cols => lons.length;
}

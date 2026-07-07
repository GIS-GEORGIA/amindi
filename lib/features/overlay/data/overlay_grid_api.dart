import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/constants/map_constants.dart';
import '../domain/overlay_grid.dart';

/// Fetches an ICON-EU grid over Georgia in a single multi-location request.
/// Open-Meteo has no raster tiles, so the overlay is drawn client-side from
/// these points (see README, Phase 5).
class OverlayGridApi {
  OverlayGridApi(this._dio);

  final Dio _dio;

  /// 18 × 12 = 216 points ≈ 0.4° lon / 0.24° lat spacing — close enough to
  /// the ~25 km effective open-data resolution that more points add little.
  static const int cols = 18;
  static const int rows = 12;

  /// Frames offered on the time slider.
  static const int maxFrames = 24;

  Future<OverlayGrid> fetch() async {
    final north = MapConstants.georgiaBounds.north;
    final south = MapConstants.georgiaBounds.south;
    final west = MapConstants.georgiaBounds.west;
    final east = MapConstants.georgiaBounds.east;

    final lats = [
      for (var r = 0; r < rows; r++) north - r * (north - south) / (rows - 1)
    ];
    final lons = [
      for (var c = 0; c < cols; c++) west + c * (east - west) / (cols - 1)
    ];

    final latParam = [
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < cols; c++) lats[r].toStringAsFixed(3)
    ].join(',');
    final lonParam = [
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < cols; c++) lons[c].toStringAsFixed(3)
    ].join(',');

    final response = await _dio.get<List<dynamic>>(
      ApiConstants.openMeteoBaseUrl,
      queryParameters: {
        'latitude': latParam,
        'longitude': lonParam,
        'hourly': 'temperature_2m,precipitation',
        'models': 'icon_eu',
        'forecast_days': 3,
        'timezone': 'auto',
      },
    );

    final locations = response.data!;
    final firstHourly = locations.first['hourly'] as Map<String, dynamic>;
    final allTimes = (firstHourly['time'] as List)
        .cast<String>()
        .map(DateTime.parse)
        .toList(growable: false);

    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    var start = allTimes.indexWhere((t) => t.isAfter(cutoff));
    if (start < 0) start = 0;
    final frames = (allTimes.length - start).clamp(0, maxFrames);
    final times = allTimes.sublist(start, start + frames);

    List<List<double?>> extract(String variable) {
      final perLocation = [
        for (final location in locations)
          ((location['hourly'] as Map<String, dynamic>)[variable] as List)
      ];
      return [
        for (var f = 0; f < frames; f++)
          [
            for (var p = 0; p < perLocation.length; p++)
              (perLocation[p][start + f] as num?)?.toDouble()
          ]
      ];
    }

    return OverlayGrid(
      lats: lats,
      lons: lons,
      times: times,
      temperature: extract('temperature_2m'),
      precipitation: extract('precipitation'),
    );
  }
}

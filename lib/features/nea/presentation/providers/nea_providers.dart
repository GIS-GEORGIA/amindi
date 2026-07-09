import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/forecast_service.dart';
import '../../data/models/forecasts.dart';
import '../../data/models/weather_warning.dart';
import '../../data/warning_service.dart';

final warningServiceProvider = Provider<WarningService>((ref) {
  final service = WarningService();
  ref.onDispose(service.dispose);
  return service;
});

final forecastServiceProvider = Provider<ForecastService>((ref) {
  final service = ForecastService();
  ref.onDispose(service.dispose);
  return service;
});

/// Official NEA storm/hazard warning. `null` when there is none, on a network
/// error, or on web (CORS blocks meteo.gov.ge) — the UI simply shows nothing.
final warningProvider = FutureProvider.autoDispose<WeatherWarning?>(
  (ref) => ref.watch(warningServiceProvider).fetchWarning(),
);

final regionForecastProvider = FutureProvider.autoDispose<RegionForecast?>(
  (ref) => ref.watch(forecastServiceProvider).fetchRegions(),
);

final monthForecastProvider = FutureProvider.autoDispose<LongRangeForecast?>(
  (ref) => ref.watch(forecastServiceProvider).fetchLatestMonth(),
);

final seasonForecastProvider = FutureProvider.autoDispose<LongRangeForecast?>(
  (ref) => ref.watch(forecastServiceProvider).fetchLatestSeason(),
);

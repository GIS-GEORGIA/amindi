import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/forecast_service.dart';
import '../../data/models/forecasts.dart';
import '../../data/models/weather_warning.dart';
import '../../data/nea_endpoints.dart';
import '../../data/warning_service.dart';

final warningServiceProvider = Provider<WarningService>((ref) {
  // Web goes through the CORS proxy; native hits meteo.gov.ge directly.
  final service = WarningService(sourceUrl: '$neaBaseUrl/natural-disaster');
  ref.onDispose(service.dispose);
  return service;
});

final forecastServiceProvider = Provider<ForecastService>((ref) {
  final service = ForecastService(baseUrl: neaBaseUrl);
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

import '../../domain/entities/forecast_point.dart';
import '../../domain/entities/weather_model.dart';
import '../datasources/open_meteo_api.dart';
import '../datasources/yr_api.dart';

class ForecastRepository {
  ForecastRepository({required this.openMeteo, required this.yr});

  final OpenMeteoApi openMeteo;
  final YrApi yr;

  /// Fetches both sources in parallel. Partial failures are kept per model;
  /// throws only when every source failed.
  Future<ForecastBundle> fetchAll(double latitude, double longitude) async {
    final forecasts = <WeatherModel, ModelForecast>{};
    final errors = <WeatherModel, Object>{};

    Future<void> collectOpenMeteo() async {
      try {
        forecasts.addAll(await openMeteo.fetch(latitude, longitude));
      } catch (e) {
        for (final model in OpenMeteoApi.modelSuffixes.keys) {
          errors[model] = e;
        }
      }
    }

    Future<void> collectYr() async {
      try {
        forecasts[WeatherModel.yr] = await yr.fetch(latitude, longitude);
      } catch (e) {
        errors[WeatherModel.yr] = e;
      }
    }

    await Future.wait([collectOpenMeteo(), collectYr()]);

    if (forecasts.isEmpty) {
      throw errors.values.first;
    }
    return ForecastBundle(forecasts: forecasts, errors: errors);
  }
}

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/forecast_point.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/entities/weather_model.dart';

/// Fetches ECMWF, ICON-EU and GFS in a single request. With multiple
/// `models=` values Open-Meteo suffixes every hourly variable with the model
/// name (`temperature_2m_ecmwf_ifs025`, ...) over one shared `time` array.
class OpenMeteoApi {
  OpenMeteoApi(this._dio);

  final Dio _dio;

  static const modelSuffixes = {
    WeatherModel.ecmwf: 'ecmwf_ifs025',
    WeatherModel.iconEu: 'icon_eu',
    WeatherModel.gfs: 'gfs_seamless',
  };

  Future<Map<WeatherModel, ModelForecast>> fetch(
      double latitude, double longitude) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.openMeteoBaseUrl,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'hourly': 'temperature_2m,precipitation,weather_code,'
            'wind_speed_10m,wind_direction_10m',
        'models': modelSuffixes.values.join(','),
        'wind_speed_unit': 'ms',
        'forecast_days': 7,
        'timezone': 'auto',
      },
    );

    final hourly = response.data!['hourly'] as Map<String, dynamic>;
    final times = (hourly['time'] as List)
        .cast<String>()
        .map(DateTime.parse)
        .toList(growable: false);

    return modelSuffixes.map((model, suffix) {
      List<double?> series(String variable) =>
          ((hourly['${variable}_$suffix'] as List?) ?? const [])
              .map((v) => (v as num?)?.toDouble())
              .toList(growable: false);

      final temperature = series('temperature_2m');
      final precipitation = series('precipitation');
      final code = series('weather_code');
      final windSpeed = series('wind_speed_10m');
      final windDirection = series('wind_direction_10m');

      double? at(List<double?> list, int i) =>
          i < list.length ? list[i] : null;

      final points = [
        for (var i = 0; i < times.length; i++)
          if (at(temperature, i) != null)
            ForecastPoint(
              time: times[i],
              temperature: at(temperature, i),
              precipitation: at(precipitation, i),
              windSpeed: at(windSpeed, i),
              windDirection: at(windDirection, i),
              condition:
                  WeatherCondition.fromWmoCode(at(code, i)?.round()),
            ),
      ];
      return MapEntry(model, ModelForecast(model: model, hourly: points));
    });
  }
}

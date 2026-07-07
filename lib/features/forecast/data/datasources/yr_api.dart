import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/forecast_point.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/entities/weather_model.dart';

/// MET Norway locationforecast. Hourly steps for ~2.5 days, then 6-hour
/// steps; precipitation/symbol come from `next_1_hours` when present,
/// otherwise `next_6_hours`. The mandatory User-Agent is attached by the
/// dio interceptor in core/network.
class YrApi {
  YrApi(this._dio);

  final Dio _dio;

  Future<ModelForecast> fetch(double latitude, double longitude) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.yrBaseUrl,
      queryParameters: {'lat': latitude, 'lon': longitude},
    );

    final timeseries =
        response.data!['properties']['timeseries'] as List;

    final points = timeseries.map((entry) {
      final data = entry['data'] as Map<String, dynamic>;
      final instant =
          (data['instant']?['details'] ?? const {}) as Map<String, dynamic>;
      final next = (data['next_1_hours'] ?? data['next_6_hours'])
          as Map<String, dynamic>?;

      double? toDouble(Object? v) => (v as num?)?.toDouble();

      return ForecastPoint(
        time: DateTime.parse(entry['time'] as String).toLocal(),
        temperature: toDouble(instant['air_temperature']),
        windSpeed: toDouble(instant['wind_speed']),
        windDirection: toDouble(instant['wind_from_direction']),
        precipitation: toDouble(next?['details']?['precipitation_amount']),
        condition: WeatherCondition.fromYrSymbol(
            next?['summary']?['symbol_code'] as String?),
      );
    }).toList(growable: false);

    return ModelForecast(model: WeatherModel.yr, hourly: points);
  }
}

import 'dart:math' as math;

import 'weather_condition.dart';
import 'weather_model.dart';

/// One normalized forecast step. All sources are converted to these units
/// in the data layer: °C, mm, m/s, degrees.
class ForecastPoint {
  const ForecastPoint({
    required this.time,
    this.temperature,
    this.precipitation,
    this.windSpeed,
    this.windDirection,
    this.condition,
  });

  final DateTime time;
  final double? temperature;
  final double? precipitation;
  final double? windSpeed;
  final double? windDirection;
  final WeatherCondition? condition;
}

class DailySummary {
  const DailySummary({
    required this.date,
    this.tempMin,
    this.tempMax,
    this.precipitation = 0,
    this.condition,
  });

  final DateTime date;
  final double? tempMin;
  final double? tempMax;
  final double precipitation;
  final WeatherCondition? condition;
}

/// Full forecast of one model for one location.
class ModelForecast {
  ModelForecast({required this.model, required this.hourly})
      : byTime = {for (final p in hourly) p.time: p};

  final WeatherModel model;
  final List<ForecastPoint> hourly;
  final Map<DateTime, ForecastPoint> byTime;

  late final List<DailySummary> daily = _aggregateDaily();

  List<DailySummary> _aggregateDaily() {
    final byDay = <DateTime, List<ForecastPoint>>{};
    for (final p in hourly) {
      final day = DateTime(p.time.year, p.time.month, p.time.day);
      byDay.putIfAbsent(day, () => []).add(p);
    }
    final days = byDay.entries.map((entry) {
      final temps =
          entry.value.map((p) => p.temperature).whereType<double>().toList();
      final precipitation = entry.value
          .map((p) => p.precipitation)
          .whereType<double>()
          .fold(0.0, (a, b) => a + b);
      // Most severe daytime condition — answers "will it rain today".
      WeatherCondition? worst;
      for (final p in entry.value) {
        if (p.time.hour < 6 || p.time.hour > 21 || p.condition == null) {
          continue;
        }
        if (worst == null || p.condition!.index > worst.index) {
          worst = p.condition;
        }
      }
      return DailySummary(
        date: entry.key,
        tempMin: temps.isEmpty ? null : temps.reduce(math.min),
        tempMax: temps.isEmpty ? null : temps.reduce(math.max),
        precipitation: precipitation,
        condition: worst,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return days;
  }
}

/// Result of fetching all sources: whatever succeeded plus per-model errors,
/// so one failing API never blanks the whole panel.
class ForecastBundle {
  const ForecastBundle({required this.forecasts, required this.errors});

  final Map<WeatherModel, ModelForecast> forecasts;
  final Map<WeatherModel, Object> errors;
}

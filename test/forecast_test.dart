import 'package:amindi/features/forecast/domain/entities/forecast_point.dart';
import 'package:amindi/features/forecast/domain/entities/weather_condition.dart';
import 'package:amindi/features/forecast/domain/entities/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherCondition.fromWmoCode', () {
    test('maps representative WMO codes', () {
      expect(WeatherCondition.fromWmoCode(0), WeatherCondition.clear);
      expect(WeatherCondition.fromWmoCode(2), WeatherCondition.partlyCloudy);
      expect(WeatherCondition.fromWmoCode(3), WeatherCondition.cloudy);
      expect(WeatherCondition.fromWmoCode(45), WeatherCondition.fog);
      expect(WeatherCondition.fromWmoCode(53), WeatherCondition.rain);
      expect(WeatherCondition.fromWmoCode(63), WeatherCondition.rain);
      expect(WeatherCondition.fromWmoCode(66), WeatherCondition.sleet);
      expect(WeatherCondition.fromWmoCode(73), WeatherCondition.snow);
      expect(WeatherCondition.fromWmoCode(86), WeatherCondition.snow);
      expect(WeatherCondition.fromWmoCode(95), WeatherCondition.thunder);
      expect(WeatherCondition.fromWmoCode(null), isNull);
    });
  });

  group('WeatherCondition.fromYrSymbol', () {
    test('maps representative symbol codes', () {
      expect(WeatherCondition.fromYrSymbol('clearsky_day'),
          WeatherCondition.clear);
      expect(WeatherCondition.fromYrSymbol('fair_night'),
          WeatherCondition.partlyCloudy);
      expect(WeatherCondition.fromYrSymbol('partlycloudy_day'),
          WeatherCondition.partlyCloudy);
      expect(WeatherCondition.fromYrSymbol('cloudy'), WeatherCondition.cloudy);
      expect(WeatherCondition.fromYrSymbol('fog'), WeatherCondition.fog);
      expect(WeatherCondition.fromYrSymbol('lightrainshowers_day'),
          WeatherCondition.rain);
      expect(WeatherCondition.fromYrSymbol('heavyrainandthunder'),
          WeatherCondition.thunder);
      expect(WeatherCondition.fromYrSymbol('sleetshowers_day'),
          WeatherCondition.sleet);
      expect(WeatherCondition.fromYrSymbol('heavysnow'),
          WeatherCondition.snow);
      expect(WeatherCondition.fromYrSymbol(null), isNull);
    });
  });

  group('ModelForecast.daily', () {
    test('aggregates min/max temp, precip sum and worst daytime condition',
        () {
      final points = [
        for (var h = 0; h < 24; h++)
          ForecastPoint(
            time: DateTime(2026, 7, 7, h),
            temperature: 10 + h.toDouble(),
            precipitation: h == 14 ? 2.5 : 0,
            condition:
                h == 14 ? WeatherCondition.rain : WeatherCondition.clear,
          ),
      ];
      final forecast =
          ModelForecast(model: WeatherModel.ecmwf, hourly: points);

      expect(forecast.daily, hasLength(1));
      final day = forecast.daily.single;
      expect(day.tempMin, 10);
      expect(day.tempMax, 33);
      expect(day.precipitation, 2.5);
      expect(day.condition, WeatherCondition.rain);
    });

    test('night-only condition does not override daytime', () {
      final points = [
        ForecastPoint(
          time: DateTime(2026, 7, 7, 2),
          temperature: 10,
          condition: WeatherCondition.thunder,
        ),
        ForecastPoint(
          time: DateTime(2026, 7, 7, 12),
          temperature: 20,
          condition: WeatherCondition.clear,
        ),
      ];
      final forecast =
          ModelForecast(model: WeatherModel.yr, hourly: points);
      expect(forecast.daily.single.condition, WeatherCondition.clear);
    });
  });
}

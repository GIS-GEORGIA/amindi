import 'package:flutter/material.dart';

/// Normalized sky/precipitation state shared by all sources.
/// Declaration order doubles as severity ranking (used when picking a
/// representative condition for a whole day).
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  fog,
  rain,
  sleet,
  snow,
  thunder;

  IconData get icon => switch (this) {
        clear => Icons.wb_sunny_outlined,
        partlyCloudy => Icons.wb_cloudy_outlined,
        cloudy => Icons.cloud_outlined,
        fog => Icons.blur_on,
        rain => Icons.water_drop_outlined,
        sleet => Icons.grain,
        snow => Icons.ac_unit,
        thunder => Icons.flash_on,
      };

  /// WMO weather interpretation codes (Open-Meteo `weather_code`).
  static WeatherCondition? fromWmoCode(int? code) => switch (code) {
        null => null,
        0 => clear,
        1 || 2 => partlyCloudy,
        3 => cloudy,
        45 || 48 => fog,
        >= 51 && <= 57 => rain,
        61 || 63 || 65 || 80 || 81 || 82 => rain,
        66 || 67 => sleet,
        >= 71 && <= 77 || 85 || 86 => snow,
        >= 95 && <= 99 => thunder,
        _ => cloudy,
      };

  /// MET Norway `symbol_code`, e.g. `lightrainshowers_day`.
  static WeatherCondition? fromYrSymbol(String? symbol) {
    if (symbol == null) return null;
    final base = symbol.split('_').first;
    if (base.contains('thunder')) return thunder;
    if (base.contains('sleet')) return sleet;
    if (base.contains('snow')) return snow;
    if (base.contains('rain')) return rain;
    if (base.contains('fog')) return fog;
    if (base.contains('cloudy')) {
      return base.contains('partly') ? partlyCloudy : cloudy;
    }
    if (base.contains('fair') || base.contains('clearsky')) {
      return base == 'fair' ? partlyCloudy : clear;
    }
    return cloudy;
  }
}

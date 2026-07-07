import 'dart:ui';

/// The four forecast sources shown side by side.
enum WeatherModel {
  ecmwf('ECMWF', 'ecmwf', Color(0xFF2E6FDB)),
  iconEu('ICON-EU', 'icon_eu', Color(0xFF2E9E5B)),
  gfs('GFS', 'gfs', Color(0xFFE08A00)),
  yr('YR', 'yr', Color(0xFF8A4FD8));

  const WeatherModel(this.label, this.key, this.color);

  /// Display name (Latin in both locales).
  final String label;

  /// Translation key suffix, e.g. `models.res.ecmwf`.
  final String key;

  /// Accent used to tell the model columns apart at a glance.
  final Color color;
}

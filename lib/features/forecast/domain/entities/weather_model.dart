/// The four forecast sources shown side by side.
enum WeatherModel {
  ecmwf('ECMWF', 'ecmwf'),
  iconEu('ICON-EU', 'icon_eu'),
  gfs('GFS', 'gfs'),
  yr('YR', 'yr');

  const WeatherModel(this.label, this.key);

  /// Display name (Latin in both locales).
  final String label;

  /// Translation key suffix, e.g. `models.res.ecmwf`.
  final String key;
}

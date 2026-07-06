abstract final class ApiConstants {
  static const String openMeteoBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String yrBaseUrl =
      'https://api.met.no/weatherapi/locationforecast/2.0/compact';

  /// Open-Meteo `models=` values, requested together in one call.
  static const String openMeteoModels = 'ecmwf_ifs025,icon_eu,gfs_seamless';

  /// Mandatory for api.met.no — requests without an identifying UA are blocked.
  static const String yrUserAgent = 'amindi/1.0 github.com/GIS-GEORGIA/amindi';
}

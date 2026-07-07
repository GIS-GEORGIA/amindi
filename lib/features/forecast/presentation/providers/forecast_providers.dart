import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/datasources/open_meteo_api.dart';
import '../../data/datasources/yr_api.dart';
import '../../data/repositories/forecast_repository.dart';
import '../../domain/entities/forecast_point.dart';

typedef Location = ({double lat, double lon});

final forecastRepositoryProvider = Provider<ForecastRepository>(
  (ref) => ForecastRepository(
    openMeteo: OpenMeteoApi(ref.watch(dioProvider)),
    yr: YrApi(ref.watch(dioProvider)),
  ),
);

final forecastProvider = FutureProvider.autoDispose
    .family<ForecastBundle, Location>(
  (ref, location) => ref
      .watch(forecastRepositoryProvider)
      .fetchAll(location.lat, location.lon),
);

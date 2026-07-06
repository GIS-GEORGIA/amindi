import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // api.met.no blocks requests without an identifying User-Agent.
        if (options.uri.host == 'api.met.no') {
          options.headers['User-Agent'] = ApiConstants.yrUserAgent;
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});

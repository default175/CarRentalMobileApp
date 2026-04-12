import 'package:dio/dio.dart';

import '../config/app_config.dart';

class ApiClient {
  ApiClient({required String baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout:
                const Duration(seconds: AppConfig.apiTimeoutSeconds),
            receiveTimeout:
                const Duration(seconds: AppConfig.apiTimeoutSeconds),
            headers: const {
              'Content-Type': 'application/json',
            },
          ),
        );

  final Dio dio;
}

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../controller/session_controller.dart';

class ApiClient {
  static Dio? _instance;
  static String get _baseUrl {
    const backendPath = '/practice_updated';

    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2$backendPath';
    }
    return 'http://localhost$backendPath';
  }

  static Dio get instance {
    if (_instance != null) return _instance!;

    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = Get.find<SessionController>().authToken.value;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    _instance = dio;
    return dio;
  }
}

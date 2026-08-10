import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../controller/session_controller.dart';

class ApiClient {
  static Dio? _instance;
  static String get _baseUrl {
    const backendPath = '/practice_updated';

    if (kIsWeb) {
      return 'http://192.168.0.210/eduplay-api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2$backendPath';
    }
    return 'http://192.168.0.210/eduplay-api';
  }

  static String get baseUrl => _baseUrl;

  static String resolveMediaUrl(String relativePath) {
    return '$baseUrl/$relativePath';
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

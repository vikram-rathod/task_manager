// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('➡️ REQUEST[${options.method}] => PATH: ${options.path}');
          print('📤 DATA: ${options.data}');
          print('📋 HEADERS: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('⬅️ RESPONSE[${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          print('❌ ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
          print('📛 ERROR DATA: ${error.response?.data}');
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Options? options,
      }) async {
    return await _dio.post(
      path,
      data: data,
      options: options,
    );
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Options? options,
      }) async {
    return await _dio.put(
      path,
      data: data,
      options: options,
    );
  }

  Future<Response> delete(
      String path, {
        Options? options,
      }) async {
    return await _dio.delete(
      path,
      options: options,
    );
  }
}
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
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
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
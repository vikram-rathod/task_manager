import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/api_constants.dart';
import '../../core/models/app_notification_acknow_model.dart';
import '../../core/models/task_model.dart';
import '../../core/network/dio_client.dart';
import '../auth/models/api_response.dart';

class AppNotificationService {
  final DioClient _dio;

  AppNotificationService(this._dio);


  Future<Response>
  getAppNotificationAcknowledgements({
    required String userId,
  }) async {

    final response = await _dio.post(
      ApiConstants.taskManagerAcknowdge,
      data: {
        'user_id': userId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );


    return response;
  }

  Future<ApiResponse<void>> taskManagerApproval({
    required int taskId,
    required int userId,
    required String taskStatus,
    required String notificationId,
  }) async {
    final response = await _dio.post(
      ApiConstants.taskManagerApproval,
      data: {
        'work_id': taskId,
        'user_id': userId,
        'status': taskStatus,
        'notification_id': notificationId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final apiResponse = ApiResponse<void>.fromJson(
      response.data,
          (data) => null,
    );
    return apiResponse;

  }


  Future<ApiResponse<void>> markAsReadFromUrl(String seenUrl) async {
    const String tag = "AppNotificationService";

    debugPrint("[$tag] markAsReadFromUrl called");
    debugPrint("[$tag] Request URL: $seenUrl");

    try {
      final response = await _dio.get(seenUrl);

      debugPrint("[$tag] HTTP Status Code: ${response.statusCode}");
      debugPrint("[$tag] Raw Response: ${response.data}");

      // Fix: Handle String response properly
      final Map<String, dynamic> jsonMap =
      response.data is String
          ? jsonDecode(response.data)
          : response.data as Map<String, dynamic>;

      final apiResponse = ApiResponse<void>.fromJson(
        jsonMap,
            (data) {},
      );

      debugPrint("[$tag] Parsed ApiResponse successfully");

      return apiResponse;
    } catch (e, stackTrace) {
      debugPrint("[$tag] Exception during API call");
      debugPrint("[$tag] Error: $e");
      debugPrint("[$tag] StackTrace: $stackTrace");

      rethrow;
    }
  }


}

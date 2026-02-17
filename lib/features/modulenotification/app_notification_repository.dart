import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:task_manager/features/auth/models/api_response.dart';
import 'package:task_manager/features/modulenotification/app_notification_service.dart';

import '../../core/models/app_notification_acknow_model.dart';

class AppNotificationRepository {
  final AppNotificationService _appNotificationService;

  AppNotificationRepository(this._appNotificationService);

  Future<ApiResponse<List<AppNotificationResponseModel>>> getNotifications({
    required String userId,
  }) async {
    try {
      final response =
      await _appNotificationService.getAppNotificationAcknowledgements(
        userId: userId,
      );

      final decoded = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final apiResponse =
      ApiResponse<List<AppNotificationResponseModel>>.fromJson(
        decoded,
            (data) {
          if (data == null) return [];
          return (data as List)
              .map((e) => AppNotificationResponseModel.fromJson(e))
              .toList();
        },
      );

      return apiResponse;
    } catch (e) {
      throw Exception("Failed to fetch notifications: $e");
    }
  }

  Future<ApiResponse<void>> taskManagerApproval({
    required int taskId,
    required int userId,
    required String taskStatus,
    required String notificationId,
  }) async {
    try {
      final response = await _appNotificationService.taskManagerApproval(
        taskId: taskId,
        userId: userId,
        taskStatus: taskStatus,
        notificationId: notificationId,
      );
      return response;
    } catch (e) {
      throw Exception("Failed to fetch notifications: $e");
    }
  }

  Future<ApiResponse<void>> markAsReadFromUrl(String seenUrl) async {
    const String tag = "NotificationRepository";

    debugPrint("[$tag] markAsReadFromUrl called");
    debugPrint("[$tag] SeenUrl: $seenUrl");

    try {
      final response =
      await _appNotificationService.markAsReadFromUrl(seenUrl);

      debugPrint("[$tag] Response received");
      debugPrint("[$tag] Status: ${response.status}");
      debugPrint("[$tag] Message: ${response.message}");

      return response;
    } catch (e, stackTrace) {
      debugPrint("[$tag] Exception occurred");
      debugPrint("[$tag] Error: $e");
      debugPrint("[$tag] StackTrace: $stackTrace");

      throw Exception("Failed to mark notification as read: $e");
    }
  }

}

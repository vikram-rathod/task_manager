import 'package:task_manager/features/auth/models/api_response.dart';
import 'package:task_manager/features/home/services/app_notification_service.dart';

import '../../../core/models/app_notification_acknow_model.dart';

class AppNotificationRepository {
  final AppNotificationService _appNotificationService;

  AppNotificationRepository(this._appNotificationService);

  /// Get In-App Notification List
  Future<ApiResponse<List<AppNotificationResponseModel>>> getNotifications({
    required String userId,
  }) async {
    try {
      final response = await _appNotificationService.getAppNotificationAcknowledgements(
        userId: userId,
      );
      return response;
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
}

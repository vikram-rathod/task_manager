import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/app_notification_acknow_model.dart';
import '../../../core/models/task_model.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/api_response.dart';

class AppNotificationService {
  final DioClient _dio;

  AppNotificationService(this._dio);


  Future<ApiResponse<List<AppNotificationResponseModel>>>
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

    final apiResponse =
    ApiResponse<List<AppNotificationResponseModel>>.fromJson(
      response.data,
          (data) => (data as List)
          .map((e) => AppNotificationResponseModel.fromJson(e))
          .toList(),
    );

    return apiResponse;
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


}

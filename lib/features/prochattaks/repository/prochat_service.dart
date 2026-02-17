import 'package:dio/dio.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/core/network/dio_client.dart';
import 'package:task_manager/features/prochattaks/repository/pro_chat_sync_model.dart';

import '../../../core/constants/api_constants.dart';
import '../../auth/models/api_response.dart';


class ProChatService {
  final DioClient _dio;

  ProChatService(this._dio);

  // Get Pro-Chat Task here...
  Future<ApiResponse<List<TMTasksModel>>> getProchatTaskList({
    required String userId,
    required String companyId,
    required String userType,
  }) async {
    final response = await _dio.post(
      ApiConstants.prochatTaskList,
      data: {'user_id': userId, 'comp_id': companyId, 'user_type': userType},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    final apiResponse = ApiResponse<List<TMTasksModel>>.fromJson(
      response.data as Map<String, dynamic>,
      (data) => (data as List)
          .map((e) => TMTasksModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );

    return apiResponse;
  }

  Future<ApiResponse<void>> assignProchatTask({
    required String userId,
    required String companyId,
    required String prochatTaskId,
    required String projectId,
    String? checkerId,
    String? makerId,
    String? pcEngrId,
  }) async {
    final response = await _dio.post(
      ApiConstants.prochatTaskTransfer,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'task_id': prochatTaskId,
        'project_id': projectId,
        'checker_id': checkerId,
        'maker_id': makerId,
        'pc_engr_id': pcEngrId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    print(response.data);

    return ApiResponse.fromJson(response.data, (data) => null);
  }
  Future<ApiResponse<ProChatTaskSyncModel>> syncProchatTasks({
    required String userId,
    required String companyId,
    required String userType,
  }) async {
    final response = await _dio.post(
      ApiConstants.prochatTaskInsert,
      data: {'user_id': userId, 'comp_id': companyId, 'user_type': userType},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    print(response.data);
    return ApiResponse.fromJson(response.data, (data) => ProChatTaskSyncModel.fromJson(data));
  }
}

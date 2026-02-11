import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../AllTasks/bloc/all_task_bloc.dart';
import '../../auth/models/api_response.dart';
import '../models/insert_data_model.dart';
import '../../../core/models/task_model.dart';

import '../../auth/models/user_model.dart';
import '../models/task_request.dart';

class TaskApiService {
  final DioClient _dio;
  final StorageService _storageService;
  TaskApiService(this._dio, this._storageService);

  /* ───────────────── Insert New Task ───────────────── */

  Future<ApiResponse<void>> insertNewTask({
    required int? makerId,
    required int? checkerId,
    required int? pcEngrId,
    required String taskDesc,
    required int? projectId,
    String? tentativeDate,
    String? remarkIfAny,
    List<MultipartFile>? files,
  }) async {
    final formData = FormData.fromMap({
      'user_id': await _storageService.read(StorageKeys.userId),
      'comp_id': await _storageService.read(StorageKeys.companyId),
      'user_type': await _storageService.read(StorageKeys.userType),
      'maker_id': makerId,
      'checker_id': checkerId,
      'pc_engr_id': pcEngrId,
      'task_desc': taskDesc,
      'project_id': projectId,
      if (tentativeDate != null) 'end_date': tentativeDate,
      if (remarkIfAny != null) 'remark_if_any': remarkIfAny,
      if (files != null) 'file': files,
    });

    debugPrint('InsertNewTask called with:');
    debugPrint(' makerId: $makerId');
    debugPrint(' checkerId: $checkerId');
    debugPrint(' pcEngrId: $pcEngrId');
    debugPrint(' taskDesc: $taskDesc');
    debugPrint(' projectId: $projectId');
    debugPrint(' tentativeDate: $tentativeDate');
    debugPrint(' remarkIfAny: $remarkIfAny');
    debugPrint(' files count: ${files?.length ?? 0}');


    final response =
    await _dio.post(ApiConstants.insertNewTask, data: formData);

    return ApiResponse.fromJson(
      response.data,
          (dataJson) => InsertIdData.fromJson(dataJson as Map<String, dynamic>),
    );

  }

  /* ───────────────── Get All Tasks ───────────────── */

  Future<ApiResponse<List<TMTasksModel>>> getAllTask(
      TaskRequestBody body) async {
    final response = await _dio.post(
      ApiConstants.taskList,
      data: body.toJson(),
    );

    return ApiResponse.fromJson(
      response.data,
          (data) =>
          (data as List).map((e) => TMTasksModel.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<TMTasksModel>> getTaskDetails(int taskId) async {
    final response = await _dio.post(
      ApiConstants.taskDetails,
      data: {
        'task_id': taskId,
        'user_id': await _storageService.read(StorageKeys.userId),
        'comp_id': await _storageService.read(StorageKeys.companyId),
        'user_type': await _storageService.read(StorageKeys.userType),
      },
    );

    return ApiResponse.fromJson(
      response.data,
          (data) => TMTasksModel.fromJson(data as Map<String, dynamic>),
    );
  }


  /* ───────────────── Employee Wise Tasks ───────────────── */

  Future<ApiResponse<List<TMTasksModel>>> getAllTaskEmployeeWise({
    required String tabId,
    required String userId,
    required String compId,
    required String userType,
    int page = 1,
    int size = 10,
    String? employeeId,
    String? search,
  }) async {
    final response = await _dio.post(
      ApiConstants.employeeWiseTaskList,
      data: {
        'tab_id': tabId,
        'user_id': userId,
        'comp_id': compId,
        'user_type': userType,
        'page': page,
        'size': size,
        'employee_id': employeeId,
        'search': search,
      },
    );

    return ApiResponse.fromJson(
      response.data,
          (data) =>
          (data as List).map((e) => TMTasksModel.fromJson(e)).toList(),
    );
  }

  /* ───────────────── Task By User ───────────────── */

  Future<ApiResponse<List<TMTasksModel>>> getAllTaskByUserId({
    required String userId,
    required String compId,
    required String userType,
    String? projectId,
    String? makerId,
    String? taskStatus,
    int page = 1,
    int size = 10,
    String? checkerId,
    String? pcEngrId,
    String? search,
  }) async {
    final response = await _dio.post(
      ApiConstants.taskListByUserId,
      data: {
        'user_id': userId,
        'comp_id': compId,
        'user_type': userType,
        'project_id': projectId,
        'maker_id': makerId,
        'task_status': taskStatus,
        'page': page,
        'size': size,
        'checker_id': checkerId,
        'pc_engr_id': pcEngrId,
        'search': search,
      },
    );

    return ApiResponse.fromJson(
      response.data,
          (data) =>
          (data as List).map((e) => TMTasksModel.fromJson(e)).toList(),
    );
  }

  /* ───────────────── Over Due / Due Today ───────────────── */

  Future<ApiResponse<List<TMTasksModel>>> getOverDueTasks({
    required String userId,
    required String compId,
    required String userType,
    required String type,
    int page = 1,
    int size = 10,
    String? search,
  }) async {
    final response = await _dio.post(
      ApiConstants.taskListOverDue,
      data: {
        'user_id': userId,
        'comp_id': compId,
        'user_type': userType,
        'page': page,
        'size': size,
        'search': search,
        'type': type,
      },
    );

    return ApiResponse.fromJson(
      response.data,
          (data) =>
          (data as List).map((e) => TMTasksModel.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<List<TMTasksModel>>> getDueTodayTasks({
    required String userId,
    required String compId,
    required String userType,
    required String type,
    int page = 1,
    int size = 10,
    String? search,
  }) async {
    final response = await _dio.post(
      ApiConstants.taskListDueToday,
      data: {
        'user_id': userId,
        'comp_id': compId,
        'user_type': userType,
        'page': page,
        'size': size,
        'search': search,
        'type': type,
      },
    );

    return ApiResponse.fromJson(
      response.data,
          (data) =>
          (data as List).map((e) => TMTasksModel.fromJson(e)).toList(),
    );
  }
}

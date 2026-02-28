import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:task_manager/core/models/project_model.dart';
import 'package:task_manager/features/auth/models/api_response.dart';
import 'package:task_manager/features/home/model/dash_board_count_model.dart';
import 'package:task_manager/features/home/model/employee_count_list_data.dart';
import 'package:task_manager/features/home/model/employee_count_model.dart';
import 'package:task_manager/features/home/model/project_count_list_data.dart';
import 'package:task_manager/features/home/model/task_history_model.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/task_model.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/user_model.dart';
import '../model/project_count_model.dart';

class HomeApiService {
  final DioClient _dio;

  HomeApiService(this._dio);

  // ===================== PROJECT LIST =====================
  Future<ApiResponse<List<ProjectModel>>> getProjectsList({
    required String userId,
    required String companyId,
    required String userType,
  }) async {
    final response = await _dio.post(
      ApiConstants.getProjectsList,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'user_type': userType,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    debugPrint("homeApi RAW ProjectList => ${response.data}");

    final apiResponse = ApiResponse<List<ProjectModel>>.fromJson(
      response.data as Map<String, dynamic>,
          (data) => (data as List)
          .map((e) =>
          ProjectModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );

    debugPrint("homeApi Parsed ProjectList => $apiResponse");

    return apiResponse;
  }

  Future<ApiResponse<ProjectListData>> getProjectsCountList({
    required String userId,
    required String companyId,
    required String userType,
    required String page,
    required String size,
  }) async {
    final response = await _dio.post(
      ApiConstants.getProjectsCountList,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'user_type': userType,
        'page': page,
        'size': size,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final apiResponse = ApiResponse<ProjectListData>.fromJson(
      response.data as Map<String, dynamic>,
          (data) => ProjectListData.fromJson(Map<String, dynamic>.from(data)),
    );

    return apiResponse;
  }
  Future<ApiResponse<EmployeeCountListData>> getEmployeeWiseTaskList({
    required String userId,
    required String companyId,
    required String userType,
    required String page,
    required String size,
  }) async {
    final response = await _dio.post(
      ApiConstants.getEmployeeWiseTaskList,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'user_type': userType,
        'page': page,
        'size': size,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    debugPrint("homeApi RAW EmployeeWiseTaskList => ${response.data}");

    final apiResponse = ApiResponse<EmployeeCountListData>.fromJson(
      response.data as Map<String, dynamic>,
          (data) =>
              EmployeeCountListData.fromJson(Map<String, dynamic>.from(data)),
    );
    debugPrint("homeApi Parsed EmployeeWiseTaskList => $apiResponse");
    return apiResponse;
  }

  // ===================== TASK MANAGER USER LIST =====================
  Future<ApiResponse<List<UserModel>>> getTaskManagerUserList({
    required String userId,
    required String companyId,
    required String userType,
    required String projectId,
  }) async {
    final response = await _dio.post(
      ApiConstants.userList,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'user_type': userType,
        'project_id': projectId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    debugPrint("homeApi RAW TaskManagerUsers => ${response.data}");

    final apiResponse = ApiResponse<List<UserModel>>.fromJson(
      response.data as Map<String, dynamic>,
          (data) => (data as List)
          .map((e) =>
          UserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );

    debugPrint("homeApi Parsed TaskManagerUsers => $apiResponse");

    return apiResponse;
  }

  // ===================== PROJECT COORDINATOR USER LIST =====================
  Future<ApiResponse<List<UserModel>>> getProjectCoordinatorUserList({
    required String userId,
    required String companyId,
    required String userType,
    required String projectId,
  }) async {
    final response = await _dio.post(
      ApiConstants.pcEnggUserList,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'user_type': userType,
        'project_id': projectId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    debugPrint("homeApi RAW ProjectCoordinatorUsers => ${response.data}");

    final apiResponse = ApiResponse<List<UserModel>>.fromJson(
      response.data as Map<String, dynamic>,
          (data) => (data as List)
          .map((e) =>
          UserModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );

    debugPrint("homeApi Parsed ProjectCoordinatorUsers => $apiResponse");

    return apiResponse;
  }

  Future<ApiResponse<List<TaskHistoryModel>>> getTaskHistory(
      {required String userId, required String companyId, required String userType}) async {
    final response = await _dio.post(
      ApiConstants.taskHistory,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'user_type': userType,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    debugPrint("homeApi RAW TaskHistory => ${response.data}");
    final apiResponse = ApiResponse<List<TaskHistoryModel>>.fromJson(
      response.data as Map<String, dynamic>,
          (data) =>
          (data as List)
              .map((e) =>
              TaskHistoryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
    );
    debugPrint("homeApi Parsed TaskHistory => $apiResponse");
    return apiResponse;
  }

  Future<ApiResponse<DashboardCountModel>> getDashboardCounts(
      {required String userId, required String companyId, required String userType}) async {
    debugPrint("getDashboardCountsHome|Service: userId=$userId, companyId=$companyId, userType=$userType");
    final response = await _dio.post(
        ApiConstants.tmDashboardCount,
        data: {
          'user_id': userId,
          'comp_id': companyId,
          'user_type': userType,
          'app_type' :"2"
        },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );
    debugPrint("homeApi RAW DashboardCounts |Service => ${response.data}");
    late final Map<String, dynamic> json;

    if (response.data is String) {
      json = jsonDecode(response.data as String);
    } else {
      json = Map<String, dynamic>.from(response.data);
    }

    return ApiResponse<DashboardCountModel>.fromJson(
      json,
          (data) => DashboardCountModel.fromJson(
        Map<String, dynamic>.from(data),
      ),
    );
  }

  Future<ApiResponse<List<TMTasksModel>>> getTodaysTmTasks({
    required String userId,
    required String companyId,
    required String userType,
    required int page,
    int size = 10,
    required bool isMyTasks,
  }) async {


    final response = await _dio.post(
      ApiConstants.todaysTask,
      data: {
        'user_id': userId,
        'comp_id': companyId,
        'user_type': userType,
        'type': isMyTasks ? '0' : '1', // self 0 , 1 other
        'page': page.toString(),
        'size': size.toString(),
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    debugPrint("homeApi RAW TodaysTasks (isMyTasks: $isMyTasks, page: $page) => ${response.data}");

    final apiResponse = ApiResponse<List<TMTasksModel>>.fromJson(
      response.data as Map<String, dynamic>,
          (data) => (data as List)
          .map((e) => TMTasksModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );

    debugPrint("homeApi Parsed TodaysTasks => $apiResponse");

    return apiResponse;
  }


}


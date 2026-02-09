import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:task_manager/core/models/project_model.dart';
import 'package:task_manager/features/auth/models/api_response.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../../auth/models/user_model.dart';

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
}

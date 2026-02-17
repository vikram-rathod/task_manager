import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../../../core/constants/api_constants.dart';
import '../../../core/models/task_detail_response.dart';
import '../../../core/models/taskchat/task_chat_message.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../AllTasks/bloc/all_task_bloc.dart';
import '../../auth/models/api_response.dart';
import '../models/chat_insert_data.dart';
import '../models/insert_data_model.dart';
import '../../../core/models/task_model.dart';

import '../../auth/models/user_model.dart';
import '../models/task_request.dart';

class TaskApiService {
  final DioClient _dio;
  final StorageService _storageService;
  final String _tag = "TaskApiService";


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

  Future<ApiResponse<TaskDetailsResponse>> getTaskDetails(int taskId) async {
    final response = await _dio.post(
      ApiConstants.taskDetails,
      data: {
        'task_id': taskId,
        'user_id': await _storageService.read(StorageKeys.userId),
        'comp_id': await _storageService.read(StorageKeys.companyId),
        'user_type': await _storageService.read(StorageKeys.userType),
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return ApiResponse.fromJson(
      response.data,
          (data) => TaskDetailsResponse.fromJson(data as Map<String, dynamic>),
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
    debugPrint('getAllTaskEmployeeWise called with:');
    debugPrint(' tabId: $tabId');
    debugPrint(' userId: $userId');
    debugPrint(' compId: $compId');
    debugPrint(' userType: $userType');
    debugPrint(' page: $page');
    debugPrint(' size: $size');
    debugPrint(' employeeId: $employeeId');
    debugPrint(' search: $search');

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
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
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
    debugPrint('getOverDueTasks called with: userId: $userId, compId: $compId, userType: $userType, type: $type'
        ', page: $page, size: $size, search: $search' );

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
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
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

    debugPrint('getDueTodayTasks called with: userId: $userId, compId: $compId, userType: $userType'
        ', type: $type, page: $page, size: $size, search: $search');


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
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return ApiResponse.fromJson(
      response.data,
          (data) =>
          (data as List).map((e) => TMTasksModel.fromJson(e)).toList(),
    );
  }

  Future<ApiResponse<List<TimelineItem>>> getTaskChat({
    required String taskId,
  }) async {
    final response = await _dio.post(
      ApiConstants.getTaskChat,
      data: {
        'work_id': taskId,
      },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
    );
    return ApiResponse.fromJson(
      response.data,
          (data) =>
          (data as List).map((e) => TimelineItem.fromJson(e)).toList(),
    );

  }

  Future<ApiResponse<ChatInsertData>> insertTaskChat({
    required String workId,
    required String userId,
    required String compId,
    required String message,
    required String mentionUserIds,
    List<File>? files,
    String? replyTo,
  }) async {

    FormData formData = FormData();

    formData.fields.add(MapEntry("work_id", workId));
    formData.fields.add(MapEntry("user_id", userId));
    formData.fields.add(MapEntry("comp_id", compId));
    formData.fields.add(MapEntry("chat_message", message));
    formData.fields.add(MapEntry("reply_to", replyTo ?? ""));
    formData.fields.add(MapEntry("mention_userids", mentionUserIds ?? ""));

    if (files != null && files.isNotEmpty) {
      for (var file in files) {
        formData.files.add(
          MapEntry(
            "file[]",
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }
    }

    final response = await _dio.post(
      ApiConstants.insertTaskChat,
      data: formData,
      options: Options(
        contentType: "multipart/form-data",
      ),
    );
    return ApiResponse.fromJson(
      response.data,
          (data) => ChatInsertData.fromJson(data as Map<String, dynamic>),
    );
  }

}

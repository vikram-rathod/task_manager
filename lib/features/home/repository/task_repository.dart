import 'dart:ffi';

import 'package:dio/dio.dart';

import '../../../core/models/task_detail_response.dart';
import '../../../core/models/task_model.dart';
import '../../auth/models/api_response.dart';
import '../../createtask/models/chat_insert_data.dart';
import '../../createtask/models/task_request.dart';
import '../../createtask/services/task_service.dart';

class TaskRepository {
  final TaskApiService _api;

  TaskRepository(this._api);

  Future<ApiResponse<List<TMTasksModel>>> fetchTasks(TaskRequestBody body) =>
      _api.getAllTask(body);

  Future<ApiResponse<TaskDetailsResponse>> fetchTaskDetails(int taskId) =>
      _api.getTaskDetails(taskId);

  Future<ApiResponse<List<TMTasksModel>>> fetchEmployeeWiseTasks({
    required String tabId,
    required String userId,
    required String compId,
    required String userType,
    int page = 1,
    int size = 10,
    String? employeeId,
    String? search,
  }) => _api.getAllTaskEmployeeWise(
    tabId: tabId,
    userId: userId,
    compId: compId,
    userType: userType,
    employeeId: employeeId,
    search: search,
    page: page,
    size: size,
  );

  // overdue Task
  Future<ApiResponse<List<TMTasksModel>>> fetchOverdueTasks({
    required String type,
    required String userId,
    required String compId,
    required String userType,
    int page = 1,
    int size = 10,
    String? search,
  }) => _api.getOverDueTasks(
    compId: compId,
    type: type,
    userId: userId,
    userType: userType,
    page: page,
    size: size,
    search: search,
  );

  // overdue Task
  Future<ApiResponse<List<TMTasksModel>>> fetchDueTodayTasks({
    required String type,
    required String userId,
    required String compId,
    required String userType,
    int page = 1,
    int size = 10,
    String? search,
  }) => _api.getDueTodayTasks(
    compId: compId,
    type: type,
    userId: userId,
    userType: userType,
    page: page,
    size: size,
    search: search,
  );

  Future<ApiResponse<void>> createTask({
    required int? makerId,
    required int? checkerId,
    required int? pcEngrId,
    required String taskDesc,
    required int? projectId,
    String? tentativeDate,
    String? remark,
    List<MultipartFile>? files,
  }) => _api.insertNewTask(
    makerId: makerId,
    checkerId: checkerId,
    pcEngrId: pcEngrId,
    taskDesc: taskDesc,
    projectId: projectId,
    tentativeDate: tentativeDate,
    remarkIfAny: remark,
    files: files,
  );

  //Get task Chat
  Future<ApiResponse<List<TMTasksModel>>> getTaskChat({required int taskId}) =>
      _api.getTaskChat(taskId: taskId);

  // Insert Task Chat
  Future<ApiResponse<ChatInsertData>> insertTaskChat({
    required int? workId,
    required int? userId,
    required int? compId,
    required String chatMessage,
    List<MultipartFile>? files,
    String? replyTo,
  }) => _api.insertTaskChat(
    workId: workId,
    userId: userId,
    compId: compId,
    chatMessage: chatMessage,
    files: files,
    replyTo: replyTo,
  );
}

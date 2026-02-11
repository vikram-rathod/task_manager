import 'package:flutter/cupertino.dart';
import 'package:task_manager/features/home/model/dash_board_count_model.dart';
import 'package:task_manager/features/home/model/task_history_model.dart';

import '../../../core/models/project_model.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../auth/models/api_response.dart';
import '../../auth/models/user_model.dart';
import '../model/employee_count_model.dart';
import '../model/project_count_model.dart';
import '../services/home_service.dart';

class HomeRepository {

  final HomeApiService _homeService;

  final StorageService _storageService;


  HomeRepository(this._homeService, this._storageService);

  Future<List<ProjectModel>> getProjectsList() async {

    debugPrint("getProjectsList: start");
    final userId = await _storageService.read(StorageKeys.userId) ?? "";
    final companyId = await _storageService.read(StorageKeys.companyId) ?? "";
    final userType = await _storageService.read(StorageKeys.userType) ?? "";
    debugPrint("getProjectsList: userId=$userId, companyId=$companyId, userType=$userType");

    final ApiResponse<List<ProjectModel>> response =
    await _homeService.getProjectsList(
      userId: userId,
      companyId : companyId ,
      userType: userType,
    );
    debugPrint("getProjectsList: $response");

    if (response.status == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to load projects');
    }
  }


  Future<List<ProjectCountModel>> getProjectsCountList() async {

    final userId = await _storageService.read(StorageKeys.userId) ?? "";
    final companyId = await _storageService.read(StorageKeys.companyId) ?? "";
    final userType = await _storageService.read(StorageKeys.userType) ?? "";
    debugPrint("getProjectsCountList: userId=$userId, companyId=$companyId, userType=$userType");

    final ApiResponse<List<ProjectCountModel>> response =
    await _homeService.getProjectsCountList(
      userId: userId,
      companyId : companyId ,
      userType: userType,
    );

    if (response.status == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message);
    }
  }

  Future<List<EmployeeModel>> getEmployeeWiseTaskList() async {

    final userId = await _storageService.read(StorageKeys.userId) ?? "";
    final companyId = await _storageService.read(StorageKeys.companyId) ?? "";
    final userType = await _storageService.read(StorageKeys.userType) ?? "";
    debugPrint("EmployeeModel: userId=$userId, companyId=$companyId, userType=$userType");

    final ApiResponse<List<EmployeeModel>> response =
    await _homeService.getEmployeeWiseTaskList(
      userId: userId,
      companyId : companyId ,
      userType: userType,
    );

    debugPrint("EmployeeModel response: $response");

    if (response.status == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message); 
    }
  }

// ===================== TASK MANAGER USER LIST =====================
  Future<List<UserModel>> getTaskManagerUserList({
    required String projectId,
  }) async {
    final userId = await _storageService.read(StorageKeys.userId) ?? "";
    final companyId =
        await _storageService.read(StorageKeys.companyId) ?? "";
    final userType =
        await _storageService.read(StorageKeys.userType) ?? "";

    debugPrint(
        "getTaskManagerUserList: userId=$userId, companyId=$companyId, userType=$userType, projectId=$projectId");

    final ApiResponse<List<UserModel>> response =
    await _homeService.getTaskManagerUserList(
      userId: userId,
      companyId: companyId,
      userType: userType,
      projectId: projectId,
    );

    debugPrint("getTaskManagerUserList response => $response");

    if (response.status == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to load users');
    }
  }

  // ===================== PROJECT COORDINATOR USER LIST =====================
  Future<List<UserModel>> getProjectCoordinatorUserList({
    required String projectId,
  }) async {
    final userId = await _storageService.read(StorageKeys.userId) ?? "";
    final companyId =
        await _storageService.read(StorageKeys.companyId) ?? "";
    final userType =
        await _storageService.read(StorageKeys.userType) ?? "";

    debugPrint(
        "getProjectCoordinatorUserList: userId=$userId, companyId=$companyId, userType=$userType, projectId=$projectId");

    final ApiResponse<List<UserModel>> response =
    await _homeService.getProjectCoordinatorUserList(
      userId: userId,
      companyId: companyId,
      userType: userType,
      projectId: projectId,
    );

    debugPrint("getProjectCoordinatorUserList response => $response");

    if (response.status == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to load coordinators');
    }
  }


  Future<List<TaskHistoryModel>> getTaskHistory() async {
    final userId = await _storageService.read(StorageKeys.userId) ?? "";
    final companyId = await _storageService.read(StorageKeys.companyId) ?? "";
    final userType = await _storageService.read(StorageKeys.userType) ?? "";
    debugPrint("getTaskHistory: userId=$userId, companyId=$companyId, userType=$userType");

    final ApiResponse<List<TaskHistoryModel>> response =
    await _homeService.getTaskHistory(
      userId: userId,
      companyId : companyId ,
      userType: userType,
    );
    debugPrint("getTaskHistory: $response");
    if (response.status == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to load projects');
    }
  }

  Future<DashboardCountModel> getDashboardCounts() async {
    final userId = await _storageService.read(StorageKeys.userId) ?? "";
    final companyId = await _storageService.read(StorageKeys.companyId) ?? "";
    final userType = await _storageService.read(StorageKeys.userType) ?? "";
    debugPrint("getDashboardCounts: userId=$userId, companyId=$companyId, userType=$userType");

    final ApiResponse<DashboardCountModel> response =
    await _homeService.getDashboardCounts(
      userId: userId,
      companyId : companyId ,
      userType: userType,
    );
    debugPrint("getDashboardCounts: $response");
    if (response.status == true && response.data != null) {
      return response.data!;
    } else {
      throw Exception(response.message ?? 'Failed to load projects');
    }
  }
}



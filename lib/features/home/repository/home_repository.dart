import 'package:flutter/cupertino.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/features/home/model/dash_board_count_model.dart';
import 'package:task_manager/features/home/model/task_history_model.dart';

import '../../../core/models/project_model.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../auth/models/api_response.dart';
import '../../auth/models/user_model.dart';
import '../../utils/app_exception.dart';
import '../model/employee_count_model.dart';
import '../model/project_count_model.dart';
import '../services/home_service.dart';

class HomeRepository {
  final HomeApiService _homeService;
  final StorageService _storageService;

  HomeRepository(this._homeService, this._storageService);

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<({String userId, String companyId, String userType})>
  _getCredentials() async {
    return (
    userId: await _storageService.read(StorageKeys.userId) ?? '',
    companyId: await _storageService.read(StorageKeys.companyId) ?? '',
    userType: await _storageService.read(StorageKeys.userType) ?? '',
    );
  }

  /// Throws [ApiException] when the response status is false or data is null.
  T _requireData<T>(ApiResponse<T> response, String fallbackMessage) {
    if (response.status == true && response.data != null) {
      return response.data as T;
    }
    throw ApiException(
      message: response.message.isNotEmpty == true
          ? response.message
          : fallbackMessage,
    );
  }

  // ── Projects ───────────────────────────────────────────────────────────────

  Future<List<ProjectModel>> getProjectsList() async {
    try {
      final c = await _getCredentials();
      debugPrint('getProjectsList: userId=${c.userId}');
      final response = await _homeService.getProjectsList(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
      );
      return _requireData(response, 'Failed to load projects.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }

  Future<List<ProjectCountModel>> getProjectsCountList() async {
    try {
      final c = await _getCredentials();
      debugPrint('getProjectsCountList: userId=${c.userId}');
      final response = await _homeService.getProjectsCountList(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
      );
      return _requireData(response, 'Failed to load project counts.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }

  // ── Employees ──────────────────────────────────────────────────────────────

  Future<List<EmployeeModel>> getEmployeeWiseTaskList() async {
    try {
      final c = await _getCredentials();
      debugPrint('getEmployeeWiseTaskList: userId=${c.userId}');
      final response = await _homeService.getEmployeeWiseTaskList(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
      );
      return _requireData(response, 'Failed to load employee task list.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<List<UserModel>> getTaskManagerUserList({
    required String projectId,
  }) async {
    try {
      final c = await _getCredentials();
      debugPrint('getTaskManagerUserList: projectId=$projectId');
      final response = await _homeService.getTaskManagerUserList(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
        projectId: projectId,
      );
      return _requireData(response, 'Failed to load users.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }

  Future<List<UserModel>> getProjectCoordinatorUserList({
    required String projectId,
  }) async {
    try {
      final c = await _getCredentials();
      debugPrint('getProjectCoordinatorUserList: projectId=$projectId');
      final response = await _homeService.getProjectCoordinatorUserList(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
        projectId: projectId,
      );
      return _requireData(response, 'Failed to load coordinators.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }

  // ── Dashboard ──────────────────────────────────────────────────────────────

  Future<DashboardCountModel> getDashboardCounts() async {
    try {
      final c = await _getCredentials();
      debugPrint('getDashboardCounts: userId=${c.userId}');
      final response = await _homeService.getDashboardCounts(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
      );
      return _requireData(response, 'Failed to load dashboard counts.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }

  Future<List<TaskHistoryModel>> getTaskHistory() async {
    try {
      final c = await _getCredentials();
      debugPrint('getTaskHistory: userId=${c.userId}');
      final response = await _homeService.getTaskHistory(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
      );
      return _requireData(response, 'Failed to load task history.');
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }

  // ── Today's Tasks ──────────────────────────────────────────────────────────

  Future<List<TMTasksModel>> getTodaysTmTasks({
    required int page,
    required bool isMyTasks,
    int size = 10,
  }) async {
    try {
      final c = await _getCredentials();
      debugPrint('getTodaysTmTasks: page=$page, isMyTasks=$isMyTasks');
      final response = await _homeService.getTodaysTmTasks(
        userId: c.userId,
        companyId: c.companyId,
        userType: c.userType,
        page: page,
        isMyTasks: isMyTasks,
        size: size,
      );

      if (response.status == true) return response.data ?? [];

      // "No tasks found" is a valid empty state, not an error.
      final msg = response.message.toLowerCase() ?? '';
      if (msg.contains('no task') || msg.contains('no data')) return [];

      throw ApiException(
        message: response.message ?? 'Failed to load today\'s tasks.',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppExceptionMapper.from(e);
    }
  }
}
import 'package:task_manager/features/task/service/task_list_service.dart';

import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../createtask/services/task_service.dart';
import '../model/task_list_models.dart';

class TaskListRepository {
  final TaskListService apiService;
  final StorageService storage;

  TaskListRepository(this.apiService, this.storage);

  Future<List<TaskItem>> fetchTaskHierarchy({
    required String projectId,
    required String tabId,
  }) async {
    final userId = await storage.read(StorageKeys.userId) ?? "";
    final compId = await storage.read(StorageKeys.companyId) ?? "";
    final userType = await storage.read(StorageKeys.userType) ?? "";

    final response = await apiService.fetchTaskHierarchy(
      userId: userId,
      compId: compId,
      projectId: projectId,
      tabId: tabId,
      userType: userType,
    );

    return response;
  }
}

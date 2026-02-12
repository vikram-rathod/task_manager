import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../model/task_list_models.dart';

class TaskListService {
  final DioClient _dio;

  TaskListService(this._dio);

  Future<List<TaskItem>> fetchTaskHierarchy({
    required String userId,
    required String compId,
    required String projectId,
    required String tabId,
    required String userType,
  }) async {
    final response = await _dio.post(
      "task_list/task_list_on_project.php",
      data: {
        "user_id": userId,
        "comp_id": compId,
        "tab_id": tabId,
        "project_id": projectId,
        "user_fix_id": userId,
        "user_type": userType,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => TaskItem.fromJson(e)).toList();
  }

  Future<bool> transferTask({
    required String userId,
    required String compId,
    required String taskId,
    required String projectId,
    required String userType,
  }) async {
    final response = await _dio.post(
      "task_list/task_transfer.php",
      data: {
        "user_id": userId,
        "comp_id": compId,
        "task_id": taskId,
        "project_id": projectId,
        "user_type": userType,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return response.data["status"] == true;
  }
}

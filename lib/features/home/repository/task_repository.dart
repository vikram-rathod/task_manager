import 'package:dio/dio.dart';

import '../../auth/models/api_response.dart';
import '../../../core/models/task_model.dart';
import '../../createtask/models/task_request.dart';
import '../../createtask/services/task_service.dart';

class TaskRepository {
  final TaskApiService _api;

  TaskRepository(this._api);

  Future<ApiResponse<List<TMTasksModel>>> fetchTasks(
      TaskRequestBody body) =>
      _api.getAllTask(body);


  Future<ApiResponse<TMTasksModel>> fetchTaskDetails(int taskId) =>
      _api.getTaskDetails(taskId);    


  Future<ApiResponse<void>> createTask({
    required int? makerId,
    required int? checkerId,
    required int? pcEngrId,
    required String taskDesc,
    required int? projectId,
    String? tentativeDate,
    String? remark,
    List<MultipartFile>? files,
  }) =>

      _api.insertNewTask(
        makerId: makerId,
        checkerId: checkerId,
        pcEngrId: pcEngrId,
        taskDesc: taskDesc,
        projectId: projectId,
        tentativeDate: tentativeDate,
        remarkIfAny: remark,
        files: files,
      );
}

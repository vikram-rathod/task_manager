

import 'package:task_manager/features/prochattaks/repository/pro_chat_sync_model.dart';
import 'package:task_manager/features/prochattaks/repository/prochat_service.dart';

import '../../../core/models/task_model.dart';
import '../../auth/models/api_response.dart';

class ProchatTaskRepository {
  final ProChatService _proChatService;

  ProchatTaskRepository(this._proChatService);

  Future<ApiResponse<List<TMTasksModel>>> getProchatTaskList({
    required String userId,
    required String companyId,
    required String userType,
  }) => _proChatService.getProchatTaskList(
    userId: userId,
    companyId: companyId,
    userType: userType,
  );

  Future<void> assignProchatTask({
    required String userId,
    required String companyId,
    required String prochatTaskId,
    required String projectId,
    String? checkerId,
    String? makerId,
    String? pcEngrId,
  }) => _proChatService.assignProchatTask(
    prochatTaskId: prochatTaskId,
    projectId: projectId,
    checkerId: checkerId,
    makerId: makerId,
    pcEngrId: pcEngrId,
    userId: userId,
    companyId: companyId,
  );

  Future<ApiResponse<ProChatTaskSyncModel>> syncProchatTasks({
    required String userId,
    required String companyId,
    required String userType,
  }) => _proChatService.syncProchatTasks(
    userId: userId,
    companyId: companyId,
    userType: userType,
  );
}


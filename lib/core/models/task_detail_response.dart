import 'package:task_manager/features/home/model/task_history_model.dart';

import '../../../core/models/task_model.dart';

class TaskDetailsResponse {
  final TMTasksModel taskDetails;
  final List<TaskHistoryModel> history;

  TaskDetailsResponse({
    required this.taskDetails,
    required this.history,
  });

  factory TaskDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TaskDetailsResponse(
      taskDetails: TMTasksModel.fromJson(
        json['task_details'] as Map<String, dynamic>,
      ),
      history: (json['history'] as List<dynamic>?)
          ?.map((e) => TaskHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_details': taskDetails.toJson(),
      'history': history.map((e) => e.toJson()).toList(),
    };
  }
}

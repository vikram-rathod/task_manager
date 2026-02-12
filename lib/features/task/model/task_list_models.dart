class TaskListResponse {
  final bool status;
  final String message;
  final List<TaskItem> data;

  TaskListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => TaskItem.fromJson(e))
          .toList(),
    );
  }
}

class TaskItem {
  final int itemId;
  final String itemName;
  final List<TaskCategory> categories;

  TaskItem({
    required this.itemId,
    required this.itemName,
    required this.categories,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      categories: (json['categories'] as List? ?? [])
          .map((e) => TaskCategory.fromJson(e))
          .toList(),
    );
  }
}

class TaskCategory {
  final int categoryId;
  final String categoryName;
  final List<TaskData> tasks;

  TaskCategory({
    required this.categoryId,
    required this.categoryName,
    required this.tasks,
  });

  factory TaskCategory.fromJson(Map<String, dynamic> json) {
    return TaskCategory(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => TaskData.fromJson(e))
          .toList(),
    );
  }
}

class TaskData {
  final int taskId;
  final String taskName;
  final bool transferStatus;
  final TaskDetails? taskDetails;

  TaskData({
    required this.taskId,
    required this.taskName,
    required this.transferStatus,
    this.taskDetails,
  });

  factory TaskData.fromJson(Map<String, dynamic> json) {
    return TaskData(
      taskId: json['task_id'] ?? 0,
      taskName: json['task_name'] ?? '',
      transferStatus: json['transfer_status'] ?? false,
      taskDetails: json['task_details'] != null
          ? TaskDetails.fromJson(json['task_details'])
          : null,
    );
  }
}

class TaskDetails {
  final String? makerName;
  final String? checkerName;
  final String? pcEngrName;
  final String? status;
  final String? priority;

  TaskDetails({
    this.makerName,
    this.checkerName,
    this.pcEngrName,
    this.status,
    this.priority,
  });

  factory TaskDetails.fromJson(Map<String, dynamic> json) {
    return TaskDetails(
      makerName: json['maker_name'],
      checkerName: json['checker_name'],
      pcEngrName: json['pc_engr_name'],
      status: json['status'],
      priority: json['priority'],
    );
  }
}

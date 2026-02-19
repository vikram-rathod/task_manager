class AssignTaskRequest {
  final String projectId;
  final String tabId;
  final List<AssignItem> data;

  AssignTaskRequest({
    required this.projectId,
    required this.tabId,
    required this.data,
  });

  Map<String, dynamic> toJson({
    required String userId,
    required String compId,
  }) {
    return {
      "user_id": userId,
      "comp_id": compId,
      "project_id": projectId,
      "tab_id": tabId,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class AssignItem {
  final int itemId;
  final String itemName;
  final List<AssignCategory> categories;

  AssignItem({
    required this.itemId,
    required this.itemName,
    required this.categories,
  });

  Map<String, dynamic> toJson() => {
    "item_id": itemId,
    "item_name": itemName,
    "categories": categories.map((e) => e.toJson()).toList(),
  };
}

class AssignCategory {
  final int categoryId;
  final String categoryName;
  final List<AssignTask> tasks;

  AssignCategory({
    required this.categoryId,
    required this.categoryName,
    required this.tasks,
  });

  Map<String, dynamic> toJson() => {
    "category_id": categoryId,
    "category_name": categoryName,
    "tasks": tasks.map((e) => e.toJson()).toList(),
  };
}

class AssignTask {
  final int taskId;
  final String taskName;

  AssignTask({required this.taskId, required this.taskName});

  Map<String, dynamic> toJson() => {"task_id": taskId, "task_name": taskName};
}

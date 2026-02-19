class TemplateResponse {
  final bool status;
  final String message;
  final List<TemplateItem> data;

  TemplateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TemplateResponse.fromJson(Map<String, dynamic> json) {
    return TemplateResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => TemplateItem.fromJson(e))
          .toList(),
    );
  }
}
class TemplateItem {
  final int itemId;
  final String itemName;
  final String status;
  final String statusName;
  final List<TemplateCategory> categories;

  TemplateItem({
    required this.itemId,
    required this.itemName,
    required this.status,
    required this.statusName,
    required this.categories,
  });

  factory TemplateItem.fromJson(Map<String, dynamic> json) {
    return TemplateItem(
      itemId: json['item_id'] ?? 0,
      itemName: json['item_name'] ?? '',
      status: json['status'] ?? '',
      statusName: json['status_name'] ?? '',
      categories: (json['categories'] as List? ?? [])
          .map((e) => TemplateCategory.fromJson(e))
          .toList(),
    );
  }
}
class TemplateCategory {
  final int categoryId;
  final String categoryName;
  final List<TemplateTask> tasks;

  TemplateCategory({
    required this.categoryId,
    required this.categoryName,
    required this.tasks,
  });

  factory TemplateCategory.fromJson(Map<String, dynamic> json) {
    return TemplateCategory(
      categoryId: json['category_id'] ?? 0,
      categoryName: json['category_name'] ?? '',
      tasks: (json['tasks'] as List? ?? [])
          .map((e) => TemplateTask.fromJson(e))
          .toList(),
    );
  }
}
class TemplateTask {
  final int taskId;
  final String taskName;
  final List<TemplateFile> files;

  TemplateTask({
    required this.taskId,
    required this.taskName,
    required this.files,
  });

  factory TemplateTask.fromJson(Map<String, dynamic> json) {
    return TemplateTask(
      taskId: json['task_id'] ?? 0,
      taskName: json['task_name'] ?? '',
      files: (json['files'] as List? ?? [])
          .map((e) => TemplateFile.fromJson(e))
          .toList(),
    );
  }
}
class TemplateFile {
  final String remoteFilePath;

  TemplateFile({required this.remoteFilePath});

  factory TemplateFile.fromJson(Map<String, dynamic> json) {
    return TemplateFile(
      remoteFilePath: json['remote_file_path'] ?? '',
    );
  }
}

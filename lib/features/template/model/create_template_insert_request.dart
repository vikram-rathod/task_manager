class CreateTemplateRequest {
  final int approvalAuthority;
  final String visibleToAccounts;
  final String tabId;
  final TemplateData data;

  CreateTemplateRequest({
    required this.approvalAuthority,
    required this.visibleToAccounts,
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
      "approval_authority": approvalAuthority,
      "visible_to_accounts": visibleToAccounts,
      "tab_id": tabId,
      "data": data.toJson(),
    };
  }
}

class TemplateData {
  final int itemId;
  final String itemName;
  final List<CategoryInsert> categories;

  TemplateData({
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

class CategoryInsert {
  final int categoryId;
  final String categoryName;
  final List<TaskInsert> tasks;

  CategoryInsert({
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

class TaskInsert {
  final int taskId;
  final String taskName;
  final List<FileInsert> files;

  TaskInsert({
    required this.taskId,
    required this.taskName,
    required this.files,
  });

  Map<String, dynamic> toJson() => {
    "task_id": taskId,
    "task_name": taskName,
    "files": files.map((e) => e.toJson()).toList(),
  };
}

class FileInsert {
  final String fileName;
  final String fileData; // base64

  FileInsert({
    required this.fileName,
    required this.fileData,
  });

  Map<String, dynamic> toJson() => {
    "file_name": fileName,
    "file_data": fileData,
  };
}

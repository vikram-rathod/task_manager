class AccountModel {
  final int id;
  final String name;

  AccountModel({
    required this.id,
    required this.name,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json["account_of_use_type_id"],
      name: json["account_of_use"],
    );
  }
}

class CategoryRequest {
  String categoryName;
  List<TaskRequest> tasks;

  CategoryRequest({
    required this.categoryName,
    required this.tasks,
  });

  Map<String, dynamic> toJson() {
    return {
      "category_name": categoryName,
      "tasks": tasks.map((e) => e.toJson()).toList(),
    };
  }
}

class TaskRequest {
  String taskName;

  TaskRequest({
    required this.taskName,
  });

  Map<String, dynamic> toJson() {
    return {
      "task_name": taskName,
    };
  }
}


class CategoryModel {
  String name = "";
  List<TaskModel> tasks = [];
}

class TaskModel {
  String name = "";
}
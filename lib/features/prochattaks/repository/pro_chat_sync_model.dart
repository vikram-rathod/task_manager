class ProChatTaskSyncModel {
  final bool isNewTasks;

  ProChatTaskSyncModel({
    required this.isNewTasks,
  });

  factory ProChatTaskSyncModel.fromJson(Map<String, dynamic> json) {
    return ProChatTaskSyncModel(
      isNewTasks: json['is_new_tasks'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_new_tasks': isNewTasks,
    };
  }
}

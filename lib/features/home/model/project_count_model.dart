class ProjectCountModel {
  final String projectId;
  final String projectName;
  final int completedTaskCount;
  final int inProgressTaskCount;
  final int totalTaskCount;

  ProjectCountModel({
    required this.projectId,
    required this.projectName,
    required this.completedTaskCount,
    required this.inProgressTaskCount,
    required this.totalTaskCount,
  });

  factory ProjectCountModel.fromJson(Map<String, dynamic> json) {
    return ProjectCountModel(
      projectId: json['project_id']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      completedTaskCount:
      int.tryParse(json['completed_task_count']?.toString() ?? '0') ?? 0,
      inProgressTaskCount:
      int.tryParse(json['in_progress_task_count']?.toString() ?? '0') ?? 0,
      totalTaskCount:
      int.tryParse(json['total_tasks_count']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'completed_task_count': completedTaskCount,
      'in_progress_task_count': inProgressTaskCount,
      'total_tasks_count': totalTaskCount,
    };
  }
}

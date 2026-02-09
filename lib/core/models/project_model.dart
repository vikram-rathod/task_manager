class ProjectModel {
  final int projectId;
  final String projectName;

  ProjectModel({required this.projectId, required this.projectName});

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: int.parse(json['project_id'].toString()),
      projectName: json['project_name']?.toString() ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {'project_id': projectId, 'project_name': projectName};
  }
}

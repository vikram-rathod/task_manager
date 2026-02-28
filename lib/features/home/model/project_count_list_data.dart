import 'package:task_manager/features/home/model/project_count_model.dart';

class ProjectListData {

  final List<ProjectCountModel> list;
  final int total;

  ProjectListData({
    required this.list,
    required this.total,
  });

  factory ProjectListData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    final rawList = json['list'] as List? ?? [];

    return ProjectListData(
      list: rawList
          .map((e) => ProjectCountModel.fromJson(e))
          .toList(),
      total: parseInt(json['total']),
    );
  }
}
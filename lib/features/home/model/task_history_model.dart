class TaskHistoryModel {
  final String statement;
  final String createdDate;

  TaskHistoryModel({
    required this.statement,
    required this.createdDate,
  });

  factory TaskHistoryModel.fromJson(Map<String, dynamic> json) {
    return TaskHistoryModel(
      statement: json['statement'] as String,
      createdDate: json['cdate'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statement': statement,
      'cdate': createdDate,
    };
  }
}

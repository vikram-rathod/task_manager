class TaskHistoryModel {
  final String changedBy;
  final int changedByUserId;
  final String userProfileUrl;
  final String createdDate;
  final String change;
  final dynamic oldValue;
  final dynamic newValue;
  final String? oldName;
  final String? newName;
  final String statement;
  TaskHistoryModel({
    required this.statement,
    required this.createdDate,
    required this.changedBy,
    required this.changedByUserId,
    required this.userProfileUrl,
    required this.change,
    required this.oldValue,
    required this.newValue,
    this.oldName,
    this.newName,
  });

  factory TaskHistoryModel.fromJson(Map<String, dynamic> json) {
    return TaskHistoryModel(
      statement: json['statement'] as String,
      createdDate: json['cdate'] as String,
      changedBy: json['changed_by'] ?? '',
      changedByUserId: json['changed_by_user_id'] ?? 0,
      userProfileUrl: json['user_profile_url'] ?? '',
      change: json['change'] ?? '',
      oldValue: json['old_value'],
      newValue: json['new_value'],
      oldName: json['old_name'],
      newName: json['new_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statement': statement,
      'cdate': createdDate,
    };
  }
}

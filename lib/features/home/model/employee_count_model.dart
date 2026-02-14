class EmployeeModel {
  final int candidateRefId;
  final int userId;
  final String userName;
  final int totalTaskCount;
  final int completedTaskCount;
  final int inProgressTaskCount;
  final String userProfileUrl;
  final int pendingAtMe;
  final int pendingAtOther;
  final int totalPendingTask;

  EmployeeModel({
    required this.candidateRefId,
    required this.userId,
    required this.userName,
    required this.totalTaskCount,
    required this.completedTaskCount,
    required this.inProgressTaskCount,
    required this.userProfileUrl,
    required this.pendingAtMe,
    required this.pendingAtOther,
    required this.totalPendingTask,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      candidateRefId: json['ref_candidate_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      totalTaskCount: json['total_tasks_count'] ?? 0,
      completedTaskCount: json['completed_task_count'] ?? 0,
      inProgressTaskCount: json['in_progress_task_count'] ?? 0,
      userProfileUrl: json['user_profile_url'] ?? '',
      pendingAtMe: json['pending_at_me'] ?? 0,
      pendingAtOther: json['pending_at_other'] ?? 0,
      totalPendingTask: json['total_pending_task'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ref_candidate_id': candidateRefId,
      'user_id': userId,
      'user_name': userName,
      'total_tasks_count': totalTaskCount,
      'completed_task_count': completedTaskCount,
      'in_progress_task_count': inProgressTaskCount,
      'user_profile_url': userProfileUrl,
      'pending_at_me': pendingAtMe,
      'pending_at_other': pendingAtOther,
      'total_pending_task': totalPendingTask,
    };
  }
  @override
  String toString() {
    return 'EmployeeModel(candidateRefId: $candidateRefId, userId: $userId, userName: $userName, totalTaskCount: $totalTaskCount, completedTaskCount: $completedTaskCount, inProgressTaskCount: $inProgressTaskCount, userProfileUrl: $userProfileUrl, pendingAtMe: $pendingAtMe, pendingAtOther: $pendingAtOther, totalPendingTask: $totalPendingTask)';
  }
}

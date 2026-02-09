import '../../auth/models/user_model.dart';

class TMTasksModel {
  final String projectId;
  final String projectName;
  final int taskId;
  final String taskDescription;
  final String taskPriority;
  final int userId;
  final String userName;
  final int checkerId;
  final String checkerName;
  final int makerId;
  final String makerName;
  final int pcEngrId;
  final String pcEngrName;
  final String taskStatus;
  final List<UserModel> teamMembers;

  // Detailed fields
  final String? taskRegisteredDate;
  final String? taskStartDate;
  final String? taskEndDate;
  final String? targetedDate;

  // Prochat related fields
  final String? prochatTaskId;
  final String? createdByName;
  final String? dueDate;
  final String? priority;
  final String? prochatRemark;
  final String? createdAt;
  final String? updatedAt;
  final String? taskType;

  TMTasksModel({
    this.projectId = '',
    this.projectName = '',
    this.taskId = 0,
    this.taskDescription = '',
    required this.taskPriority,
    this.userId = 0,
    this.userName = '',
    this.checkerId = 0,
    this.checkerName = '',
    this.makerId = 0,
    this.makerName = '',
    this.pcEngrId = 0,
    this.pcEngrName = '',
    this.taskStatus = '',
    this.teamMembers = const [],
    this.taskRegisteredDate,
    this.taskStartDate,
    this.taskEndDate,
    this.targetedDate,
    this.prochatTaskId,
    this.createdByName,
    this.dueDate,
    this.priority,
    this.prochatRemark,
    this.createdAt,
    this.updatedAt,
    this.taskType,
  });

  factory TMTasksModel.fromJson(Map<String, dynamic> json) {
    return TMTasksModel(
      projectId: json['project_id']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      taskId: json['task_id'] is int
          ? json['task_id']
          : int.tryParse(json['task_id']?.toString() ?? '') ?? 0,
      taskDescription: json['task_description']?.toString() ?? '',
      taskPriority: json['task_priority']?.toString() ?? '',
      userId: json['user_id'] ?? 0,
      userName: json['user_name']?.toString() ?? '',
      checkerId: json['checker_id'] ?? 0,
      checkerName: json['checker_name']?.toString() ?? '',
      makerId: json['maker_id'] ?? 0,
      makerName: json['maker_name']?.toString() ?? '',
      pcEngrId: json['pc_engr_id'] ?? 0,
      pcEngrName: json['pc_engr_name']?.toString() ?? '',
      taskStatus: json['task_status']?.toString() ?? '',
      teamMembers: (json['team_members'] as List<dynamic>?)
          ?.map((e) => UserModel.fromJson(e))
          .toList() ??
          [],
      taskRegisteredDate: json['task_registered_date']?.toString(),
      taskStartDate: json['task_start_date']?.toString(),
      taskEndDate: json['task_end_date']?.toString(),
      targetedDate: json['targeted_date']?.toString(),
      prochatTaskId: json['prochat_task_id']?.toString(),
      createdByName: json['created_by_name']?.toString(),
      dueDate: json['due_date']?.toString(),
      priority: json['priority']?.toString(),
      prochatRemark: json['prochat_remark']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      taskType: json['task_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'project_name': projectName,
      'task_id': taskId,
      'task_description': taskDescription,
      'task_priority': taskPriority,
      'user_id': userId,
      'user_name': userName,
      'checker_id': checkerId,
      'checker_name': checkerName,
      'maker_id': makerId,
      'maker_name': makerName,
      'pc_engr_id': pcEngrId,
      'pc_engr_name': pcEngrName,
      'task_status': taskStatus,
      'team_members': teamMembers.map((e) => e.toJson()).toList(),
      'task_registered_date': taskRegisteredDate,
      'task_start_date': taskStartDate,
      'task_end_date': taskEndDate,
      'targeted_date': targetedDate,
      'prochat_task_id': prochatTaskId,
      'created_by_name': createdByName,
      'due_date': dueDate,
      'priority': priority,
      'prochat_remark': prochatRemark,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'task_type': taskType,
    };
  }
}

import 'package:equatable/equatable.dart';

class BcstepTaskModel extends Equatable {
  // ── Common ─────────────────────────────────────────────────────────────────
  final String workId;
  final String taskDesc;
  final String makerName;
  final String checkerName;
  final String projectName;
  final String status;
  final String pcName;
  final String username;
  final String notificationId;
  final String createdAt;
  final String? remark;

  // ── new_tasks specific ────────────────────────────────────────────────────
  final String? seenStatusUrl;

  // ── status_change specific ────────────────────────────────────────────────
  final String? prevStatusName;
  final String? newStatusName;

  // ── mentioned_message specific ────────────────────────────────────────────
  final String? chatId;
  final String? message;
  final String? messageDateTime;

  const BcstepTaskModel({
    this.workId = '',
    required this.taskDesc,
    this.makerName = '',
    this.checkerName = '',
    this.projectName = '',
    this.status = '',
    this.pcName = '',
    this.username = '',
    this.notificationId = '',
    required this.createdAt,
    this.remark,
    this.seenStatusUrl,
    this.prevStatusName,
    this.newStatusName,
    this.chatId,
    this.message,
    this.messageDateTime,
  });

  factory BcstepTaskModel.fromJson(Map<String, dynamic> json) {
    return BcstepTaskModel(
      workId: json['work_id']?.toString() ?? '',
      taskDesc: json['task_description']?.toString() ?? '',
      makerName: json['maker_name']?.toString() ?? '',
      checkerName: json['checker_name']?.toString() ?? '',
      projectName: json['project_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      pcName: json['pc_name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      notificationId: json['notification_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      remark: json['remark']?.toString(),
      seenStatusUrl: json['seen_status_url']?.toString(),
      prevStatusName: json['prev_status_name']?.toString(),
      newStatusName: json['new_status_name']?.toString(),
      chatId: json['chat_id']?.toString(),
      message: json['message']?.toString(),
      messageDateTime: json['message_datetime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'work_id': workId,
    'task_description': taskDesc,
    'maker_name': makerName,
    'checker_name': checkerName,
    'project_name': projectName,
    'status': status,
    'pc_name': pcName,
    'username': username,
    'notification_id': notificationId,
    'created_at': createdAt,
    'remark': remark,
    'seen_status_url': seenStatusUrl,
    'prev_status_name': prevStatusName,
    'new_status_name': newStatusName,
    'chat_id': chatId,
    'message': message,
    'message_datetime': messageDateTime,
  };

  String readKey(String typeName) {
    final keyId =
    workId.isNotEmpty ? workId : (chatId?.isNotEmpty == true ? chatId : '');
    return '${typeName}_$keyId';
  }

  @override
  List<Object?> get props => [
    workId,
    taskDesc,
    makerName,
    checkerName,
    projectName,
    status,
    pcName,
    username,
    notificationId,
    createdAt,
    remark,
    seenStatusUrl,
    prevStatusName,
    newStatusName,
    chatId,
    message,
    messageDateTime,
  ];
}
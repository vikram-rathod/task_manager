import 'package:equatable/equatable.dart';

class DashboardCountModel extends Equatable {
  final int notificationCount;
  final int proChatCount;
  final int todayDueCount;
  final int overDueCount;
  final int todayDuePendingAtMe;
  final int todayDuePendingAtOthers;
  final int overduePendingAtMe;
  final int overduePendingAtOther;

  const DashboardCountModel({
    this.notificationCount = 0,
    this.proChatCount = 0,
    this.todayDueCount = 0,
    this.overDueCount = 0,
    this.todayDuePendingAtMe = 0,
    this.todayDuePendingAtOthers = 0,
    this.overduePendingAtMe = 0,
    this.overduePendingAtOther = 0,
  });

  factory DashboardCountModel.fromJson(Map<String, dynamic> json) {
    return DashboardCountModel(
      notificationCount: json['notification_count'] ?? 0,
      proChatCount: json['procom_chat_count'] ?? 0,
      todayDueCount: json['today_due_count'] ?? 0,
      overDueCount: json['over_due_count'] ?? 0,
      todayDuePendingAtMe: json['today_due_pending_at_me'] ?? 0,
      todayDuePendingAtOthers: json['today_due_pending_at_other'] ?? 0,
      overduePendingAtMe: json['overdue_pending_at_me'] ?? 0,
      overduePendingAtOther: json['overdue_pending_at_other'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_count': notificationCount,
      'procom_chat_count': proChatCount,
      'today_due_count': todayDueCount,
      'over_due_count': overDueCount,
      'today_due_pending_at_me': todayDuePendingAtMe,
      'today_due_pending_at_other': todayDuePendingAtOthers,
      'overdue_pending_at_me': overduePendingAtMe,
      'overdue_pending_at_other': overduePendingAtOther,
    };
  }

  @override
  List<Object?> get props => [
    notificationCount,
    proChatCount,
    todayDueCount,
    overDueCount,
    todayDuePendingAtMe,
    todayDuePendingAtOthers,
    overduePendingAtMe,
    overduePendingAtOther,
  ];
}

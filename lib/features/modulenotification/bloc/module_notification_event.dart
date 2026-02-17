part of 'module_notification_bloc.dart';

abstract class ModuleNotificationEvent extends Equatable {
  const ModuleNotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationFetched extends ModuleNotificationEvent {
  const NotificationFetched();
}

class NotificationRefreshed extends ModuleNotificationEvent {
  const NotificationRefreshed();
}

/// Dispatched for all three action buttons.
/// [taskStatus] is one of: 'Completed' | 'Cancelled' | 'Hold'
class NotificationApprovalSubmitted extends ModuleNotificationEvent {
  final String workId;
  final String notificationId;
  final String taskStatus;

  const NotificationApprovalSubmitted({
    required this.workId,
    required this.notificationId,
    required this.taskStatus,
  });

  @override
  List<Object?> get props => [workId, notificationId, taskStatus];
}

class NotificationErrorCleared extends ModuleNotificationEvent {
  const NotificationErrorCleared();
}

class NotificationMarkedAsRead extends ModuleNotificationEvent {
  final String notificationId;
  final String seenUrl;

  const NotificationMarkedAsRead({
    required this.notificationId,
    required this.seenUrl,
  });

  @override
  List<Object?> get props => [notificationId, seenUrl];
}


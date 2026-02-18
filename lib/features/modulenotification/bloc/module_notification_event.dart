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

class NotificationErrorCleared extends ModuleNotificationEvent {
  const NotificationErrorCleared();
}

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

class NotificationMarkedAsRead extends ModuleNotificationEvent {
  /// Unique key for this item: '{groupType}_{workId}' or '{groupType}_{chatId}'
  /// Built from BcstepTaskModel.readKey(groupType).
  final String readKey;

  /// The notification type string (e.g. 'status_change', 'mentioned_message').
  /// Used to scope removal to the correct group only.
  final String groupType;

  /// The API URL to call to mark this item as read.
  final String seenUrl;

  const NotificationMarkedAsRead({
    required this.readKey,
    required this.groupType,
    required this.seenUrl,
  });

  @override
  List<Object?> get props => [readKey, groupType, seenUrl];
}
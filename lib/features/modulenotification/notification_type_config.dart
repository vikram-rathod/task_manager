import 'package:flutter/material.dart';

import 'notification_design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Enum
// ─────────────────────────────────────────────────────────────────────────────

enum TaskNotificationType {
  actionNotification('action_notification'),
  newTasks('new_tasks'),
  checkerActionPendingTasks('checker_action_pending_tasks'),
  inProgress('in_progress'),
  statusChange('status_change'),
  checkerChange('checker_change'),
  mentionedMessage('mentioned_message');

  final String value;
  const TaskNotificationType(this.value);

  static TaskNotificationType? from(String? value) {
    if (value == null) return null;
    for (final t in TaskNotificationType.values) {
      if (t.value == value) return t;
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Type config model
// ─────────────────────────────────────────────────────────────────────────────

class NotificationTypeConfig {
  final String label;
  final IconData icon;
  final Color dot;

  const NotificationTypeConfig({
    required this.label,
    required this.icon,
    required this.dot,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Config map
// ─────────────────────────────────────────────────────────────────────────────

const Map<TaskNotificationType, NotificationTypeConfig> kNotificationTypeConfig = {
  TaskNotificationType.actionNotification: NotificationTypeConfig(
    label: 'Status Change Requests',
    icon: Icons.priority_high_rounded,
    dot: NotificationDt.dotAction,
  ),
  TaskNotificationType.newTasks: NotificationTypeConfig(
    label: 'Pending Action · Maker',
    icon: Icons.task_alt_rounded,
    dot: NotificationDt.dotNew,
  ),
  TaskNotificationType.checkerActionPendingTasks: NotificationTypeConfig(
    label: 'Pending Action · Checker',
    icon: Icons.pending_actions_rounded,
    dot: NotificationDt.dotCheckerPending,
  ),
  TaskNotificationType.inProgress: NotificationTypeConfig(
    label: 'In Progress',
    icon: Icons.timelapse_rounded,
    dot: NotificationDt.dotInProgress,
  ),
  TaskNotificationType.statusChange: NotificationTypeConfig(
    label: 'Status Changed',
    icon: Icons.swap_horiz_rounded,
    dot: NotificationDt.dotStatusChange,
  ),
  TaskNotificationType.checkerChange: NotificationTypeConfig(
    label: 'Checker Changed',
    icon: Icons.manage_accounts_rounded,
    dot: NotificationDt.dotCheckerChange,
  ),
  TaskNotificationType.mentionedMessage: NotificationTypeConfig(
    label: 'New Task Chats',
    icon: Icons.alternate_email_rounded,
    dot: NotificationDt.dotMention,
  ),
};

const NotificationTypeConfig kDefaultTypeConfig = NotificationTypeConfig(
  label: 'Notification',
  icon: Icons.notifications_outlined,
  dot: NotificationDt.dotDefault,
);

// ─────────────────────────────────────────────────────────────────────────────
// Lookup helper
// ─────────────────────────────────────────────────────────────────────────────

NotificationTypeConfig typeConfigFor(TaskNotificationType? type) =>
    (type != null ? kNotificationTypeConfig[type] : null) ?? kDefaultTypeConfig;
import 'package:flutter/material.dart';

import '../../../core/models/taskchat/bcstep_task_model.dart';
import '../notification_design_tokens.dart';
import '../notification_type_config.dart';
import 'notification_primitives.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dispatcher — selects the correct body based on type
// ─────────────────────────────────────────────────────────────────────────────

class NotificationCardBody extends StatelessWidget {
  final BcstepTaskModel task;
  final TaskNotificationType? type;
  final NotificationTypeConfig tc;

  const NotificationCardBody({
    super.key,
    required this.task,
    required this.type,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      TaskNotificationType.actionNotification => NotificationActionBody(
        task: task,
        tc: tc,
      ),
      TaskNotificationType.newTasks => NotificationNewTaskBody(
        task: task,
        tc: tc,
      ),
      TaskNotificationType.checkerActionPendingTasks =>
        NotificationCheckerPendingBody(task: task, tc: tc),
      TaskNotificationType.inProgress => NotificationInProgressBody(
        task: task,
        tc: tc,
      ),
      TaskNotificationType.statusChange => NotificationStatusChangeBody(
        task: task,
        tc: tc,
      ),
      TaskNotificationType.checkerChange => NotificationCheckerChangeBody(
        task: task,
        tc: tc,
      ),
      TaskNotificationType.mentionedMessage => NotificationMentionBody(
        task: task,
        tc: tc,
      ),
      null => NotificationDefaultMetaRow(task: task),
    };
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// action_notification
// ─────────────────────────────────────────────────────────────────────────────

class NotificationActionBody extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;

  const NotificationActionBody({
    super.key,
    required this.task,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.remark?.isNotEmpty ?? false) ...[
          NotificationRemarkBox(remark: task.remark!),
          const SizedBox(height: NotificationDt.sp8),
        ],
        NotificationDefaultMetaRow(task: task),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// new_tasks
// ─────────────────────────────────────────────────────────────────────────────

class NotificationNewTaskBody extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;

  const NotificationNewTaskBody({
    super.key,
    required this.task,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.remark?.isNotEmpty ?? false) ...[
          NotificationRemarkBox(remark: task.remark!),
          const SizedBox(height: NotificationDt.sp8),
        ],
        NotificationMetaGrid(
          entries: [
            if (task.projectName.isNotEmpty)
              NotificationMetaEntry('Project', task.projectName),
            if (task.makerName.isNotEmpty)
              NotificationMetaEntry('Maker', task.makerName),
            if (task.checkerName.isNotEmpty)
              NotificationMetaEntry('Checker', task.checkerName),
            if (task.pcName.isNotEmpty)
              NotificationMetaEntry('PC', task.pcName),
            if (task.username.isNotEmpty)
              NotificationMetaEntry('User', task.username),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// checker_action_pending_tasks
// ─────────────────────────────────────────────────────────────────────────────

class NotificationCheckerPendingBody extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;

  const NotificationCheckerPendingBody({
    super.key,
    required this.task,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.hourglass_top_rounded, size: 13, color: tc.dot),
            const SizedBox(width: NotificationDt.sp4),
            Text(
              'Awaiting your checker action',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: tc.dot,
              ),
            ),
          ],
        ),
        const SizedBox(height: NotificationDt.sp8),
        NotificationMetaGrid(
          entries: [
            if (task.projectName.isNotEmpty)
              NotificationMetaEntry('Project', task.projectName),
            if (task.username.isNotEmpty)
              NotificationMetaEntry('User', task.username),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// in_progress
// ─────────────────────────────────────────────────────────────────────────────

class NotificationInProgressBody extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;

  const NotificationInProgressBody({
    super.key,
    required this.task,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(NotificationDt.r4),
          child: LinearProgressIndicator(
            value: null,
            minHeight: 2,
            backgroundColor: ntfBorder(context),
            valueColor: AlwaysStoppedAnimation<Color>(tc.dot),
          ),
        ),
        const SizedBox(height: NotificationDt.sp8),
        NotificationMetaGrid(
          entries: [
            if (task.projectName.isNotEmpty)
              NotificationMetaEntry('Project', task.projectName),
            if (task.status.isNotEmpty)
              NotificationMetaEntry('Status', task.status),
            if (task.makerName.isNotEmpty)
              NotificationMetaEntry('Maker', task.makerName),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// status_change
// ─────────────────────────────────────────────────────────────────────────────

class NotificationStatusChangeBody extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;

  const NotificationStatusChangeBody({
    super.key,
    required this.task,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrev = task.prevStatusName?.isNotEmpty ?? false;
    final hasNew = task.newStatusName?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasPrev || hasNew)
          Wrap(
            spacing: NotificationDt.sp8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hasPrev)
                NotificationPillLabel(task.prevStatusName!, ntfInk2(context)),

              if (hasPrev && hasNew)
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: ntfInk2(context),
                ),

              if (hasNew) NotificationPillLabel(task.newStatusName!, tc.dot),
            ],
          ),
        if (task.projectName.isNotEmpty) ...[
          const SizedBox(height: NotificationDt.sp8),
          NotificationMetaGrid(
            entries: [NotificationMetaEntry('Project', task.projectName)],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// checker_change
// ─────────────────────────────────────────────────────────────────────────────

class NotificationCheckerChangeBody extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;

  const NotificationCheckerChangeBody({
    super.key,
    required this.task,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrev = task.username.isNotEmpty;
    final hasNew = task.checkerName.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (hasPrev) NotificationNameTag(task.username, ntfInk2(context)),
            if (hasPrev && hasNew) ...[
              const SizedBox(width: NotificationDt.sp8),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: ntfInk2(context),
              ),
              const SizedBox(width: NotificationDt.sp8),
            ],
            if (hasNew) NotificationNameTag(task.checkerName, tc.dot),
          ],
        ),
        if (task.projectName.isNotEmpty) ...[
          const SizedBox(height: NotificationDt.sp8),
          NotificationMetaGrid(
            entries: [NotificationMetaEntry('Project', task.projectName)],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// mentioned_message
// ─────────────────────────────────────────────────────────────────────────────

class NotificationMentionBody extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;

  const NotificationMentionBody({
    super.key,
    required this.task,
    required this.tc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.message?.isNotEmpty ?? false)
          NotificationQuoteBlock(
            message: task.message!,
            timestamp: task.messageDateTime,
            accentColor: tc.dot,
          ),
        const SizedBox(height: NotificationDt.sp8),
        NotificationMetaGrid(
          entries: [
            if (task.projectName.isNotEmpty)
              NotificationMetaEntry('Project', task.projectName),
            if (task.chatId?.isNotEmpty ?? false)
              NotificationMetaEntry('Chat', '#${task.chatId}'),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Default — generic meta row (fallback)
// ─────────────────────────────────────────────────────────────────────────────

class NotificationDefaultMetaRow extends StatelessWidget {
  final BcstepTaskModel task;

  const NotificationDefaultMetaRow({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return NotificationMetaGrid(
      entries: [
        if (task.projectName.isNotEmpty)
          NotificationMetaEntry('Project', task.projectName),
        if (task.makerName.isNotEmpty)
          NotificationMetaEntry('Maker', task.makerName),
        if (task.checkerName.isNotEmpty)
          NotificationMetaEntry('Checker', task.checkerName),
        if (task.pcName.isNotEmpty) NotificationMetaEntry('PC', task.pcName),
        if (task.status.isNotEmpty)
          NotificationMetaEntry('Status', task.status),
      ],
    );
  }
}

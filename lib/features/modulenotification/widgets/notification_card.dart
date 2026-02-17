import 'package:flutter/material.dart';

import '../../../core/models/taskchat/bcstep_task_model.dart';
import '../notification_design_tokens.dart';
import '../notification_type_config.dart';
import 'notification_approval_buttons.dart';
import 'notification_card_bodies.dart';
import 'notification_mark_read_button.dart';
import 'notification_primitives.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class NotificationCard extends StatelessWidget {
  final BcstepTaskModel task;
  final TaskNotificationType? type;
  final NotificationTypeConfig tc;
  final String? actionStatus;
  final bool isSubmitting;

  const NotificationCard({
    super.key,
    required this.task,
    required this.type,
    required this.tc,
    required this.actionStatus,
    required this.isSubmitting,
  });

  /// actionNotification uses Approve/Hold/Cancel — it never has a seenUrl.
  /// Every other type shows "Mark as read" when seenUrl is present.
  bool get _showMarkRead =>
      type != TaskNotificationType.actionNotification &&
          (task.seenStatusUrl?.isNotEmpty ?? false);

  /// Left-edge strip color — reflects resolved state or type dot.
  Color _edgeColor() {
    return switch (actionStatus) {
      'Completed'  => NotificationDt.positive,
      'Cancelled'  => NotificationDt.negative,
      'Hold'       => const Color(0xFFD97706),
      _            => tc.dot,
    };
  }

  @override
  Widget build(BuildContext context) {
    final edgeColor = _edgeColor();

    return Container(
      decoration: BoxDecoration(
        color: ntfSurface(context),
        borderRadius: BorderRadius.circular(NotificationDt.r12),
        border: Border.all(color: ntfBorder(context)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent strip
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: edgeColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(NotificationDt.r12),
                  bottomLeft: Radius.circular(NotificationDt.r12),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(NotificationDt.sp16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NotificationCardHeader(
                      task: task,
                      tc: tc,
                      actionStatus: actionStatus,
                    ),
                    const SizedBox(height: NotificationDt.sp12),
                    NotificationCardBody(task: task, type: type, tc: tc),

                    // ── Approve / Hold / Cancelled row (actionNotification) ─
                    if (type == TaskNotificationType.actionNotification &&
                        actionStatus == null) ...[
                      const SizedBox(height: NotificationDt.sp16),
                      Container(height: 1, color: ntfBorder(context)),
                      const SizedBox(height: NotificationDt.sp12),
                      NotificationApprovalButtons(
                        task: task,
                        isSubmitting: isSubmitting,
                      ),
                    ],

                    // ── Mark as read (all other types with seenUrl) ─────────
                    if (_showMarkRead) ...[
                      const SizedBox(height: NotificationDt.sp12),
                      Container(height: 1, color: ntfBorder(context)),
                      const SizedBox(height: NotificationDt.sp12),
                      NotificationMarkReadButton(
                        notificationId: task.notificationId,
                        seenUrl: task.seenStatusUrl!,
                      )
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card Header
// ─────────────────────────────────────────────────────────────────────────────

class NotificationCardHeader extends StatelessWidget {
  final BcstepTaskModel task;
  final NotificationTypeConfig tc;
  final String? actionStatus;

  const NotificationCardHeader({
    super.key,
    required this.task,
    required this.tc,
    required this.actionStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // icon · type label ········ timestamp · [badge]
        Row(
          children: [
            Icon(tc.icon, size: 13, color: ntfInk2(context)),
            const SizedBox(width: 5),
            Text(
              tc.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ntfInk2(context),
              ),
            ),
            const Spacer(),
            if (task.createdAt.isNotEmpty)
              Text(
                task.createdAt,
                style: TextStyle(
                  fontSize: 11,
                  color: ntfInk2(context).withOpacity(0.55),
                ),
              ),
            if (actionStatus != null) ...[
              const SizedBox(width: NotificationDt.sp8),
              NotificationStatusBadge(status: actionStatus!),
            ],
          ],
        ),
        const SizedBox(height: NotificationDt.sp8),
        Text(
          task.taskDesc,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ntfInk(context),
            height: 1.35,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
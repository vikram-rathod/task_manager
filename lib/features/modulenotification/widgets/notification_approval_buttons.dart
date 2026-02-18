import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/taskchat/bcstep_task_model.dart';
import '../bloc/module_notification_bloc.dart';
import '../notification_design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Three-action button row  (Complete · Hold · Cancelled)
// Each button independently tracks its own loading state via notificationId_taskStatus
// ─────────────────────────────────────────────────────────────────────────────

class NotificationApprovalButtons extends StatelessWidget {
  final BcstepTaskModel task;

  const NotificationApprovalButtons({
    super.key,
    required this.task,
  });

  void _dispatch(BuildContext context, String status) {
    context.read<ModuleNotificationBloc>().add(
      NotificationApprovalSubmitted(
        workId: task.workId,
        notificationId: task.notificationId,
        taskStatus: status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModuleNotificationBloc, ModuleNotificationState>(
      // Rebuild only when the submitting state for THIS task changes
      buildWhen: (p, c) =>
      p.submittingId != c.submittingId &&
          (p.submittingId?.startsWith(task.notificationId) == true ||
              c.submittingId?.startsWith(task.notificationId) == true),
      builder: (context, state) {
        // Each status maps to its own key — only the tapped button is loading
        final isCompletingSubmitting = state.isSubmitting(task.notificationId, '1');
        final isHoldSubmitting = state.isSubmitting(task.notificationId, '3');
        final isCancelledSubmitting = state.isSubmitting(task.notificationId, '2');

        // Disable all buttons while any one of them is in-flight
        final anySubmitting =
            isCompletingSubmitting || isHoldSubmitting || isCancelledSubmitting;

        return Row(
          children: [
            // ── Complete ──────────────────────────────────────────────────
            Expanded(
              child: _ActionButton(
                label: 'Complete',
                icon: Icons.check_rounded,
                backgroundColor: NotificationDt.positive,
                foregroundColor: Colors.white,
                isSubmitting: isCompletingSubmitting,
                isDisabled: anySubmitting,
                isFilled: true,
                onTap: () => _dispatch(context, '1'),
              ),
            ),
            const SizedBox(width: NotificationDt.sp8),

            // ── Hold ──────────────────────────────────────────────────────
            Expanded(
              child: _ActionButton(
                label: 'Hold',
                icon: Icons.pause_rounded,
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                isSubmitting: isHoldSubmitting,
                isDisabled: anySubmitting,
                isFilled: true,
                onTap: () => _dispatch(context, '3'),
              ),
            ),
            const SizedBox(width: NotificationDt.sp8),

            // ── Cancelled ─────────────────────────────────────────────────
            Expanded(
              child: _ActionButton(
                label: 'Cancelled',
                icon: Icons.close_rounded,
                backgroundColor: Colors.transparent,
                foregroundColor: NotificationDt.negative,
                borderColor: NotificationDt.negative,
                isSubmitting: isCancelledSubmitting,
                isDisabled: anySubmitting,
                isFilled: false,
                onTap: () => _dispatch(context, '2'),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable single action button
// isSubmitting  → shows spinner on THIS button only
// isDisabled    → disables all buttons while any one is in-flight
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isSubmitting;
  final bool isDisabled;
  final bool isFilled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isSubmitting,
    required this.isDisabled,
    required this.isFilled,
    required this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(NotificationDt.r8),
    );

    final child = isSubmitting
        ? SizedBox(
      width: 13,
      height: 13,
      child: CircularProgressIndicator(
        strokeWidth: 1.5,
        color: foregroundColor,
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: foregroundColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ),
      ],
    );

    if (isFilled) {
      return SizedBox(
        height: 38,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            shape: shape,
          ),
          onPressed: isDisabled ? null : onTap,
          child: child,
        ),
      );
    }

    return SizedBox(
      height: 38,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          side: BorderSide(color: borderColor ?? foregroundColor),
          shape: shape,
        ),
        onPressed: isDisabled ? null : onTap,
        child: child,
      ),
    );
  }
}
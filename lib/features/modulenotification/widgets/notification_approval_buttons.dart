import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/taskchat/bcstep_task_model.dart';
import '../bloc/module_notification_bloc.dart';
import '../notification_design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Three-action button row  (Complete · Hold · Cancelled)
// ─────────────────────────────────────────────────────────────────────────────

class NotificationApprovalButtons extends StatelessWidget {
  final BcstepTaskModel task;
  final bool isSubmitting;

  const NotificationApprovalButtons({
    super.key,
    required this.task,
    required this.isSubmitting,
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
    return Row(
      children: [
        // ── Complete ────────────────────────────────────────────────────────
        Expanded(
          child: _ActionButton(
            label: 'Complete',
            icon: Icons.check_rounded,
            backgroundColor: NotificationDt.positive,
            foregroundColor: Colors.white,
            isSubmitting: isSubmitting,
            isFilled: true,
            onTap: () => _dispatch(context, '1'),
          ),
        ),
        const SizedBox(width: NotificationDt.sp8),

        // ── Hold ────────────────────────────────────────────────────────────
        Expanded(
          child: _ActionButton(
            label: 'Hold',
            icon: Icons.pause_rounded,
            backgroundColor: const Color(0xFFD97706), // amber
            foregroundColor: Colors.white,
            isSubmitting: isSubmitting,
            isFilled: true,
            onTap: () => _dispatch(context, '3'),
          ),
        ),
        const SizedBox(width: NotificationDt.sp8),

        // ── Cancelled ───────────────────────────────────────────────────────
        Expanded(
          child: _ActionButton(
            label: 'Cancelled',
            icon: Icons.close_rounded,
            backgroundColor: Colors.transparent,
            foregroundColor: NotificationDt.negative,
            borderColor: NotificationDt.negative,
            isSubmitting: isSubmitting,
            isFilled: false,
            onTap: () => _dispatch(context, '2'),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable single action button
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final bool isSubmitting;
  final bool isFilled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.isSubmitting,
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
          onPressed: isSubmitting ? null : onTap,
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
        onPressed: isSubmitting ? null : onTap,
        child: child,
      ),
    );
  }
}
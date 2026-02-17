import 'package:flutter/material.dart';

import '../notification_design_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Error view
// ─────────────────────────────────────────────────────────────────────────────

class NotificationErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NotificationErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 48,
              color: ntfInk2(context).withOpacity(0.35),
            ),
            const SizedBox(height: NotificationDt.sp16),
            Text(
              message.isNotEmpty ? message : 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: ntfInk2(context),
                height: 1.6,
              ),
            ),
            const SizedBox(height: NotificationDt.sp24),
            SizedBox(
              height: 38,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: NotificationDt.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NotificationDt.r8),
                  ),
                ),
                onPressed: onRetry,
                child: const Text(
                  'Try again',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
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
// Empty view
// ─────────────────────────────────────────────────────────────────────────────

class NotificationEmptyView extends StatelessWidget {
  const NotificationEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 52,
            color: ntfInk2(context).withOpacity(0.25),
          ),
          const SizedBox(height: NotificationDt.sp16),
          Text(
            'All caught up',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ntfInk(context),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: NotificationDt.sp4),
          Text(
            'No notifications right now.',
            style: TextStyle(fontSize: 13, color: ntfInk2(context)),
          ),
        ],
      ),
    );
  }
}
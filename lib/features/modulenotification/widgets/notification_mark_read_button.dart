import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/module_notification_bloc.dart';
import '../notification_design_tokens.dart';

class NotificationMarkReadButton extends StatelessWidget {
  final String notificationId;
  final String seenUrl;

  const NotificationMarkReadButton({
    super.key,
    required this.notificationId,
    required this.seenUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ModuleNotificationBloc, ModuleNotificationState>(
      buildWhen: (p, c) =>
      p.markingReadId != c.markingReadId ||
          p.readMap != c.readMap,
      builder: (context, state) {
        final isLoading = state.isMarkingRead(notificationId);
        final isRead = state.isRead(notificationId);

        return GestureDetector(
          onTap: (isLoading || isRead)
              ? null
              : () {
            context.read<ModuleNotificationBloc>().add(
              NotificationMarkedAsRead(
                notificationId: notificationId,
                seenUrl: seenUrl,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: NotificationDt.sp12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isRead
                  ? NotificationDt.positive.withOpacity(0.08)
                  : ntfSurfaceAlt(context),
              borderRadius: BorderRadius.circular(NotificationDt.r8),
              border: Border.all(
                color: isRead
                    ? NotificationDt.positive.withOpacity(0.25)
                    : ntfBorder(context),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: ntfInk2(context),
                    ),
                  )
                else
                  Icon(
                    isRead
                        ? Icons.check_circle_outline_rounded
                        : Icons.done_outline_rounded,
                    size: 14,
                    color: isRead
                        ? NotificationDt.positive
                        : ntfInk2(context),
                  ),
                const SizedBox(width: 6),
                Text(
                  isLoading
                      ? 'Marking…'
                      : isRead
                      ? 'Read'
                      : 'Mark as read',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isRead
                        ? NotificationDt.positive
                        : ntfInk2(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

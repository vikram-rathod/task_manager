import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/taskchat/bcstep_task_model.dart';
import '../bloc/module_notification_bloc.dart';
import '../notification_design_tokens.dart';

class NotificationMarkReadButton extends StatelessWidget {
  final BcstepTaskModel task;
  final String groupType;
  final String seenUrl;

  const NotificationMarkReadButton({
    super.key,
    required this.task,
    required this.groupType,
    required this.seenUrl,
  });

  @override
  Widget build(BuildContext context) {
    // readKey is unique per item within its type: '{groupType}_{workId|chatId}'
    final readKey = task.readKey(groupType);

    return BlocBuilder<ModuleNotificationBloc, ModuleNotificationState>(
      buildWhen: (p, c) => p.isMarkingRead(readKey) != c.isMarkingRead(readKey),
      builder: (context, state) {
        final isLoading = state.isMarkingRead(readKey);

        return GestureDetector(
          onTap: isLoading
              ? null
              : () {
            context.read<ModuleNotificationBloc>().add(
              NotificationMarkedAsRead(
                readKey: readKey,
                groupType: groupType,
                seenUrl: seenUrl,
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: NotificationDt.sp12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: ntfSurfaceAlt(context),
              borderRadius: BorderRadius.circular(NotificationDt.r8),
              border: Border.all(color: ntfBorder(context)),
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
                    Icons.done_outline_rounded,
                    size: 14,
                    color: ntfInk2(context),
                  ),
                const SizedBox(width: 6),
                Text(
                  isLoading ? 'Marking...' : 'Mark as read',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: ntfInk2(context),
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
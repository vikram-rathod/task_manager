import 'package:flutter/material.dart';

import '../../../core/models/app_notification_acknow_model.dart';
import '../bloc/module_notification_bloc.dart';
import '../notification_design_tokens.dart';
import '../notification_type_config.dart';
import 'notification_card.dart';

class NotificationGroupSection extends StatelessWidget {
  final AppNotificationResponseModel group;
  final ModuleNotificationState state;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const NotificationGroupSection({
    super.key,
    required this.group,
    required this.state,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final type = TaskNotificationType.from(group.type);
    final tc = typeConfigFor(type);

    return SliverMainAxisGroup(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              NotificationDt.sp16,
              NotificationDt.sp20,
              NotificationDt.sp16,
              NotificationDt.sp8,
            ),
            child: NotificationGroupHeader(
              tc: tc,
              count: group.list.length,
              isCollapsed: isCollapsed,
              onToggle: onToggle,
            ),
          ),
        ),

        // Cards (hidden when collapsed)
        if (!isCollapsed)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: NotificationDt.sp16,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, i) {
                  final task = group.list[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: NotificationDt.sp8),
                    child: NotificationCard(
                      task: task,
                      type: type,
                      tc: tc,
                      actionStatus: state.actionFor(task.notificationId),
                    ),
                  );
                },
                childCount: group.list.length,
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationGroupHeader extends StatelessWidget {
  final NotificationTypeConfig tc;
  final int count;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const NotificationGroupHeader({
    super.key,
    required this.tc,
    required this.count,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Dot indicator
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: tc.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: NotificationDt.sp8),

          // Label
          Text(
            tc.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ntfInk2(context),
              letterSpacing: 0.1,
            ),
          ),
          const SizedBox(width: NotificationDt.sp8),

          // Count
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: ntfInk2(context).withOpacity(0.55),
            ),
          ),

          const Spacer(),

          // Animated chevron
          AnimatedRotation(
            turns: isCollapsed ? 0 : 0.5,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: ntfInk2(context),
            ),
          ),
        ],
      ),
    );
  }
}
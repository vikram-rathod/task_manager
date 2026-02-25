import 'package:flutter/material.dart';

import '../../../../core/models/task_model.dart';
import '../../../../reusables/task_card.dart';

class TaskList extends StatelessWidget {
  final List<TMTasksModel> tasks;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final bool canEditPriority;
  final int userId;

  const TaskList({
    required this.tasks,
    required this.isLoadingMore,
    required this.scrollController,
    required this.onRefresh,
    required this.canEditPriority,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == tasks.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            Navigator.pushNamed(context, '/taskDetails', arguments: task);
          },
          onChatTap: () {
            Navigator.pushNamed(context, '/taskChat', arguments: task);
          },
          onRefresh: () {
            onRefresh();
          },
          canEditPriority:
              task.taskPriority != '--' && (canEditPriority ||
              task.checkerId == task.checkerId),
        );
      },
    );
  }
}
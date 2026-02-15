import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reusables/task_history_list.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

class TaskHistorySection extends StatelessWidget {
  const TaskHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      buildWhen: (p, c) =>
      p.isTaskHistoryLoading != c.isTaskHistoryLoading ||
          p.taskHistory != c.taskHistory,
      builder: (context, state) {
        final historyData = state.taskHistory
            .map((item) => TaskHistoryData(
          statement: item.statement,
          createdDate: item.createdDate,
        ))
            .toList();

        return TaskHistoryList(
          historyItems: historyData,
          isLoading: state.isTaskHistoryLoading,
          showViewAll: true,
          maxItems: 5,
          title: 'Recent Activity',
          emptyMessage: 'No recent activity',
          onViewAllTap: () {
            // Navigate to full history page
            // Navigator.pushNamed(context, '/task-history');
          },
          onItemTap: (item) {
            // Navigate to task details
            if (item.taskId != null) {
              // Navigator.pushNamed(
              //   context,
              //   '/task-details',
              //   arguments: item.taskId,
              // );
            }
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/home/screens/project_section.dart';
import 'package:task_manager/features/home/screens/quick_action_section.dart';
import 'package:task_manager/features/home/screens/task_history_section.dart';
import 'package:task_manager/features/home/screens/todays_task_section.dart';

import '../bloc/home_bloc.dart';
import 'employee_wise_count_section.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<HomeBloc>();
    bloc.add(FetchQuickActions());
    bloc.add(FetchTaskHistory());
    bloc.add(LoadProjectList());
    bloc.add(LoadEmployeeWiseTaskList());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(FetchQuickActions());
        context.read<HomeBloc>().add(FetchTaskHistory());
        context.read<HomeBloc>().add(LoadProjectList());
        context.read<HomeBloc>().add(LoadEmployeeWiseTaskList());
        context.read<HomeBloc>().add(const FetchTodaysTasks(page: 1, isMyTasks: true));
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: QuickActionSection()),
          const SliverToBoxAdapter(child: EmployeeSection()),
          const SliverToBoxAdapter(child: ProjectSection()),
          const SliverToBoxAdapter(child: TodaysTaskSection()),
          const SliverToBoxAdapter(child: TaskHistorySection()),
        ],
      ),
    );

  }
}






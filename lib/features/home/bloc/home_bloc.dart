import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../model/quick_action_model.dart';
import '../repository/home_repository.dart';
import 'home_state.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;

  HomeBloc(this.repository) : super(const HomeState()) {
    on<FetchQuickActions>(_fetchQuickActions);
    on<ClearQuickActionsError>(_clearQuickActionsError);
    on<FetchTaskHistory>(_fetchTaskHistory);
    on<ClearTaskHistoryError>(_clearTaskHistoryError);
    on<LoadProjectList>(_onLoadProjectList);
    on<ClearProjectList>(_onClearProjectList);
    on<LoadEmployeeWiseTaskList>(_fetchEmployeeWiseTaskList);
    on<ClearEmployeeWiseTaskListError>(_clearEmployeeWiseTaskListError);
  }

  //  fetch quick actions data for dashboard
  Future<void> _fetchQuickActions(
      FetchQuickActions event,
      Emitter<HomeState> emit,
      ) async {
    emit(state.copyWith(isQuickActionsLoading: true));

    try {
      final data = await repository.getDashboardCounts();

      final actions = [
        QuickActionModel(
          id: 'addTask',
          icon: Icons.add,
          label: 'Add Task-List',
          isHighlighted: true,
          onTap: () {},
        ),
        QuickActionModel(
          id: 'prochat',
          icon: Icons.chat_bubble,
          label: 'Prochat Tasks',
          count: data.proChatCount,
          onTap: () {},
        ),
        QuickActionModel(
          id: 'dueToday',
          icon: Icons.today,
          label: 'Due Today',
          count: data.todayDueCount,
          pendingAtMe: data.todayDuePendingAtMe,
          pendingAtOthers: data.todayDuePendingAtOthers,
          onTap: () {},
        ),
        QuickActionModel(
          id: 'overDue',
          icon: Icons.error_outline,
          label: 'Over Due',
          count: data.overDueCount,
          pendingAtMe: data.overduePendingAtMe,
          pendingAtOthers: data.overduePendingAtOther,
          onTap: () {},
        ),
      ];

      emit(
        state.copyWith(
          isQuickActionsLoading: false,
          quickActions: actions,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[HomeBloc] Error in FetchQuickActions: $e');
      debugPrint(stackTrace.toString());

      final defaultActions = [
        QuickActionModel(
          id: 'addTask',
          icon: Icons.add,
          label: 'Add Task-List',
          isHighlighted: true,
          onTap: () {},
        ),
        QuickActionModel(
          id: 'prochat',
          icon: Icons.chat_bubble,
          label: 'Prochat Tasks',
          count: 0,
          onTap: () {},
        ),
        QuickActionModel(
          id: 'dueToday',
          icon: Icons.today,
          label: 'Due Today',
          count: 0,
          pendingAtMe: 0,
          pendingAtOthers: 0,
          onTap: () {},
        ),
        QuickActionModel(
          id: 'overDue',
          icon: Icons.error_outline,
          label: 'Over Due',
          count: 0,
          pendingAtMe: 0,
          pendingAtOthers: 0,
          onTap: () {},
        ),
      ];

      emit(
        state.copyWith(
          isQuickActionsLoading: false,
          quickActions: defaultActions,
          quickActionsError: e.toString(),
        ),
      );
    }
  }
 
  // fetch task history for dashboard
  Future<void> _fetchTaskHistory(
    FetchTaskHistory event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isTaskHistoryLoading: true, taskHistoryError: null));

    try {
      final history = await repository.getTaskHistory();
      emit(state.copyWith(isTaskHistoryLoading: false, taskHistory: history));
    } catch (e) {
      emit(
        state.copyWith(
          isTaskHistoryLoading: false,
          taskHistoryError: e.toString(),
        ),
      );
    }
  }

// clear task history error
  void _clearTaskHistoryError(
    ClearTaskHistoryError event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(taskHistoryError: null));
  }

  Future<void> _onLoadProjectList(
    LoadProjectList event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isProjectsLoading: true, projectsError: null));
    try {
      final projectsCountList = await repository.getProjectsCountList();
      emit(
        state.copyWith(projects: projectsCountList, isProjectsLoading: false),
      );
    } catch (e, stackTrace) {
      emit(
        state.copyWith(isProjectsLoading: false, projectsError: e.toString()),
      );
    }
  }

  void _onClearProjectList(ClearProjectList event, Emitter<HomeState> emit) {
    emit(state.copyWith(projects: []));
  }

  FutureOr<void> _clearQuickActionsError(
    ClearQuickActionsError event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(quickActionsError: null));
  }


  Future<void> _fetchEmployeeWiseTaskList(
      LoadEmployeeWiseTaskList event,
      Emitter<HomeState> emit,
      ) async {
    emit(state.copyWith(isEmployeeWiseTaskListLoading: true, employeeWiseTaskListError: null));
    try {
      final employeeWiseTaskList = await repository.getEmployeeWiseTaskList();
      debugPrint("Fetched EmployeeWiseTaskList: $employeeWiseTaskList");
      emit(
        state.copyWith(employeeWiseTaskList: employeeWiseTaskList, isEmployeeWiseTaskListLoading: false),
      );
    } catch (e, stackTrace) {
      debugPrint('[HomeBloc] Error in LoadEmployeeWiseTaskList: $e');
      debugPrint(stackTrace.toString());
      emit(
        state.copyWith(isEmployeeWiseTaskListLoading: false, employeeWiseTaskListError: e.toString()),
      );
    }
  }

  void _clearEmployeeWiseTaskListError(ClearEmployeeWiseTaskListError event, Emitter<HomeState> emit) {
    emit(state.copyWith(employeeWiseTaskList: []));
  }


}

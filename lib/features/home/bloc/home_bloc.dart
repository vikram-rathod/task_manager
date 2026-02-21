import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/features/utils/app_exception.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';
import '../model/quick_action_model.dart';
import '../repository/home_repository.dart';
import 'home_state.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository repository;
  final AuthBloc authBloc;

  late final StreamSubscription _authSubscription;


  HomeBloc(this.repository, this.authBloc) : super(const HomeState()) {

    on<RefreshHomeData>(_onRefreshHomeData);
    on<FetchQuickActions>(_fetchQuickActions);
    on<ClearQuickActionsError>(_clearQuickActionsError);
    on<FetchTaskHistory>(_fetchTaskHistory);
    on<ClearTaskHistoryError>(_clearTaskHistoryError);
    on<LoadProjectList>(_onLoadProjectList);
    on<ClearProjectList>(_onClearProjectList);
    on<LoadEmployeeWiseTaskList>(_fetchEmployeeWiseTaskList);
    on<ClearEmployeeWiseTaskListError>(_clearEmployeeWiseTaskListError);
    on<FetchTodaysTasks>(_fetchTodaysTasks);
    on<ClearTodaysTasksError>(_clearTodaysTasksError);

    _authSubscription = authBloc.stream.listen((authState) {
      debugPrint('HomeBloc: _authSubscription state: $authState');
      if (authState is AuthAuthenticated) {
        add(RefreshHomeData());
      }
    });
  }

  Future<void> _onRefreshHomeData(
      RefreshHomeData event,
      Emitter<HomeState> emit,
      ) async {
    debugPrint('HomeBloc: _onRefreshHomeData');

    add(FetchQuickActions());
    add(FetchTaskHistory());
    add(LoadProjectList());
    add(LoadEmployeeWiseTaskList());
    add(const FetchTodaysTasks(page: 1, isMyTasks: true));
  }

  Future<void> _fetchQuickActions(
      FetchQuickActions event,
      Emitter<HomeState> emit,
      ) async {
    final staticActions = [
      QuickActionModel(
        id: 'addTask',
        icon: Icons.add,
        label: 'Add Task-List',
        isHighlighted: true,
        onTap: () {},
      ),
      QuickActionModel(
        id: 'prochat',
        icon: Icons.chat_bubble_outline,
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

    emit(state.copyWith(
      isQuickActionsLoading: true,
      quickActions: staticActions,
      notificationCount: 0
    ));

    try {
      final data = await repository.getDashboardCounts();

      final updatedActions = staticActions.map((action) {
        switch (action.id) {
          case 'prochat':
            return action.copyWith(count: data.proChatCount);
          case 'dueToday':
            return action.copyWith(
              count: data.todayDueCount,
              pendingAtMe: data.todayDuePendingAtMe,
              pendingAtOthers: data.todayDuePendingAtOthers,
            );
          case 'overDue':
            return action.copyWith(
              count: data.overDueCount,
              pendingAtMe: data.overduePendingAtMe,
              pendingAtOthers: data.overduePendingAtOther,
            );
          default:
            return action;
        }
      }).toList();

      emit(state.copyWith(
        isQuickActionsLoading: false,
        quickActions: updatedActions,
          notificationCount: data.notificationCount
      ));
    } catch (e, stackTrace) {
      debugPrint('[HomeBloc] Error in FetchQuickActions: $e');
      final exception = AppExceptionMapper.from(e);
      debugPrint(stackTrace.toString());
      emit(state.copyWith(
        isQuickActionsLoading: false,
        quickActionsError: exception.message,

          notificationCount: 0
      ));
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
      debugPrint('[HomeBloc] Error in FetchTaskHistory: $e');
      final exception = AppExceptionMapper.from(e);
      debugPrint(exception.message);
      emit(
        state.copyWith(
          isTaskHistoryLoading: false,
          taskHistoryError: exception.message,
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
    } catch (e) {
      debugPrint('[HomeBloc] Error in LoadProjectList: $e');
      final exception = AppExceptionMapper.from(e);
      emit(
        state.copyWith(isProjectsLoading: false, projectsError: exception.message),
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
      final exception = AppExceptionMapper.from(e);
      debugPrint(stackTrace.toString());
      emit(
        state.copyWith(isEmployeeWiseTaskListLoading: false, employeeWiseTaskListError: exception.message),
      );
    }
  }

  void _clearEmployeeWiseTaskListError(ClearEmployeeWiseTaskListError event, Emitter<HomeState> emit) {
    emit(state.copyWith(employeeWiseTaskList: []));
  }

  static const String _tag = "HomeBlocTodayTasks";

// Fetch today's tasks
  Future<void> _fetchTodaysTasks(
      FetchTodaysTasks event,
      Emitter<HomeState> emit,
      ) async {
    final isMyTasks = event.isMyTasks;
    final page = event.page;

    debugPrint("[$_tag] ===== FetchTodaysTasks START =====");
    debugPrint("[$_tag] Type : ${isMyTasks ? "MyTasks" : "OtherTasks"} | Page : $page");

    if (isMyTasks) {
      if (page == 1) {
        debugPrint("[$_tag] MyTasks Loading = true");
        emit(state.copyWith(isMyTasksLoading: true, myTasksError: null));
      }

      try {
        debugPrint("[$_tag] Calling API (MyTasks) → page=$page");

        final tasks = await repository.getTodaysTmTasks(
          page: page,
          isMyTasks: true,
          size: 10,
        );

        debugPrint("[$_tag] API SUCCESS (MyTasks) | Count: ${tasks.length}");

        final updatedTasks =
        page == 1 ? tasks : [...state.myTasks, ...tasks];

        final hasMore = tasks.length >= 10;

        debugPrint("[$_tag] Updated Total: ${updatedTasks.length} | HasMore: $hasMore");

        emit(state.copyWith(
          isMyTasksLoading: false,
          myTasks: updatedTasks,
          myTasksPage: page,
          hasMoreMyTasks: hasMore,
          myTasksError: null,
        ));

        debugPrint("[$_tag] State Updated (MyTasks)");
      } catch (e, stackTrace) {
        debugPrint("[$_tag] API ERROR (MyTasks) → $e");
        debugPrint("[$_tag] StackTrace → $stackTrace");
        final exception = AppExceptionMapper.from(e);


        emit(state.copyWith(
          isMyTasksLoading: false,
          myTasksError: exception.message,
        ));
      }
    } else {
      if (page == 1) {
        debugPrint("[$_tag] OtherTasks Loading = true");
        emit(state.copyWith(isOtherTasksLoading: true, otherTasksError: null));
      }

      try {
        debugPrint("[$_tag] Calling API (OtherTasks) → page=$page");

        final tasks = await repository.getTodaysTmTasks(
          page: page,
          isMyTasks: false,
          size: 10,
        );

        debugPrint("[$_tag] API SUCCESS (OtherTasks) | Count: ${tasks.length}");

        final updatedTasks =
        page == 1 ? tasks : [...state.otherTasks, ...tasks];

        final hasMore = tasks.length >= 10;

        debugPrint("[$_tag] Updated Total: ${updatedTasks.length} | HasMore: $hasMore");

        emit(state.copyWith(
          isOtherTasksLoading: false,
          otherTasks: updatedTasks,
          otherTasksPage: page,
          hasMoreOtherTasks: hasMore,
          otherTasksError: null,
        ));

        debugPrint("[$_tag] State Updated (OtherTasks)");
      } catch (e, stackTrace) {
        debugPrint("[$_tag] API ERROR (OtherTasks) → $e");
        debugPrint("[$_tag] StackTrace → $stackTrace");
        final exception = AppExceptionMapper.from(e);


        emit(state.copyWith(
          isOtherTasksLoading: false,
          otherTasksError: exception.message,
        ));
      }
    }

    debugPrint("[$_tag] ===== FetchTodaysTasks END =====\n");
  }


  void _clearTodaysTasksError(
      ClearTodaysTasksError event,
      Emitter<HomeState> emit,
      ) {
    emit(state.copyWith(
      myTasksError: null,
      otherTasksError: null,
    ));
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}



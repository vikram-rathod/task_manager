import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../../../reusables/custom_tabs.dart';
import '../../home/repository/task_repository.dart';

part 'due_today_event.dart';
part 'due_today_state.dart';

class DueTodayBloc extends Bloc<DueTodayEvent, DueTodayState> {
  final TaskRepository _repository;
  final StorageService _storageService;
  DueTodayBloc(
      this._repository,
      this._storageService,
      ) : super(DueTodayState()) {
    on<InitializeTabs>(_onInitializeTabs);
    on<FetchDueTasks>(_onFetchDueTodayTasks);
    on<ChangeTaskTab>(_onChangeTab);
    on<ResetTaskState>(_onResetState);
  }

  Future<void> _onInitializeTabs(
      InitializeTabs event,
      Emitter<DueTodayState> emit,
      ) async {

    final tabs =  [
      // Viewing own tasks
      const TaskTab(
        id: '0',
        label: 'Pending@U',
        icon: Icons.person_outline_rounded,
      ),
      const TaskTab(
        id: '1',
        label: 'Pending@Others',
        icon: Icons.groups_outlined,
      ),
    ];

    emit(state.copyWith(tabs: tabs));

  }

  Future<void> _onFetchDueTodayTasks(
      FetchDueTasks event,
      Emitter<DueTodayState> emit,
      ) async {
    final tabId = event.tabId;
    final isFirstPage = event.page == 1;

    print(' [DueTodayBloc] Fetching tasks for tab: $tabId, page: ${event.page}, isRefresh: ${event.isRefresh}');

    // Set loading state
    if (isFirstPage) {
      // Initial load or refresh - clear existing tasks if refresh and show main loader
      final updatedTasksByTab = event.isRefresh
          ? {...state.tasksByTab, tabId: <dynamic>[]}
          : state.tasksByTab;

      emit(state.copyWith(
        tasksByTab: updatedTasksByTab,
        loadingByTab: {...state.loadingByTab, tabId: true},
        errorsByTab: {...state.errorsByTab, tabId: null},
        pagesByTab: {...state.pagesByTab, tabId: 1},
      ));
    } else {
      // Pagination load - show pagination loader
      emit(state.copyWith(
        paginationLoadingByTab: {...state.paginationLoadingByTab, tabId: true},
      ));
    }

    try {
      final userId = await _storageService.read(StorageKeys.userId) ?? "";
      final compId = await _storageService.read(StorageKeys.companyId) ?? "";
      final userType = await _storageService.read(StorageKeys.userType) ?? "";

      print(' [DueTodayBloc] Request params: userId=$userId, compId=$compId, userType=$userType');

      final response = await _repository.fetchDueTodayTasks(
        type: tabId,
        userId: userId,
        compId: compId,
        userType: userType,
        page: event.page,
        size: event.size,
        search: event.search,
      );

      print(' [DueTodayBloc] Response received: status=${response.status}, hasData=${response.data != null}');

      // Handle successful response
      if (response.status && response.data != null) {
        final newTasks = response.data as List<dynamic>;
        print(' [DueTodayBloc] Fetched ${newTasks.length} tasks for page ${event.page}');

        // Determine if there are more pages
        final hasMore = newTasks.length >= event.size;

        // Get existing tasks for this tab
        final existingTasks = state.tasksByTab[tabId] ?? [];

        // Merge or replace tasks
        // For first page or refresh, replace completely
        // For pagination, append to existing
        final updatedTasks = isFirstPage
            ? newTasks
            : [...existingTasks, ...newTasks];

        print(' [DueTodayBloc] Total tasks for tab $tabId: ${updatedTasks.length} (previous: ${existingTasks.length}, new: ${newTasks.length})');

        emit(state.copyWith(
          tasksByTab: {...state.tasksByTab, tabId: updatedTasks},
          loadingByTab: {...state.loadingByTab, tabId: false},
          paginationLoadingByTab: {...state.paginationLoadingByTab, tabId: false},
          errorsByTab: {...state.errorsByTab, tabId: null},
          pagesByTab: {...state.pagesByTab, tabId: event.page},
          hasMoreByTab: {...state.hasMoreByTab, tabId: hasMore},
        ));
      } else {
        // Handle error response
        final errorMessage = response.message ?? 'Failed to load tasks';
        print(' [DueTodayBloc] Error: $errorMessage');

        emit(state.copyWith(
          loadingByTab: {...state.loadingByTab, tabId: false},
          paginationLoadingByTab: {...state.paginationLoadingByTab, tabId: false},
          errorsByTab: {...state.errorsByTab, tabId: errorMessage},
          hasMoreByTab: {...state.hasMoreByTab, tabId: false},
        ));
      }
    } catch (e, stackTrace) {
      print(' [DueTodayBloc] Exception: $e');
      print('   Stack trace: $stackTrace');

      emit(state.copyWith(
        loadingByTab: {...state.loadingByTab, tabId: false},
        paginationLoadingByTab: {...state.paginationLoadingByTab, tabId: false},
        errorsByTab: {...state.errorsByTab, tabId: 'An unexpected error occurred'},
        hasMoreByTab: {...state.hasMoreByTab, tabId: false},
      ));
    }
  }

  Future<void> _onChangeTab(
      ChangeTaskTab event,
      Emitter<DueTodayState> emit,
      ) async {
    print(' [DueTodayBloc] Changing tab to index: ${event.tabIndex}');

    emit(state.copyWith(currentTabIndex: event.tabIndex));

    if (state.tabs.isNotEmpty && event.tabIndex < state.tabs.length) {
      final currentTab = state.tabs[event.tabIndex];
      print(' [DueTodayBloc] Tab changed to: ${currentTab.label} (id: ${currentTab.id})');
    }
  }

  Future<void> _onResetState(
      ResetTaskState event,
      Emitter<DueTodayState> emit,
      ) async {
    print(' [DueTodayBloc] Resetting state - Screen is closing');

    // Reset to initial empty state
    emit(const DueTodayState());
  }


}


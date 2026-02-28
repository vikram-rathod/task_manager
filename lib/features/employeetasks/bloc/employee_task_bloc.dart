import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:task_manager/core/storage/storage_keys.dart';
import 'package:task_manager/core/storage/storage_service.dart';

import '../../../core/constants/app_constant.dart';
import '../../../reusables/custom_tabs.dart';
import '../../home/repository/task_repository.dart';
import '../../utils/app_exception.dart';

part 'employee_task_event.dart';
part 'employee_task_state.dart';

class EmployeeTaskBloc extends Bloc<EmployeeTaskEvent, EmployeeTaskState> {
  final TaskRepository _repository;
  final StorageService _storageService;

  EmployeeTaskBloc(
      this._repository,
      this._storageService,
      ) : super(const EmployeeTaskState()) {
    on<LoadUserRole>(_onLoadUserRole);
    on<InitializeEmployeeTabs>(_onInitializeTabs);
    on<FetchEmployeeTasks>(_onFetchEmployeeTasks);
    on<ChangeEmployeeTaskTab>(_onChangeTab);
    on<ResetEmployeeTaskState>(_onResetState);
  }

  Future<void> _onLoadUserRole(LoadUserRole event,
      Emitter<EmployeeTaskState> emit,) async {
    final userType = await _storageService.read(StorageKeys.userType) ?? "";
    final loginUserId = await _storageService.read(StorageKeys.userId) ?? "0";


    final isHighAuthority =
        AppConstant.owners.contains(userType) ||
            AppConstant.partners.contains(userType);

    emit(state.copyWith(isHighAuthority: isHighAuthority,
        loginUserId: int.tryParse(loginUserId)));
  }


  Future<void> _onInitializeTabs(
      InitializeEmployeeTabs event,
      Emitter<EmployeeTaskState> emit,
      ) async {
    print(' [EmployeeTaskBloc] Initializing tabs...');
    print('   Employee User ID: ${event.employeeUserId}');

    final loggedUserId = await _storageService.read(StorageKeys.userId);
    print('   Logged User ID: $loggedUserId');

    final isViewingOwnTasks = loggedUserId == event.employeeUserId;
    print('   Is viewing own tasks: $isViewingOwnTasks');

    final tabs = isViewingOwnTasks
        ? [
      // Viewing own tasks
      const TaskTab(
        id: '0',
        label: 'For U',
        icon: Icons.person_outline_rounded,
      ),
      const TaskTab(
        id: '1',
        label: 'For Others',
        icon: Icons.groups_outlined,
      ),
    ]
        : [
      // Viewing others' tasks
      const TaskTab(
        id: '0',
        label: 'For User',
        icon: Icons.person_outline_rounded,
      ),
      const TaskTab(
        id: '1',
        label: 'For Others',
        icon: Icons.groups_outlined,
      ),
    ];

    print(' [EmployeeTaskBloc] Tabs initialized: ${tabs.length} tabs');
    for (var tab in tabs) {
      print('   - Tab ${tab.id}: ${tab.label}');
    }

    emit(state.copyWith(tabs: tabs));
  }

  Future<void> _onFetchEmployeeTasks(
      FetchEmployeeTasks event,
      Emitter<EmployeeTaskState> emit,
      ) async {
    final tabId = event.tabId;
    final isFirstPage = event.page == 1;

    print(' [EmployeeTaskBloc] Fetching tasks for tab: $tabId, page: ${event.page}, isRefresh: ${event.isRefresh}');

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

      print(' [EmployeeTaskBloc] Request params: userId=$userId, compId=$compId, userType=$userType, employeeId=${event.employeeId}');

      final response = await _repository.fetchEmployeeWiseTasks(
        tabId: tabId,
        userId: userId,
        compId: compId,
        userType: userType,
        page: event.page,
        size: event.size,
        employeeId: event.employeeId,
        search: event.search,
      );

      print(' [EmployeeTaskBloc] '
          'Response received: status=${response.status}, '
          'hasData=${response.data != null}'
          'message=${response.data}'
      );

      // Handle successful response
      if (response.status && response.data != null) {
        final newTasks = response.data as List<dynamic>;
        print(' [EmployeeTaskBloc] Fetched ${newTasks.length} tasks for page ${event.page}');

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

        print(' [EmployeeTaskBloc] Total tasks for tab $tabId: ${updatedTasks.length} (previous: ${existingTasks.length}, new: ${newTasks.length})');

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
        print(' [EmployeeTaskBloc] Error: $errorMessage');

        emit(state.copyWith(
          loadingByTab: {...state.loadingByTab, tabId: false},
          paginationLoadingByTab: {...state.paginationLoadingByTab, tabId: false},
          errorsByTab: {...state.errorsByTab, tabId: errorMessage},
          hasMoreByTab: {...state.hasMoreByTab, tabId: false},
        ));
      }
    } catch (e, stackTrace) {
      print(' [EmployeeTaskBloc] Exception: $e');
      print('   Stack trace: $stackTrace');
      final exception = AppExceptionMapper.from(e);

      emit(state.copyWith(
        loadingByTab: {...state.loadingByTab, tabId: false},
        paginationLoadingByTab: {...state.paginationLoadingByTab, tabId: false},
        errorsByTab: {...state.errorsByTab, tabId: exception.message},
        hasMoreByTab: {...state.hasMoreByTab, tabId: false},
      ));
    }
  }

  Future<void> _onChangeTab(
      ChangeEmployeeTaskTab event,
      Emitter<EmployeeTaskState> emit,
      ) async {
    print(' [EmployeeTaskBloc] Changing tab to index: ${event.tabIndex}');

    emit(state.copyWith(currentTabIndex: event.tabIndex));

    if (state.tabs.isNotEmpty && event.tabIndex < state.tabs.length) {
      final currentTab = state.tabs[event.tabIndex];
      print(' [EmployeeTaskBloc] Tab changed to: ${currentTab.label} (id: ${currentTab.id})');
    }
  }

  Future<void> _onResetState(
      ResetEmployeeTaskState event,
      Emitter<EmployeeTaskState> emit,
      ) async {
    print(' [EmployeeTaskBloc] 🔄 Resetting state - Screen is closing');

    // Reset to initial empty state
    emit(const EmployeeTaskState());
  }
}
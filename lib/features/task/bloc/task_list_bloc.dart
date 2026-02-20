import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/task/service/task_list_service.dart';

import '../../../core/constants/app_constant.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/storage/storage_service.dart';
import '../repository/task_list_repository.dart';
import 'task_list_event.dart';
import 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  static const String _tag = "TaskListBloc";

  final TaskListRepository repository;
  final StorageService storage;
  final TaskListService service;

  TaskListBloc(this.repository,
      this.service,
      this.storage,) : super(TaskListState()) {
    on<LoadTaskHierarchy>(_onLoadTaskHierarchy);
    on<TransferTaskRequested>(_onTransferTask);
    on<ChangeTab>(_onChangeTab);
    on<LoadUserRole>(_onLoadUserRole);
    on<ClearTaskItems>(_onClearTaskItems);
    on<ResetTaskList>(_onResetTaskList);

    debugPrint("[$_tag] Initialized");
  }

  Future<void> _onLoadUserRole(LoadUserRole event,
      Emitter<TaskListState> emit,) async {
    final userType = await storage.read(StorageKeys.userType) ?? "";
    debugPrint("$_tag: Current Logged UserType: $userType");

    final isFounderOrPartner =
        AppConstant.owners.contains(userType) ||
            AppConstant.partners.contains(userType);

    emit(state.copyWith(isFounderOrPartner: isFounderOrPartner));
  }


  Future<void> _onChangeTab(ChangeTab event,
      Emitter<TaskListState> emit,) async {
    debugPrint(
        "[$_tag] ChangeTab -> tabId: ${event.tabId}, index: ${event.tabIndex}");

    emit(state.copyWith(
      selectedTabId: event.tabId,
      selectedTabIndex: event.tabIndex,
    ));
  }

  Future<void> _onLoadTaskHierarchy(
      LoadTaskHierarchy event,
      Emitter<TaskListState> emit,
      ) async {
    debugPrint("[$_tag] LoadTaskHierarchy -> projectId: ${event
        .projectId}, tabId: ${event.tabId}");

    emit(state.copyWith(isLoading: true));

    try {
      final data = await repository.fetchTaskHierarchy(
        projectId: event.projectId,
        tabId: event.tabId,
      );

      debugPrint("[$_tag] Hierarchy Loaded -> items: ${data.length}");

      emit(state.copyWith(
        isLoading: false,
        items: data,
        error: null,
      ));
    } catch (e, stackTrace) {
      debugPrint("[$_tag] Load Error -> $e");
      debugPrint("[$_tag] StackTrace -> $stackTrace");

      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onTransferTask(
      TransferTaskRequested event,
      Emitter<TaskListState> emit,
      ) async {
    debugPrint("[$_tag] TransferTask -> taskId: ${event.taskId}");

    final userId = await storage.read("user_id") ?? "";
    final compId = await storage.read("company_id") ?? "";
    final userType = await storage.read("user_type") ?? "";

    debugPrint(
        "[$_tag] UserInfo -> userId: $userId, compId: $compId, userType: $userType");

    try {
      final success = await service.transferTask(
        userId: userId,
        compId: compId,
        taskId: event.taskId,
        projectId: event.projectId,
        userType: userType,
      );

      debugPrint("[$_tag] Transfer Response -> success: $success");

      if (success) {
        debugPrint("[$_tag] Reloading hierarchy after transfer");

        add(LoadTaskHierarchy(
          projectId: event.projectId,
          tabId: state.selectedTabId,
        ));
      }
    } catch (e, stackTrace) {
      debugPrint("[$_tag] Transfer Error -> $e");
      debugPrint("[$_tag] StackTrace -> $stackTrace");
    }
  }

  // Only clears items, keeps tab & role state
  void _onClearTaskItems(ClearTaskItems event, Emitter<TaskListState> emit) {
    emit(state.copyWith(
      items: [],
      isLoading: false,
      error: null,
    ));
  }

// Full reset when screen closes
  void _onResetTaskList(ResetTaskList event, Emitter<TaskListState> emit) {
    emit(TaskListState());
  }
}

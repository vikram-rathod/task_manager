import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/task/service/task_list_service.dart';
import '../../../core/storage/storage_service.dart';
import '../repository/task_list_repository.dart';
import 'task_list_event.dart';
import 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final TaskListRepository repository;
  final StorageService storage;
  final TaskListService service;

  TaskListBloc(this.repository, this.service,
      this.storage,) : super(TaskListState()) {
    on<LoadTaskHierarchy>(_onLoadTaskHierarchy);
    on<TransferTaskRequested>(_onTransferTask);
  }

  Future<void> _onLoadTaskHierarchy(
      LoadTaskHierarchy event,
      Emitter<TaskListState> emit,
      ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final data = await repository.fetchTaskHierarchy(
        projectId: event.projectId,
        tabId: event.tabId,
      );

      emit(state.copyWith(
        isLoading: false,
        items: data,
      ));
    } catch (e) {
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
    final userId = await storage.read("user_id") ?? "";
    final compId = await storage.read("company_id") ?? "";
    final userType = await storage.read("user_type") ?? "";

    try {
      final success = await service.transferTask(
        userId: userId,
        compId: compId,
        taskId: event.taskId,
        projectId: event.projectId,
        userType: userType,
      );

      if (success) {
        // Reload hierarchy after transfer
        add(LoadTaskHierarchy(
          projectId: event.projectId,
          tabId: state.selectedTabId,
        ));
      }
    } catch (e) {
      debugPrint("Transfer failed: $e");
    }
  }

}

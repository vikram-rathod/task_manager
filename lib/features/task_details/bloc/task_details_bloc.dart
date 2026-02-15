import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/core/storage/storage_service.dart';
import 'package:task_manager/features/home/model/task_history_model.dart';
import 'package:task_manager/features/home/repository/task_repository.dart';

import '../../../core/models/task_model.dart';

part 'task_details_event.dart';
part 'task_details_state.dart';

class TaskDetailsBloc extends Bloc<TaskDetailsEvent, TaskDetailsState> {
  final TaskRepository _taskRepository;
  final StorageService _storageService;

  TaskDetailsBloc(
      this._taskRepository,
      this._storageService,
      ) : super(TaskDetailsState()) {
    on<FetchTaskDetails>(_onFetchTaskDetails);
    on<ResetTaskState>(_onResetTaskState);
  }
  Future<void> _onFetchTaskDetails (
      FetchTaskDetails event,
      Emitter<TaskDetailsState> emit,
      ) async {
    print(' [TaskDetailsBloc] Fetching task details for taskId: ${event.taskId}');
    emit(state.copyWith(isLoading: true, errorMessage: null));

    try {
      final taskId = int.tryParse(event.taskId);

      if (taskId == null) {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid task ID',
        ));
        return;
      }

      final response = await _taskRepository.fetchTaskDetails(taskId);

      if (response.status && response.data != null) {
        print(' [TaskDetailsBloc] Successfully fetched task details');
        emit(state.copyWith(
          isLoading: false,
          taskModel: response.data!.taskDetails,
          history: response.data!.history,
          errorMessage: null,
        ));
      } else {
        print(' [TaskDetailsBloc] Failed to fetch task details: ${response.message}');
        emit(state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Failed to fetch task details',
        ));
      }
    } catch (e) {
      print(' [TaskDetailsBloc] Error fetching task details: $e');
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'An error occurred while fetching task details',
      ));
    }
  }

  void _onResetTaskState(
      ResetTaskState event,
      Emitter<TaskDetailsState> emit,
      ) {
    print(' [TaskDetailsBloc] Resetting task state');
    emit(TaskDetailsState());
  }

}
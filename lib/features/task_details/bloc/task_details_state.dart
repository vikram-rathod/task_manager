part of 'task_details_bloc.dart';

class TaskDetailsState extends Equatable {

  final bool isLoading;
  final String? errorMessage;
  final TMTasksModel? taskModel;
  final List<TaskHistoryModel> history;

  const TaskDetailsState({
    this.isLoading = false,
    this.errorMessage,
    this.taskModel,
    this.history = const [],
  });

  TaskDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    TMTasksModel? taskModel,
    List<TaskHistoryModel>? history,
  }) {
    return TaskDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      taskModel: taskModel ?? this.taskModel,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props =>
      [
        isLoading,
        errorMessage,
        taskModel,
        history,
      ];

}
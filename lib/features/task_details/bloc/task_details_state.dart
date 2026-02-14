part of 'task_details_bloc.dart';

class TaskDetailsState extends Equatable {

  final bool isLoading;
  final String? errorMessage;
  final TMTasksModel? taskModel;

  const TaskDetailsState({
    this.isLoading = false,
    this.errorMessage,
    this.taskModel,
  });

  TaskDetailsState copyWith({
    bool? isLoading,
    String? errorMessage,
    TMTasksModel? taskModel,
  }) {
    return TaskDetailsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      taskModel: taskModel ?? this.taskModel,
    );
  }

  @override
  List<Object?> get props =>
      [
        isLoading,
        errorMessage,
        taskModel,
      ];

}



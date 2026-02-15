part of 'task_details_bloc.dart';

class TaskDetailsEvent extends Equatable {
  const TaskDetailsEvent();
  @override
  List<Object?> get props => [];
}

class FetchTaskDetails extends TaskDetailsEvent {
  final String taskId;

  const FetchTaskDetails(this.taskId);
  @override
  List<Object?> get props => [taskId];
}

class ResetTaskState extends TaskDetailsEvent {
  const ResetTaskState();

  @override
  List<Object?> get props => [];
}
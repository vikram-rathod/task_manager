part of 'task_priority_bloc.dart';
abstract class ChangePriorityEvent {}

class SubmitPriorityChange extends ChangePriorityEvent {
  final String taskId;
  final String priority;

  SubmitPriorityChange({
    required this.taskId,
    required this.priority,
  });

  SubmitPriorityChange copyWith({
    String? userId,
    String? taskId,
    String? priority,
  }) {
    return SubmitPriorityChange(
      taskId: taskId ?? this.taskId,
      priority: priority ?? this.priority,
    );
  }
}

class ResetPriorityState extends ChangePriorityEvent {}
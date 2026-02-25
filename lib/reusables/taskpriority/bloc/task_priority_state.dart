part of 'task_priority_bloc.dart';

abstract class ChangePriorityState {}

class ChangePriorityInitial extends ChangePriorityState {}

class ChangePriorityLoading extends ChangePriorityState {}

class ChangePrioritySuccess extends ChangePriorityState {
  final String message;

  ChangePrioritySuccess({this.message = 'Priority changed successfully'});
}

class ChangePriorityFailure extends ChangePriorityState {
  final String message;

  ChangePriorityFailure({required this.message});

  ChangePriorityFailure copyWith({String? message}) {
    return ChangePriorityFailure(message: message ?? this.message);
  }
}

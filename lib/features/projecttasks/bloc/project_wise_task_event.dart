import 'package:equatable/equatable.dart';
import 'package:task_manager/features/projecttasks/bloc/project_wise_task_state.dart';

import '../../auth/models/user_model.dart';
import '../../home/model/project_count_model.dart';

abstract class ProjectWiseTaskEvent extends Equatable {
  const ProjectWiseTaskEvent();

  @override
  List<Object?> get props => [];
}

class InitializeProjectWiseTask extends ProjectWiseTaskEvent {
  final ProjectCountModel project;
  const InitializeProjectWiseTask(this.project);

  @override
  List<Object?> get props => [project];
}

class UserRoleSelected extends ProjectWiseTaskEvent {
  final UserRoleType role;
  const UserRoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}

class MakerUserSelected extends ProjectWiseTaskEvent {
  final UserModel user;
  const MakerUserSelected(this.user);

  @override
  List<Object?> get props => [user];
}

class CheckerUserSelected extends ProjectWiseTaskEvent {
  final UserModel user;
  const CheckerUserSelected(this.user);

  @override
  List<Object?> get props => [user];
}

class PcEngineerSelected extends ProjectWiseTaskEvent {
  final UserModel user;
  const PcEngineerSelected(this.user);

  @override
  List<Object?> get props => [user];
}

class SearchQueryChanged extends ProjectWiseTaskEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadNextPage extends ProjectWiseTaskEvent {
  const LoadNextPage();
}

class RefreshTasks extends ProjectWiseTaskEvent {
  const RefreshTasks();
}

class ResetProjectWiseTaskState extends ProjectWiseTaskEvent {
  const ResetProjectWiseTaskState();
}
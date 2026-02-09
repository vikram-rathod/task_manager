import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:task_manager/features/auth/models/user_model.dart';

import '../../../core/models/project_model.dart';

abstract class CreateTaskEvent extends Equatable {
  const CreateTaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadProjectList extends CreateTaskEvent {}

class ProjectSelected extends CreateTaskEvent {
  final ProjectModel project;
  const ProjectSelected(this.project);

  @override
  List<Object?> get props => [project];
}

class ProjectCleared extends CreateTaskEvent {}

class CheckerSelected extends CreateTaskEvent {
  final UserModel checker;
  const CheckerSelected(this.checker);

  @override
  List<Object?> get props => [checker];
}

class CheckerCleared extends CreateTaskEvent {}

class MakerSelected extends CreateTaskEvent {
  final UserModel maker;
  const MakerSelected(this.maker);

  @override
  List<Object?> get props => [maker];
}

class MakerCleared extends CreateTaskEvent {}

class PcEngineerSelected extends CreateTaskEvent {
  final UserModel engineer;
  const PcEngineerSelected(this.engineer);

  @override
  List<Object?> get props => [engineer];
}

class PcEngineerCleared extends CreateTaskEvent {}

class TaskDescriptionChanged extends CreateTaskEvent {
  final String description;
  const TaskDescriptionChanged(this.description);

  @override
  List<Object?> get props => [description];
}

class TentativeDateChanged extends CreateTaskEvent {
  final DateTime date;
  const TentativeDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class RemarkChanged extends CreateTaskEvent {
  final String remark;
  const RemarkChanged(this.remark);

  @override
  List<Object?> get props => [remark];
}

class AttachmentPickerOpened extends CreateTaskEvent {}

class AttachmentAdded extends CreateTaskEvent {
  final List<File> files;
  const AttachmentAdded(this.files);

  @override
  List<Object?> get props => [files];
}
class PickFromCameraRequested extends CreateTaskEvent {}
class PickFromGalleryRequested extends CreateTaskEvent {}

class PickDocumentsRequested extends CreateTaskEvent {}


class AttachmentRemoved extends CreateTaskEvent {
  final File file;
  const AttachmentRemoved(this.file);

  @override
  List<Object?> get props => [file];
}

class CreateTaskSubmitted extends CreateTaskEvent {}

class ResetCreateTaskState extends CreateTaskEvent {}

class ClearError extends CreateTaskEvent {}
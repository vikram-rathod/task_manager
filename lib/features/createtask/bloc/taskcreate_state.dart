import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:task_manager/features/auth/models/user_model.dart';

import '../../../core/models/project_model.dart';

enum TaskCreateStatus { idle, loading, success, error }

class CreateTaskState extends Equatable {
  final List<ProjectModel> projects;
  final List<UserModel> checkers;
  final List<UserModel> makers;
  final List<UserModel> pcEngineers;

  final ProjectModel? selectedProject;
  final UserModel? selectedChecker;
  final UserModel? selectedMaker;
  final UserModel? selectedPcEngineer;

  final String taskDescription;
  final DateTime? tentativeDate;
  final String remark;
  final List<File> selectedFiles;

  final bool projectListLoading;
  final bool checkerListLoading;
  final bool makerListLoading;
  final bool pcEngineerListLoading;

  final TaskCreateStatus taskCreateStatus;
  final String? errorMessage;
  final String? successMessage;

  const CreateTaskState({
    this.projects = const [],
    this.checkers = const [],
    this.makers = const [],
    this.pcEngineers = const [],
    this.selectedProject,
    this.selectedChecker,
    this.selectedMaker,
    this.selectedPcEngineer,
    this.taskDescription = '',
    this.tentativeDate,
    this.remark = '',
    this.selectedFiles = const [],
    this.projectListLoading = false,
    this.checkerListLoading = false,
    this.makerListLoading = false,
    this.pcEngineerListLoading = false,
    this.taskCreateStatus = TaskCreateStatus.idle,
    this.errorMessage,
    this.successMessage,
  });

  bool get isFormValid =>
      selectedProject != null &&
          taskDescription.trim().isNotEmpty;

  bool get isLoading =>
      projectListLoading ||
          checkerListLoading ||
          makerListLoading ||
          pcEngineerListLoading ||
          taskCreateStatus == TaskCreateStatus.loading;

  CreateTaskState copyWith({
    List<ProjectModel>? projects,
    List<UserModel>? checkers,
    List<UserModel>? makers,
    List<UserModel>? pcEngineers,
    ProjectModel? selectedProject,
    UserModel? selectedChecker,
    UserModel? selectedMaker,
    UserModel? selectedPcEngineer,
    String? taskDescription,
    DateTime? tentativeDate,
    String? remark,
    List<File>? selectedFiles,
    bool? projectListLoading,
    bool? checkerListLoading,
    bool? makerListLoading,
    bool? pcEngineerListLoading,
    TaskCreateStatus? taskCreateStatus,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedProject = false,
    bool clearSelectedChecker = false,
    bool clearSelectedMaker = false,
    bool clearSelectedPcEngineer = false,
    bool clearTentativeDate = false,
  }) {
    return CreateTaskState(
      projects: projects ?? this.projects,
      checkers: checkers ?? this.checkers,
      makers: makers ?? this.makers,
      pcEngineers: pcEngineers ?? this.pcEngineers,
      selectedProject: clearSelectedProject ? null : (selectedProject ?? this.selectedProject),
      selectedChecker: clearSelectedChecker ? null : (selectedChecker ?? this.selectedChecker),
      selectedMaker: clearSelectedMaker ? null : (selectedMaker ?? this.selectedMaker),
      selectedPcEngineer: clearSelectedPcEngineer ? null : (selectedPcEngineer ?? this.selectedPcEngineer),
      taskDescription: taskDescription ?? this.taskDescription,
      tentativeDate: clearTentativeDate ? null : (tentativeDate ?? this.tentativeDate),
      remark: remark ?? this.remark,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      projectListLoading: projectListLoading ?? this.projectListLoading,
      checkerListLoading: checkerListLoading ?? this.checkerListLoading,
      makerListLoading: makerListLoading ?? this.makerListLoading,
      pcEngineerListLoading: pcEngineerListLoading ?? this.pcEngineerListLoading,
      taskCreateStatus: taskCreateStatus ?? this.taskCreateStatus,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
    projects,
    checkers,
    makers,
    pcEngineers,
    selectedProject,
    selectedChecker,
    selectedMaker,
    selectedPcEngineer,
    taskDescription,
    tentativeDate,
    remark,
    selectedFiles,
    projectListLoading,
    checkerListLoading,
    makerListLoading,
    pcEngineerListLoading,
    taskCreateStatus,
    errorMessage,
    successMessage,
  ];
}
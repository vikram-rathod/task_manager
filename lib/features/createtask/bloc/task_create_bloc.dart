import 'dart:io';
import 'package:dio/src/multipart_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:task_manager/features/createtask/bloc/taskcreate_event.dart';
import 'package:task_manager/features/createtask/bloc/taskcreate_state.dart';

import '../../home/repository/home_repository.dart';
import '../../home/repository/task_repository.dart';
import '../../utils/app_exception.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  final HomeRepository homeRepository;
  final TaskRepository tasksRepository;

  CreateTaskBloc(
      this.tasksRepository,
      this.homeRepository,
      ) : super(const CreateTaskState()) {
    on<LoadProjectList>(_onLoadProjectList);
    on<ProjectSelected>(_onProjectSelected);
    on<ProjectCleared>(_onProjectCleared);
    on<CheckerSelected>(_onCheckerSelected);
    on<CheckerCleared>(_onCheckerCleared);
    on<MakerSelected>(_onMakerSelected);
    on<MakerCleared>(_onMakerCleared);
    on<PcEngineerSelected>(_onPcEngineerSelected);
    on<PcEngineerCleared>(_onPcEngineerCleared);
    on<TaskDescriptionChanged>(_onTaskDescriptionChanged);
    on<TentativeDateChanged>(_onTentativeDateChanged);
    on<RemarkChanged>(_onRemarkChanged);
    on<AttachmentPickerOpened>(_onAttachmentPickerOpened);
    on<PickFromCameraRequested>(_onPickFromCameraRequested);
    on<PickFromGalleryRequested>(_onPickFromGalleryRequested);
    on<PickDocumentsRequested>(_onPickDocumentsRequested);
    on<AttachmentAdded>(_onAttachmentAdded);
    on<AttachmentRemoved>(_onAttachmentRemoved);
    on<CreateTaskSubmitted>(_onCreateTaskSubmitted);
    on<ResetCreateTaskState>(_onResetCreateTaskState);
    on<ClearError>(_onClearError);
  }

  Future<void> _onLoadProjectList(
      LoadProjectList event,
      Emitter<CreateTaskState> emit,
      ) async {
    emit(state.copyWith(projectListLoading: true, errorMessage: null));
    try {
      final projects = await homeRepository.getProjectsList();
      debugPrint('[CreateTask] Loaded ${projects.length} projects');
      emit(state.copyWith(
        projects: projects,
        projectListLoading: false,
      ));
    } catch (e, stackTrace) {
      debugPrint('[CreateTask][ERROR] Failed to load projects: $e');
      debugPrint('StackTrace: $stackTrace');
      final exception = AppExceptionMapper.from(e);
      emit(state.copyWith(
        projectListLoading: false,
        errorMessage : exception.message,
      ));
    }
  }

  Future<void> _onProjectSelected(
      ProjectSelected event,
      Emitter<CreateTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedProject: event.project,
      checkerListLoading: true,
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      makers: [],
      pcEngineers: [],
      errorMessage: null,
    ));

    try {
      final checkers = await homeRepository.getTaskManagerUserList(
        projectId: event.project.projectId.toString(),
      );
      debugPrint('[CreateTask] Loaded ${checkers.length} checkers for project ${event.project.projectName}');
      emit(state.copyWith(
        checkers: checkers,
        checkerListLoading: false,
      ));
    } catch (e, stackTrace) {
      debugPrint('[CreateTask][ERROR] Failed to load checkers: $e');
      debugPrint('StackTrace: $stackTrace');
      final exception = AppExceptionMapper.from(e);
      emit(state.copyWith(
        checkerListLoading: false,
        errorMessage:  exception.message,
      ));
    }
  }

  void _onProjectCleared(ProjectCleared event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(
      clearSelectedProject: true,
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      checkers: [],
      makers: [],
      pcEngineers: [],
      errorMessage: null,
    ));
  }

  Future<void> _onCheckerSelected(
      CheckerSelected event,
      Emitter<CreateTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedChecker: event.checker,
      makerListLoading: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      pcEngineers: [],
      errorMessage: null,
    ));

    try {
      final makers = await homeRepository.getTaskManagerUserList(
        projectId: state.selectedProject!.projectId.toString(),
      );
      debugPrint('[CreateTask] Loaded ${makers.length} makers for checker ${event.checker.userName}');
      emit(state.copyWith(
        makers: makers,
        makerListLoading: false,
      ));
    } catch (e, stackTrace) {
      debugPrint('[CreateTask][ERROR] Failed to load makers: $e');
      debugPrint('StackTrace: $stackTrace');
      final exception = AppExceptionMapper.from(e);
      emit(state.copyWith(
        makerListLoading: false,
        errorMessage : exception.message,
      ));
    }
  }

  void _onCheckerCleared(CheckerCleared event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(
      clearSelectedChecker: true,
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      makers: [],
      pcEngineers: [],
      errorMessage: null,
    ));
  }

  Future<void> _onMakerSelected(
      MakerSelected event,
      Emitter<CreateTaskState> emit,
      ) async {
    emit(state.copyWith(
      selectedMaker: event.maker,
      pcEngineerListLoading: true,
      clearSelectedPcEngineer: true,
      errorMessage: null,
    ));

    try {
      final pcEngineers = await homeRepository.getProjectCoordinatorUserList(
        projectId: state.selectedProject!.projectId.toString(),
      );
      debugPrint('[CreateTask] Loaded ${pcEngineers.length} PC engineers for maker ${event.maker.userName}');
      emit(state.copyWith(
        pcEngineers: pcEngineers,
        pcEngineerListLoading: false,
      ));
    } catch (e, stackTrace) {
      debugPrint('[CreateTask][ERROR] Failed to load PC engineers: $e');
      debugPrint('StackTrace: $stackTrace');
      final exception = AppExceptionMapper.from(e);
      emit(state.copyWith(
        pcEngineerListLoading: false,
        errorMessage: exception.message,
      ));
    }
  }

  void _onMakerCleared(MakerCleared event, Emitter<CreateTaskState> emit) {
    emit(state.copyWith(
      clearSelectedMaker: true,
      clearSelectedPcEngineer: true,
      pcEngineers: [],
      errorMessage: null,
    ));
  }

  void _onPcEngineerSelected(
      PcEngineerSelected event,
      Emitter<CreateTaskState> emit,
      ) {
    emit(state.copyWith(selectedPcEngineer: event.engineer, errorMessage: null));
  }

  void _onPcEngineerCleared(
      PcEngineerCleared event,
      Emitter<CreateTaskState> emit,
      ) {
    emit(state.copyWith(clearSelectedPcEngineer: true, errorMessage: null));
  }

  void _onTaskDescriptionChanged(
      TaskDescriptionChanged event,
      Emitter<CreateTaskState> emit,
      ) {
    emit(state.copyWith(taskDescription: event.description));
  }

  void _onTentativeDateChanged(
      TentativeDateChanged event,
      Emitter<CreateTaskState> emit,
      ) {
    emit(state.copyWith(tentativeDate: event.date));
  }

  void _onRemarkChanged(
      RemarkChanged event,
      Emitter<CreateTaskState> emit,
      ) {
    emit(state.copyWith(remark: event.remark));
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _onPickFromCameraRequested(
      PickFromCameraRequested event,
      Emitter<CreateTaskState> emit,
      ) async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        emit(state.copyWith(errorMessage: 'Camera permission denied'));
        return;
      }

      final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        add(AttachmentAdded([file]));
      } else {
        emit(state.copyWith(errorMessage: 'No image selected from camera'));
      }
    } catch (e) {

      emit(state.copyWith(errorMessage: 'Failed to pick image from camera'));
    }
  }

  Future<void> _onPickFromGalleryRequested(
      PickFromGalleryRequested event,
      Emitter<CreateTaskState> emit,
      ) async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        final files = pickedFiles.map((xfile) => File(xfile.path)).toList();
        add(AttachmentAdded(files));
      } else {
        emit(state.copyWith(errorMessage: 'No images selected from gallery'));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick images from gallery'));
    }
  }



  Future<void> _onPickDocumentsRequested(
      PickDocumentsRequested event,
      Emitter<CreateTaskState> emit,
      ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();
        add(AttachmentAdded(files));
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to pick documents'));
    }
  }

  void _onAttachmentAdded(
      AttachmentAdded event,
      Emitter<CreateTaskState> emit,
      ) {
    final updatedFiles = [...state.selectedFiles, ...event.files];
    emit(state.copyWith(selectedFiles: updatedFiles));
  }


  Future<void> _onAttachmentPickerOpened(
      AttachmentPickerOpened event,
      Emitter<CreateTaskState> emit,
      ) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        if (files.isNotEmpty) {
          add(AttachmentAdded(files));
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[CreateTask][ERROR] Failed to pick files: $e');
      debugPrint('StackTrace: $stackTrace');
      final exception = AppExceptionMapper.from(e);
      emit(state.copyWith(
        errorMessage: exception.message,
      ));
    }
  }

  void _onAttachmentRemoved(
      AttachmentRemoved event,
      Emitter<CreateTaskState> emit,
      ) {
    final updatedFiles = state.selectedFiles
        .where((file) => file.path != event.file.path)
        .toList();
    debugPrint('[CreateTask] Removed file. Remaining: ${updatedFiles.length}');
    emit(state.copyWith(selectedFiles: updatedFiles));
  }

  Future<void> _onCreateTaskSubmitted(
      CreateTaskSubmitted event,
      Emitter<CreateTaskState> emit,
      ) async {
    debugPrint('[CreateTask] Submit clicked');

    // Clear any previous errors
    emit(state.copyWith(errorMessage: null));

    // Validation
    if (state.selectedProject == null) {
      debugPrint('[CreateTask][ERROR] Project not selected');
      emit(state.copyWith(
        taskCreateStatus: TaskCreateStatus.error,
        errorMessage: 'Please select a project',
      ));
      return;
    }

    if (state.taskDescription.trim().isEmpty) {
      debugPrint('[CreateTask][ERROR] Task description empty');
      emit(state.copyWith(
        taskCreateStatus: TaskCreateStatus.error,
        errorMessage: 'Please enter task description',
      ));
      return;
    }

    debugPrint('[CreateTask] Validation passed');
    emit(state.copyWith(taskCreateStatus: TaskCreateStatus.loading));

    try {
      // Log request payload
      debugPrint('[CreateTask] Creating task with payload:');
      debugPrint('  ProjectId : ${state.selectedProject!.projectId}');
      debugPrint('  MakerId   : ${state.selectedMaker?.userId}');
      debugPrint('  CheckerId : ${state.selectedChecker?.userId}');
      debugPrint('  PcEnggId  : ${state.selectedPcEngineer?.userId}');
      debugPrint('  Date      : ${state.tentativeDate.toYyyyMmDd()}');
      debugPrint('  Remark    : ${state.remark}');
      debugPrint('  Files     : ${state.selectedFiles.length}');

      final response = await tasksRepository.createTask(
        makerId: state.selectedMaker?.userId,
        checkerId: state.selectedChecker?.userId,
        pcEngrId: state.selectedPcEngineer?.userId,
        taskDesc: state.taskDescription,
        projectId: state.selectedProject?.projectId,
        tentativeDate: state.tentativeDate.toYyyyMmDd(),
        remark: state.remark,
        files: state.selectedFiles.toMultilpart(),
      );

      debugPrint('[CreateTask] API call success: $response');

      emit(state.copyWith(
        taskCreateStatus: TaskCreateStatus.success,
        successMessage: 'Task created successfully',
      ));

      debugPrint('[CreateTask] Task created successfully');
    } catch (e, stackTrace) {
      debugPrint('[CreateTask][ERROR] Task creation failed');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
      final exception = AppExceptionMapper.from(e);

      emit(state.copyWith(
        taskCreateStatus: TaskCreateStatus.error,
        errorMessage:  exception.message,
      ));
    }
  }

  void _onResetCreateTaskState(
      ResetCreateTaskState event,
      Emitter<CreateTaskState> emit,
      ) {
    debugPrint('[CreateTask] Resetting state');
    emit(const CreateTaskState());
  }

  void _onClearError(
      ClearError event,
      Emitter<CreateTaskState> emit,
      ) {
    emit(state.copyWith(errorMessage: null, taskCreateStatus: TaskCreateStatus.idle));
  }

}

extension DateTimeX on DateTime? {
  String? toYyyyMmDd() {
    if (this == null) return null;

    final d = this!;
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year.toString().padLeft(4, '0')}';
  }
}

extension on List<File> {
  List<MultipartFile>? toMultilpart() {
    if (isEmpty) return null;
    return map((file) => MultipartFile.fromFileSync(file.path)).toList();
  }
}
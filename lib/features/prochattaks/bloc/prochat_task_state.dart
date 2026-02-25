part of 'prochat_task_bloc.dart';

enum ProchatAssignStatus { idle, loading, success, error }

class ProchatTaskState extends Equatable {
  // ── Task list ──────────────────────────────────────────────────────────────
  final bool isLoading;
  final bool isRefreshing;
  final bool isError;
  final List<TMTasksModel> tasks;
  final String errorMessage;

  // ── Assign / Transfer ──────────────────────────────────────────────────────
  final List<ProjectModel> projects;
  final List<UserModel> checkers;
  final List<UserModel> makers;
  final List<UserModel> pcEngineers;

  final ProjectModel? selectedProject;
  final UserModel? selectedChecker;
  final UserModel? selectedMaker;
  final UserModel? selectedPcEngineer;

  final bool projectListLoading;
  final bool checkerListLoading;
  final bool makerListLoading;
  final bool pcEngineerListLoading;

  final ProchatAssignStatus assignStatus;
  final String assignErrorMessage;


  final bool isSyncing;
  final bool hasNewTasksToSync;

  final bool isHighAuthority;
  final int loginUserId;


  const ProchatTaskState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.isError = false,
    this.tasks = const [],
    this.errorMessage = '',
    this.projects = const [],
    this.checkers = const [],
    this.makers = const [],
    this.pcEngineers = const [],
    this.selectedProject,
    this.selectedChecker,
    this.selectedMaker,
    this.selectedPcEngineer,
    this.projectListLoading = false,
    this.checkerListLoading = false,
    this.makerListLoading = false,
    this.pcEngineerListLoading = false,
    this.assignStatus = ProchatAssignStatus.idle,
    this.assignErrorMessage = '',
    this.isSyncing = false,
    this.hasNewTasksToSync = false,

    this.isHighAuthority = false,
    this.loginUserId = 0,

  });

  bool get isEmpty => !isLoading && !isError && tasks.isEmpty;
  bool get hasData => tasks.isNotEmpty;

  bool get isAssignFormValid => selectedProject != null;

  ProchatTaskState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    bool? isError,
    List<TMTasksModel>? tasks,
    String? errorMessage,
    List<ProjectModel>? projects,
    List<UserModel>? checkers,
    List<UserModel>? makers,
    List<UserModel>? pcEngineers,
    ProjectModel? selectedProject,
    UserModel? selectedChecker,
    UserModel? selectedMaker,
    UserModel? selectedPcEngineer,
    bool? projectListLoading,
    bool? checkerListLoading,
    bool? makerListLoading,
    bool? pcEngineerListLoading,
    ProchatAssignStatus? assignStatus,
    String? assignErrorMessage,
    // null-clear flags
    bool clearSelectedProject = false,
    bool clearSelectedChecker = false,
    bool clearSelectedMaker = false,
    bool clearSelectedPcEngineer = false,
    bool? isSyncing,
    bool? hasNewTasksToSync,
    bool? isHighAuthority,
    int? loginUserId,
  }) {
    return ProchatTaskState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isError: isError ?? this.isError,
      tasks: tasks ?? this.tasks,
      errorMessage: errorMessage ?? this.errorMessage,
      projects: projects ?? this.projects,
      checkers: checkers ?? this.checkers,
      makers: makers ?? this.makers,
      pcEngineers: pcEngineers ?? this.pcEngineers,
      selectedProject:
      clearSelectedProject ? null : (selectedProject ?? this.selectedProject),
      selectedChecker:
      clearSelectedChecker ? null : (selectedChecker ?? this.selectedChecker),
      selectedMaker:
      clearSelectedMaker ? null : (selectedMaker ?? this.selectedMaker),
      selectedPcEngineer:
      clearSelectedPcEngineer ? null : (selectedPcEngineer ?? this.selectedPcEngineer),
      projectListLoading: projectListLoading ?? this.projectListLoading,
      checkerListLoading: checkerListLoading ?? this.checkerListLoading,
      makerListLoading: makerListLoading ?? this.makerListLoading,
      pcEngineerListLoading: pcEngineerListLoading ?? this.pcEngineerListLoading,
      assignStatus: assignStatus ?? this.assignStatus,
      assignErrorMessage: assignErrorMessage ?? this.assignErrorMessage,
      isSyncing: isSyncing ?? this.isSyncing,
      hasNewTasksToSync: hasNewTasksToSync ?? this.hasNewTasksToSync,
      isHighAuthority: isHighAuthority ?? this.isHighAuthority,
      loginUserId: loginUserId ?? this.loginUserId,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isRefreshing,
    isError,
    tasks,
    errorMessage,
    projects,
    checkers,
    makers,
    pcEngineers,
    selectedProject,
    selectedChecker,
    selectedMaker,
    selectedPcEngineer,
    projectListLoading,
    checkerListLoading,
    makerListLoading,
    pcEngineerListLoading,
    assignStatus,
    assignErrorMessage,
    isSyncing,
    hasNewTasksToSync,
    isHighAuthority,
    loginUserId,
  ];
}
part of 'prochat_task_bloc.dart';

abstract class ProchatTaskEvent extends Equatable {
  const ProchatTaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserRole extends ProchatTaskEvent {
  const LoadUserRole();
}


// ── Task list ──────────────────────────────────────────────────────────────

class ProchatTaskFetched extends ProchatTaskEvent {
  const ProchatTaskFetched();
}

class ProchatTaskRefreshed extends ProchatTaskEvent {
  const ProchatTaskRefreshed();
}

class ResetProchatTask extends ProchatTaskEvent {
  const ResetProchatTask();
}

// ── Assign flow — project ──────────────────────────────────────────────────

class ProchatLoadProjectList extends ProchatTaskEvent {
  final TMTasksModel? task;

  const ProchatLoadProjectList({this.task});

  @override
  List<Object?> get props => [task];
}

class ProchatProjectSelected extends ProchatTaskEvent {
  final ProjectModel project;

  const ProchatProjectSelected(this.project);

  @override
  List<Object?> get props => [project];
}

class ProchatProjectCleared extends ProchatTaskEvent {
  const ProchatProjectCleared();
}

// ── Assign flow — checker ──────────────────────────────────────────────────

class ProchatCheckerSelected extends ProchatTaskEvent {
  final UserModel checker;

  const ProchatCheckerSelected(this.checker);

  @override
  List<Object?> get props => [checker];
}

class ProchatCheckerCleared extends ProchatTaskEvent {
  const ProchatCheckerCleared();
}

// ── Assign flow — maker ────────────────────────────────────────────────────

class ProchatMakerSelected extends ProchatTaskEvent {
  final UserModel maker;

  const ProchatMakerSelected(this.maker);

  @override
  List<Object?> get props => [maker];
}

class ProchatMakerCleared extends ProchatTaskEvent {
  const ProchatMakerCleared();
}

// ── Assign flow — Planner/Coordinator ──────────────────────────────────────────────

class ProchatPcEngineerSelected extends ProchatTaskEvent {
  final UserModel engineer;

  const ProchatPcEngineerSelected(this.engineer);

  @override
  List<Object?> get props => [engineer];
}

class ProchatPcEngineerCleared extends ProchatTaskEvent {
  const ProchatPcEngineerCleared();
}

// ── Assign flow — submit & reset ───────────────────────────────────────────

class ProchatAssignTaskSubmitted extends ProchatTaskEvent {
  final TMTasksModel task;

  const ProchatAssignTaskSubmitted(this.task);

  @override
  List<Object?> get props => [task];
}

class ProchatAssignReset extends ProchatTaskEvent {
  const ProchatAssignReset();
}

class ProchatAssignPreselect extends ProchatTaskEvent {
  final TMTasksModel task;

  const ProchatAssignPreselect(this.task);

  @override
  List<Object?> get props => [task];
}

class ProchatTaskSyncCheck extends ProchatTaskEvent {
  const ProchatTaskSyncCheck();
}

class ProchatSyncAndReload extends ProchatTaskEvent {
  const ProchatSyncAndReload();
}

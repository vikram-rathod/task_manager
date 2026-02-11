import 'package:equatable/equatable.dart';
import 'package:task_manager/features/home/model/employee_count_model.dart';
import 'package:task_manager/features/home/model/project_count_model.dart';

import '../model/quick_action_model.dart';
import '../model/task_history_model.dart';

class HomeState extends Equatable {

// Quick actions
  final bool isQuickActionsLoading;
  final List<QuickActionModel> quickActions;
  final String? quickActionsError;


  // projects
  final bool isProjectsLoading;
  final List<ProjectCountModel> projects;
  final String? projectsError;

  // employee wise task list
  final bool isEmployeeWiseTaskListLoading;
  final List<EmployeeModel> employeeWiseTaskList;
  final String? employeeWiseTaskListError;


  // Task history
  final bool isTaskHistoryLoading;
  final List<TaskHistoryModel> taskHistory;
  final String? taskHistoryError;


  const HomeState({

    //quick actions
    this.isQuickActionsLoading = false,
    this.quickActions = const [],
    this.quickActionsError,

    // Projects
    this.isProjectsLoading = false,
    this.projects = const [],
    this.projectsError,

    // employee wise task list
    this.isEmployeeWiseTaskListLoading = false,
    this.employeeWiseTaskList = const [],
    this.employeeWiseTaskListError,

    // Task history
    this.isTaskHistoryLoading = false,
    this.taskHistory = const [],
    this.taskHistoryError,
  });

  HomeState copyWith({

    //quick actions
    bool? isQuickActionsLoading,
    List<QuickActionModel>? quickActions,
    String? quickActionsError,

    // Projects
    bool? isProjectsLoading,
    List<ProjectCountModel>? projects,
    String? projectsError,

    // employee wise task list
    bool? isEmployeeWiseTaskListLoading,
    List<EmployeeModel>? employeeWiseTaskList,
    String? employeeWiseTaskListError,

    bool? isTaskHistoryLoading,
    List<TaskHistoryModel>? taskHistory,
    String? taskHistoryError,
  }) {
    return HomeState(

      isQuickActionsLoading: isQuickActionsLoading ?? this.isQuickActionsLoading,
      quickActions: quickActions ?? this.quickActions,
      quickActionsError: quickActionsError,

      isProjectsLoading: isProjectsLoading ?? this.isProjectsLoading,
      projects: projects ?? this.projects,
      projectsError: projectsError,

      isEmployeeWiseTaskListLoading: isEmployeeWiseTaskListLoading ?? this.isEmployeeWiseTaskListLoading,
      employeeWiseTaskList: employeeWiseTaskList ?? this.employeeWiseTaskList,
      employeeWiseTaskListError: employeeWiseTaskListError,

      isTaskHistoryLoading: isTaskHistoryLoading ?? this.isTaskHistoryLoading,
      taskHistory: taskHistory ?? this.taskHistory,
      taskHistoryError: taskHistoryError,
    );
  }

  @override
  List<Object?> get props => [
    isQuickActionsLoading,
    quickActions,
    quickActionsError,
    isTaskHistoryLoading,
    taskHistory,
    taskHistoryError,
    isProjectsLoading,
    projects,
    projectsError,
    isEmployeeWiseTaskListLoading,
    employeeWiseTaskList,
    employeeWiseTaskListError,
  ];
}

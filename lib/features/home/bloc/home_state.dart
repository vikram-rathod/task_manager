import 'package:equatable/equatable.dart';
import 'package:task_manager/features/home/model/employee_count_model.dart';
import 'package:task_manager/features/home/model/project_count_model.dart';

import '../../../core/models/task_model.dart';
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

  // Today's Tasks - My Tasks
  final bool isMyTasksLoading;
  final List<TMTasksModel> myTasks;
  final String? myTasksError;
  final int myTasksPage;
  final bool hasMoreMyTasks;

  // Today's Tasks - Other Tasks
  final bool isOtherTasksLoading;
  final List<TMTasksModel> otherTasks;
  final String? otherTasksError;
  final int otherTasksPage;
  final bool hasMoreOtherTasks;

  final int notificationCount;


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

    // Today's Tasks - My Tasks
    this.isMyTasksLoading = false,
    this.myTasks = const [],
    this.myTasksError,
    this.myTasksPage = 1,
    this.hasMoreMyTasks = true,

    // Today's Tasks - Other Tasks
    this.isOtherTasksLoading = false,
    this.otherTasks = const [],
    this.otherTasksError,
    this.otherTasksPage = 1,
    this.hasMoreOtherTasks = true,
    this.notificationCount = 0,

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


    // Today's Tasks - My Tasks
    bool? isMyTasksLoading,
    List<TMTasksModel>? myTasks,
    String? myTasksError,
    int? myTasksPage,
    bool? hasMoreMyTasks,

    // Today's Tasks - Other Tasks
    bool? isOtherTasksLoading,
    List<TMTasksModel>? otherTasks,
    String? otherTasksError,
    int? otherTasksPage,
    bool? hasMoreOtherTasks,

    int? notificationCount,

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

      isMyTasksLoading: isMyTasksLoading ?? this.isMyTasksLoading,
      myTasks: myTasks ?? this.myTasks,
      myTasksError: myTasksError,
      myTasksPage: myTasksPage ?? this.myTasksPage,
      hasMoreMyTasks: hasMoreMyTasks ?? this.hasMoreMyTasks,

      isOtherTasksLoading: isOtherTasksLoading ?? this.isOtherTasksLoading,
      otherTasks: otherTasks ?? this.otherTasks,
      otherTasksError: otherTasksError,
      otherTasksPage: otherTasksPage ?? this.otherTasksPage,
      hasMoreOtherTasks: hasMoreOtherTasks ?? this.hasMoreOtherTasks,
      notificationCount: notificationCount ?? this.notificationCount,
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
    isMyTasksLoading,
    myTasks,
    myTasksError,
    myTasksPage,
    hasMoreMyTasks,
    isOtherTasksLoading,
    otherTasks,
    otherTasksError,
    otherTasksPage,
    hasMoreOtherTasks,
    notificationCount,
  ];
}

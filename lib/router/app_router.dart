import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/core/models/task_model.dart';
import 'package:task_manager/features/createtask/screen/create_task_screen.dart';
import 'package:task_manager/features/home/model/project_count_model.dart';
import 'package:task_manager/features/home/model/quick_action_model.dart';
import 'package:task_manager/features/modulenotification/ui/module_notification_screen.dart';
import 'package:task_manager/features/overdue/ui/over_due_task_screen.dart';
import 'package:task_manager/features/prochattaks/prochat_task_screen.dart';
import 'package:task_manager/features/projecttasks/ui/projects_task_screen.dart';
import 'package:task_manager/features/taskChat/ui/screens/task_chat_screen.dart';

import '../core/di/injection_container.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/duetodaytasks/ui/due_today_task_screen.dart';
import '../features/employeetasks/screens/employee_task_screen.dart';
import '../features/home/model/employee_count_model.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/profile_page.dart';
import '../features/projecttasks/bloc/project_wise_task_bloc.dart';
import '../features/task_details/ui/task_details_screen.dart';
import '../my_app.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const AuthWrapper());

      case '/login':
        return MaterialPageRoute(builder: (_) =>  LoginScreen());

      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case '/profile' :
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case '/createTask':
        return MaterialPageRoute(builder: (_) => const CreateTaskScreen());

      case '/taskDetails':
        final taskModel = settings.arguments as TMTasksModel;
        return MaterialPageRoute(
          builder: (_) => TaskDetailsScreen(taskModel: taskModel),
        );

      case '/employeeTask':
        final employee = settings.arguments as EmployeeModel;
        return MaterialPageRoute(
          builder: (_) => EmployeeTaskScreen(employee: employee),
        );

      case '/project-details':
        final projectCountModel = settings.arguments as ProjectCountModel;

        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => ProjectWiseTaskBloc(
              tasksRepository: sl(),
              homeRepository: sl(),
              storageService: sl(),
            ),
            child: ProjectWiseTaskScreen(
              projectCountModel: projectCountModel,
            ),
          ),
        );

      case '/overdue':
        final action = settings.arguments as QuickActionModel;

        return MaterialPageRoute(
          builder: (_) => OverDueTaskScreen(action: action),
        );

      case '/dueToday':
        final action = settings.arguments as QuickActionModel;
        return MaterialPageRoute(
          builder: (_) => DueTodayTaskScreen(action: action),
        );

      case '/prochat':
        final quickActionModel = settings.arguments as QuickActionModel;
        return MaterialPageRoute(builder: (_) => ProChatTaskScreen(quickActionModel: quickActionModel));

      case '/taskChat':
        final task = settings.arguments as TMTasksModel;
        return MaterialPageRoute(builder: (_) => TaskChatScreen(task: task));

      case '/notifications':
        // final quickActionModel = settings.arguments as QuickActionModel;
        return MaterialPageRoute(builder: (_) => ModuleNotificationScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}


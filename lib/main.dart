import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/features/employeetasks/bloc/employee_task_bloc.dart';
import 'package:task_manager/features/home/bloc/home_bloc.dart';
import 'package:task_manager/features/modulenotification/bloc/module_notification_bloc.dart';
import 'package:task_manager/features/prochattaks/bloc/prochat_task_bloc.dart';
import 'package:task_manager/features/taskChat/bloc/task_chat_bloc.dart';

import 'core/di/injection_container.dart';
import 'core/theme/theme_cubit.dart';
import 'features/AllTasks/bloc/all_task_bloc.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/createtask/bloc/task_create_bloc.dart';
import 'features/duetodaytasks/bloc/due_today_bloc.dart';
import 'features/overdue/bloc/over_due_bloc.dart';
import 'features/profile/bloc/profile_bloc.dart';
import 'features/task_details/bloc/task_details_bloc.dart';
import 'firebase_options.dart';
import 'my_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthBloc>()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider.value(value: CreateTaskBloc(sl(), sl())),
        BlocProvider.value(value: AllTaskBloc(sl(), sl())),
        BlocProvider.value(value: HomeBloc(sl())),
        BlocProvider.value(value: EmployeeTaskBloc(sl(), sl())),
        BlocProvider.value(value: OverDueBloc(sl(), sl())),
        BlocProvider.value(value: DueTodayBloc(sl(), sl())),
        BlocProvider.value(value: TaskDetailsBloc(sl(), sl())),
        BlocProvider.value(value: TaskChatBloc(sl(),sl())),
        BlocProvider.value(value: ProchatTaskBloc(sl(),sl(),sl())),
        BlocProvider.value(value: ModuleNotificationBloc(sl(),sl())),
        BlocProvider.value(value: ProfileBloc(sl())),
      ],
      child: const MyApp(),
    ),
  );
}


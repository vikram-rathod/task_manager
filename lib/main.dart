import 'package:task_manager/features/home/bloc/home_bloc.dart';

import 'features/AllTasks/bloc/all_task_bloc.dart';
import 'features/createtask/bloc/task_create_bloc.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection_container.dart';

import 'core/theme/theme_cubit.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';

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
        BlocProvider.value(value: HomeBloc(sl()))
      ],
      child: const MyApp(),
    ),
  );
}


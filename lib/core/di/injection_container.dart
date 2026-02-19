import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/features/AllTasks/bloc/all_task_bloc.dart';
import 'package:task_manager/features/createtask/bloc/task_create_bloc.dart';
import 'package:task_manager/features/employeetasks/bloc/employee_task_bloc.dart';
import 'package:task_manager/features/home/bloc/home_bloc.dart';
import 'package:task_manager/features/modulenotification/app_notification_repository.dart';
import 'package:task_manager/features/home/repository/task_repository.dart';
import 'package:task_manager/features/modulenotification/app_notification_service.dart';
import 'package:task_manager/features/home/services/home_service.dart';
import 'package:task_manager/features/task/service/task_list_service.dart';
import 'package:task_manager/features/modulenotification/bloc/module_notification_bloc.dart';
import 'package:task_manager/features/prochattaks/bloc/prochat_task_bloc.dart';
import 'package:task_manager/features/prochattaks/repository/prochat_task_repository.dart';
import 'package:task_manager/features/taskChat/bloc/task_chat_bloc.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/createtask/services/task_service.dart';
import '../../features/duetodaytasks/bloc/due_today_bloc.dart';
import '../../features/home/repository/home_repository.dart';
import '../../features/task/bloc/task_list_bloc.dart';
import '../../features/task/repository/task_list_repository.dart';
import '../../features/template/bloc/template_bloc.dart';
import '../../features/template/repository/template_repository.dart';
import '../../features/template/service/template_service.dart';
import '../../features/overdue/bloc/over_due_bloc.dart';
import '../../features/prochattaks/repository/prochat_service.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/task_details/bloc/task_details_bloc.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';
import '../storage/storage_service.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ======================================================
  //  External Dependencies
  // ======================================================

  const secureStorageOptions = AndroidOptions();

  final flutterSecureStorage = FlutterSecureStorage(
    aOptions: secureStorageOptions,
  );

  sl.registerLazySingleton<FlutterSecureStorage>(
        () => flutterSecureStorage,
  );

  // ======================================================
  //  Core Layer
  // ======================================================

  // Storage
  sl.registerLazySingleton<StorageService>(
        () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  // Network
  sl.registerLazySingleton<DioClient>(
        () => DioClient(),
  );

  // ======================================================
  //  Auth Feature
  // ======================================================

  // Repository
  sl.registerLazySingleton<AuthRepository>(
        () =>
        AuthRepository(
      sl<DioClient>(),
      sl<StorageService>(),
    ),
  );

  // Bloc
  sl.registerFactory<AuthBloc>(
        () =>
        AuthBloc(
          sl<AuthRepository>(),
        ),
  );

  // ======================================================
  //  Home Feature
  // ======================================================

  // API Service
  sl.registerLazySingleton<HomeApiService>(
        () =>
        HomeApiService(
          sl<DioClient>(),
        ),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
        () =>
        HomeRepository(
          sl<HomeApiService>(), sl<StorageService>(),
        ),
  );

  // ======================================================
  // Create Task Feature
  // ======================================================

  // API Service
  sl.registerLazySingleton<TaskApiService>(
        () =>
        TaskApiService(
          sl<DioClient>(),
          sl<StorageService>(),
        ),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
        () =>
        TaskRepository(
          sl<TaskApiService>(),
        ),
  );

  // Bloc
  sl.registerFactory<CreateTaskBloc>(
        () =>
        CreateTaskBloc(
          sl<TaskRepository>(),
          sl<HomeRepository>(),
        ),
  );

  sl.registerFactory<AllTaskBloc>(
        () =>
        AllTaskBloc(
          sl<TaskRepository>(),
          sl<StorageService>(),
        ),
  );
  sl.registerFactory<HomeBloc>(
        () =>
        HomeBloc(
          sl<HomeRepository>(),
        ),
  );

// ======================================================
// Task List Feature
// ======================================================

// Service
  sl.registerLazySingleton<TaskListService>(
        () => TaskListService(
      sl<DioClient>(),
    ),
  );

// Repository
  sl.registerLazySingleton<TaskListRepository>(
        () => TaskListRepository(
      sl<TaskListService>(),
      sl<StorageService>(),
    ),
  );

// Bloc
  sl.registerFactory<TaskListBloc>(
        () => TaskListBloc(
      sl<TaskListRepository>(),
      sl<TaskListService>(),
      sl<StorageService>(),
    ),
  );




  sl.registerLazySingleton<TemplateService>(
        () => TemplateService(
      sl<DioClient>(),   // ✅ Only DioClient
    ),
  );

  sl.registerLazySingleton<TemplateRepository>(
        () => TemplateRepository(
      sl<TemplateService>(),  // ✅ Service
      sl<StorageService>(),   // ✅ StorageService REQUIRED
    ),
  );

  sl.registerFactory<TemplateBloc>(
        () => TemplateBloc(
      sl<TemplateRepository>(),
    ),
  );


  sl.registerLazySingleton<AppNotificationService>(
    () => AppNotificationService(sl<DioClient>()),
  );

  sl.registerLazySingleton<AppNotificationRepository>(
    () => AppNotificationRepository(sl<AppNotificationService>()),
  );

  sl.registerLazySingleton<ModuleNotificationBloc>(() =>
      ModuleNotificationBloc(
          sl<AppNotificationRepository>(), sl<StorageService>()));

  sl.registerLazySingleton<ProChatService>(() => ProChatService(sl<DioClient>()));

  sl.registerLazySingleton<ProchatTaskRepository>(() => ProchatTaskRepository(sl<ProChatService>()));

  sl.registerLazySingleton<ProchatTaskBloc>(() =>
      ProchatTaskBloc(sl<ProchatTaskRepository>(), sl<HomeRepository>(),
          sl<StorageService>()));

  sl.registerLazySingleton<ProfileBloc>(() =>
      ProfileBloc(sl<StorageService>()));


}

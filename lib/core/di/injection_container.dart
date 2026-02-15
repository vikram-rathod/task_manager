import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/features/AllTasks/bloc/all_task_bloc.dart';
import 'package:task_manager/features/createtask/bloc/task_create_bloc.dart';
import 'package:task_manager/features/employeetasks/bloc/employee_task_bloc.dart';
import 'package:task_manager/features/home/bloc/home_bloc.dart';
import 'package:task_manager/features/home/repository/app_notification_repository.dart';
import 'package:task_manager/features/home/repository/prochat_task_repository.dart';
import 'package:task_manager/features/home/repository/task_repository.dart';
import 'package:task_manager/features/home/services/app_notification_service.dart';
import 'package:task_manager/features/home/services/home_service.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/createtask/services/task_service.dart';
import '../../features/duetodaytasks/bloc/due_today_bloc.dart';
import '../../features/home/repository/home_repository.dart';
import '../../features/home/services/prochat_service.dart';
import '../../features/overdue/bloc/over_due_bloc.dart';
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

  sl.registerLazySingleton<FlutterSecureStorage>(() => flutterSecureStorage);

  // ======================================================
  //  Core Layer
  // ======================================================

  // Storage
  sl.registerLazySingleton<StorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );

  // Network
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ======================================================
  //  Auth Feature
  // ======================================================

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<DioClient>(), sl<StorageService>()),
  );

  // Bloc
  sl.registerFactory<AuthBloc>(() => AuthBloc(sl<AuthRepository>()));

  // ======================================================
  //  Home Feature
  // ======================================================

  // API Service
  sl.registerLazySingleton<HomeApiService>(
    () => HomeApiService(sl<DioClient>()),
  );

  // Repository
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepository(sl<HomeApiService>(), sl<StorageService>()),
  );

  // ======================================================
  // Create Task Feature
  // ======================================================

  // API Service
  sl.registerLazySingleton<TaskApiService>(
    () => TaskApiService(sl<DioClient>(), sl<StorageService>()),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepository(sl<TaskApiService>()),
  );

  // Bloc
  sl.registerLazySingleton<CreateTaskBloc>(
    () => CreateTaskBloc(sl<TaskRepository>(), sl<HomeRepository>()),
  );

  sl.registerLazySingleton<AllTaskBloc>(
    () => AllTaskBloc(sl<TaskRepository>(), sl<StorageService>()),
  );
  sl.registerLazySingleton<HomeBloc>(() => HomeBloc(sl<HomeRepository>()));

  sl.registerLazySingleton<EmployeeTaskBloc>(
    () => EmployeeTaskBloc(sl<TaskRepository>(), sl<StorageService>()),
  );
  // ======================================================
  //  OverDue Feature
  // ======================================================
  sl.registerLazySingleton<OverDueBloc>(
    () => OverDueBloc(sl<TaskRepository>(), sl<StorageService>()),
  );
  sl.registerLazySingleton<DueTodayBloc>(
    () => DueTodayBloc(sl<TaskRepository>(), sl<StorageService>()),
  );

  // ======================================================
  //  Task Details Feature
  // ======================================================

  sl.registerFactory<TaskDetailsBloc>(
    () => TaskDetailsBloc(sl<TaskRepository>(), sl<StorageService>()),
  );

  sl.registerLazySingleton<AppNotificationService>(
    () => AppNotificationService(sl<DioClient>()),
  );

  sl.registerLazySingleton<AppNotificationRepository>(
    () => AppNotificationRepository(sl<AppNotificationService>()),
  );

  sl.registerLazySingleton<ProChatService>(() => ProChatService(sl<DioClient>()));

  sl.registerLazySingleton<ProchatTaskRepository>(() => ProchatTaskRepository(sl<ProChatService>()));



}

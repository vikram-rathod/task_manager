import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager/features/AllTasks/bloc/all_task_bloc.dart';
import 'package:task_manager/features/createtask/bloc/task_create_bloc.dart';
import 'package:task_manager/features/home/bloc/home_bloc.dart';
import 'package:task_manager/features/home/repository/task_repository.dart';
import 'package:task_manager/features/home/services/home_service.dart';

import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/createtask/services/task_service.dart';
import '../../features/home/repository/home_repository.dart';
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
}

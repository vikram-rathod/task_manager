// lib/core/di/injection_container.dart

import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/dio_client.dart';
import '../storage/storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // ============================================
  // External Dependencies
  // ============================================
  const secureStorageOptions = AndroidOptions();
  
  final flutterSecureStorage = const FlutterSecureStorage(
    aOptions: secureStorageOptions,
  );
  
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => flutterSecureStorage,
  );
  // ============================================
  // Core - Storage
  // ============================================

  sl.registerLazySingleton<StorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );
  // ============================================
  // Core - Network
  // ============================================
  sl.registerLazySingleton<DioClient>(() => DioClient());

  // ============================================
  // Features - Auth
  // ============================================
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      sl<DioClient>(),
      sl<StorageService>(),
    ),
  );
  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );

}
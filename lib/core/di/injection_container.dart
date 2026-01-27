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
  print('');
  print('========================================');
  print(' Initializing Dependencies...');
  print('========================================');

  // ============================================
  // External Dependencies
  // ============================================
  print(' Setting up External Dependencies...');
  
  const secureStorageOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  
  final flutterSecureStorage = const FlutterSecureStorage(
    aOptions: secureStorageOptions,
  );
  
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => flutterSecureStorage,
  );
  print('    FlutterSecureStorage registered');

  // ============================================
  // Core - Storage
  // ============================================
  print(' Setting up Storage Layer...');
  
  sl.registerLazySingleton<StorageService>(
    () => SecureStorageService(sl<FlutterSecureStorage>()),
  );
  print('    StorageService registered');

  // ============================================
  // Core - Network
  // ============================================
  print(' Setting up Network Layer...');
  
  sl.registerLazySingleton<DioClient>(() => DioClient());
  print('    DioClient registered');

  // ============================================
  // Features - Auth
  // ============================================
  print(' Setting up Auth Feature...');
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      sl<DioClient>(),
      sl<StorageService>(),
    ),
  );
  print('    AuthRepository registered');

  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );
  print('    AuthBloc registered');

  print('');
  print('========================================');
  print(' All Dependencies Initialized!');
  print('========================================');
  print('');
}
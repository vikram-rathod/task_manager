// lib/features/auth/repository/auth_repository.dart

import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../models/auth_request.dart';

class AuthRepository {
  final DioClient _dioClient;
  final StorageService _storage;

  AuthRepository(this._dioClient, this._storage);

  /// Login
  Future<UserModel> login(AuthRequest request) async {
    try {
      print('🔐 Attempting login: ${request.email}');

      final response = await _dioClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final token = response.data['token'] as String;
      
      // Save to storage
      await _storage.write(StorageKeys.authToken, token);
      await _storage.write(StorageKeys.isLoggedIn, 'true');
      await _storage.write(StorageKeys.userEmail, request.email);
      
      _dioClient.addAuthToken(token);

      // Create user (in real app, fetch from /user endpoint)
      final user = UserModel(
        id: 1,
        email: request.email,
        firstName: 'John',
        lastName: 'Doe',
        token: token,
      );

      await _saveUserToStorage(user);
      
      print('✅ Login successful');
      return user;
      
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register
  Future<UserModel> register(AuthRequest request) async {
    try {
      print('📝 Attempting registration: ${request.email}');

      final response = await _dioClient.post(
        ApiConstants.register,
        data: request.toJson(),
      );

      final token = response.data['token'] as String;
      final userId = response.data['id'] ?? 1;
      
      // Save to storage
      await _storage.write(StorageKeys.authToken, token);
      await _storage.write(StorageKeys.isLoggedIn, 'true');
      await _storage.write(StorageKeys.userEmail, request.email);
      await _storage.write(StorageKeys.userId, userId.toString());
      
      _dioClient.addAuthToken(token);

      final user = UserModel(
        id: userId,
        email: request.email,
        token: token,
      );

      await _saveUserToStorage(user);
      
      print('✅ Registration successful');
      return user;
      
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    print('👋 Logging out...');
    
    await _storage.delete(StorageKeys.authToken);
    await _storage.delete(StorageKeys.userId);
    await _storage.delete(StorageKeys.userEmail);
    await _storage.delete(StorageKeys.userName);
    await _storage.delete(StorageKeys.isLoggedIn);
    
    _dioClient.removeAuthToken();
    
    print('✅ Logout successful');
  }

  /// Check if logged in
  Future<bool> isLoggedIn() async {
    final hasToken = await _storage.containsKey(StorageKeys.authToken);
    final isLoggedInValue = await _storage.read(StorageKeys.isLoggedIn);
    return hasToken && isLoggedInValue == 'true';
  }

  /// Get saved user
  Future<UserModel?> getSavedUser() async {
    try {
      final token = await _storage.read(StorageKeys.authToken);
      final userIdStr = await _storage.read(StorageKeys.userId);
      final email = await _storage.read(StorageKeys.userEmail);

      if (token == null || email == null) return null;

      final userId = int.tryParse(userIdStr ?? '0') ?? 0;

      return UserModel(
        id: userId,
        email: email,
        token: token,
      );
    } catch (e) {
      print('❌ Error getting saved user: $e');
      return null;
    }
  }

  /// Save user to storage
  Future<void> _saveUserToStorage(UserModel user) async {
    await _storage.write(StorageKeys.userId, user.id.toString());
    await _storage.write(StorageKeys.userEmail, user.email);
    
    if (user.firstName != null && user.lastName != null) {
      await _storage.write(StorageKeys.userName, user.fullName);
    }
  }

  /// Handle errors
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please try again.';
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['error'] ?? 'Server error';
        
        if (statusCode == 400) return message;
        if (statusCode == 401) return 'Invalid email or password';
        if (statusCode == 404) return 'User not found';
        return 'Error: $statusCode';
      
      case DioExceptionType.connectionError:
        return 'No internet connection';
      
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
import 'package:dio/dio.dart';
import 'package:task_manager/features/auth/models/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/constants/api_constants.dart';

import '../models/auth_request.dart';
import '../models/login_response.dart';
import '../models/session_data.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final StorageService _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<ApiResponse<LoginResponse>> login(AuthRequest request) async {
    try {

      final response = await _dioClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
            (data) => LoginResponse.fromJson(data),
      );

        return apiResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// REQUEST OTP for force login
  Future<ApiResponse<dynamic>> requestOtp(String email) async {
    try {

      // Using Form-Data
      final formData = FormData.fromMap({
        'sendOtp': '1',
        'email': email,
      });

      final response = await _dioClient.post(
        ApiConstants.requestOtp,
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
            (data) => data,
      );

      return apiResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// VERIFY OTP
  Future<ApiResponse<dynamic>> verifyOtp(String email, String otp) async {
    try {
      // Using Form-Data
      final formData = FormData.fromMap({
        'verifyOtp': '1',
        'otp': otp,
        'email': email,
      });

      final response = await _dioClient.post(
        ApiConstants.verifyOtp,
        data: formData,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final apiResponse = ApiResponse.fromJson(
        response.data,
            (data) => data,
      );

      return apiResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  /// CHECK SESSION - Validate with backend using generic ApiResponse
  Future<bool> checkSessionWithBackend() async {
    try {

      final email = await _storage.read(StorageKeys.userEmail);
      final deviceUniqueId = await _storage.read(StorageKeys.deviceUniqueId);
      final storedSessionId = await _storage.read(StorageKeys.loginSessionId);

      if (email == null ||
          email.isEmpty ||
          deviceUniqueId == null ||
          deviceUniqueId.isEmpty ||
          storedSessionId == null ||
          storedSessionId.isEmpty) {
        return false;
      }


      final response = await _dioClient.get(
        ApiConstants.sessionCheck,
        queryParameters: {
          'email_id': email,
          'device_unique_id': deviceUniqueId,
        },
      );

      // ApiResponse with SessionData
      final apiResponse = ApiResponse.fromJson(
        response.data,
            (data) => SessionData.fromJson(data),
      );

      if (apiResponse.status && apiResponse.data != null) {
        final backendSessionId = apiResponse.data!.loginSessionId.toString();

        // Compare session IDs
        if (backendSessionId == storedSessionId) {
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } on DioException {
      return false;
    } catch (e) {
      return false;
    }
  }

  /// VALIDATE SESSION (local + backend check)
  Future<bool> isSessionValid() async {
    try {
      // First check local storage
      final isLoggedIn = await _storage.read(StorageKeys.isLoggedIn);
      final sessionId = await _storage.read(StorageKeys.loginSessionId);

      if (isLoggedIn != 'true' || sessionId == null || sessionId.isEmpty) {
        return false;
      }

      // Validate with backend
      final isBackendValid = await checkSessionWithBackend();

      if (!isBackendValid) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> saveUser(UserModel user, {String? deviceUniqueId}) async {
    await _storage.write(StorageKeys.isLoggedIn, 'true');

    await _storage.write(StorageKeys.loginSessionId, user.loginSessionId);

    await _storage.write(StorageKeys.userName, user.userName);
    await _storage.write(StorageKeys.userId, user.userId.toString());
    await _storage.write(StorageKeys.userType, user.userType.toString());
    await _storage.write(StorageKeys.userTypeName, user.userTypeName);
    await _storage.write(StorageKeys.userMobile, user.userMobileNumber);
    await _storage.write(StorageKeys.userEmail, user.userEmail);
    await _storage.write(StorageKeys.designation, user.designation);
    await _storage.write(
      StorageKeys.userAccAutoCreate,
      user.userAccAutoCreate.toString(),
    );
    await _storage.write(
      StorageKeys.refCandidateId,
      user.refCandidateId.toString(),
    );
    await _storage.write(StorageKeys.userFixId, user.userFixId.toString());
    await _storage.write(StorageKeys.profileType, user.profileType);
    await _storage.write(StorageKeys.userProfileUrl, user.userProfileUrl);

    await _storage.write(StorageKeys.companyId, user.companyId.toString());
    await _storage.write(StorageKeys.companyName, user.companyName);
    await _storage.write(StorageKeys.companyType, user.companyType);
    await _storage.write(StorageKeys.companyLogoUrl, user.companyLogoUrl);

    await _storage.write(StorageKeys.userPassword, user.userPassword);

    if (deviceUniqueId != null && deviceUniqueId.isNotEmpty) {
      await _storage.write(StorageKeys.deviceUniqueId, deviceUniqueId);
    }
  }

  Future<void> logout() async {
    for (final key in [
      StorageKeys.isLoggedIn,
      StorageKeys.loginSessionId,
      StorageKeys.userName,
      StorageKeys.userId,
      StorageKeys.userType,
      StorageKeys.userTypeName,
      StorageKeys.userMobile,
      StorageKeys.userEmail,
      StorageKeys.designation,
      StorageKeys.userAccAutoCreate,
      StorageKeys.refCandidateId,
      StorageKeys.userFixId,
      StorageKeys.profileType,
      StorageKeys.userProfileUrl,
      StorageKeys.companyId,
      StorageKeys.companyName,
      StorageKeys.companyType,
      StorageKeys.companyLogoUrl,
      StorageKeys.userPassword,
    ]) {
      await _storage.delete(key);
    }
  }

  Future<UserModel?> getSavedUser() async {
    final isLoggedIn = await _storage.read(StorageKeys.isLoggedIn);
    if (isLoggedIn != 'true') return null;

    return UserModel(
      userName: await _storage.read(StorageKeys.userName) ?? '',
      userId: int.tryParse(await _storage.read(StorageKeys.userId) ?? '0') ?? 0,
      userType:
      int.tryParse(await _storage.read(StorageKeys.userType) ?? '0') ?? 0,
      userTypeName: await _storage.read(StorageKeys.userTypeName) ?? '',
      companyId:
      int.tryParse(await _storage.read(StorageKeys.companyId) ?? '0') ?? 0,
      companyName: await _storage.read(StorageKeys.companyName) ?? '',
      companyType: await _storage.read(StorageKeys.companyType) ?? '',
      companyLogoUrl: await _storage.read(StorageKeys.companyLogoUrl) ?? '',
      userProfileUrl: await _storage.read(StorageKeys.userProfileUrl) ?? '',
      profileType: await _storage.read(StorageKeys.profileType) ?? '',
      userMobileNumber: await _storage.read(StorageKeys.userMobile) ?? '',
      userEmail: await _storage.read(StorageKeys.userEmail) ?? '',
      designation: await _storage.read(StorageKeys.designation) ?? '',
      userAccAutoCreate:
      (await _storage.read(StorageKeys.userAccAutoCreate)) == 'true',
      refCandidateId:
      int.tryParse(
        await _storage.read(StorageKeys.refCandidateId) ?? '0',
      ) ??
          0,
      userFixId:
      int.tryParse(await _storage.read(StorageKeys.userFixId) ?? '0') ?? 0,
      userPassword: await _storage.read(StorageKeys.userPassword) ?? '',
      loginSessionId: await _storage.read(StorageKeys.loginSessionId) ?? '',
    );
  }

  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Try again.';

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'Server error';

        if (status == 400) return message;
        if (status == 401) return 'Invalid credentials';
        if (status == 404) return 'User not found';
        return 'Error: $status';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      default:
        return 'Something went wrong';
    }
  }
}
import 'dart:convert';

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
      print(" LOGIN REQUEST BODY: ${request.toJson()}");

      final response = await _dioClient.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      print(" LOGIN RESPONSE BODY: ${response.data}");

      final apiResponse = ApiResponse.fromJson(
        response.data,
            (data) => LoginResponse.fromJson(data),
      );


        return apiResponse;
    } on DioException catch (e) {
      if (e.response != null) {
        print(" LOGIN ERROR BODY: ${e.response?.data}");
      }
      throw _handleError(e);
    }
  }

  /// REQUEST OTP for force login
  Future<ApiResponse<dynamic>> requestOtp(String email) async {
    try {
      print(" REQUEST OTP FOR: $email");

      // Using FormData
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

      print(" REQUEST OTP RESPONSE: ${response.data}");

      // Parse the response
      final responseData = response.data is String
          ? _parseJsonString(response.data)
          : response.data;

      // Create ApiResponse wrapper
      final status = responseData['status'] ?? false;
      final message = responseData['message'] ?? 'OTP request failed';
      final otp = responseData['otp'].toString() ?? '';

      print(" OTP Status: $status");
      print(" OTP Message: $message");
      if (status && otp.isNotEmpty) {
        print(" OTP: $otp"); // For development only, remove in production
      }

      return ApiResponse(
        status: status,
        message: message,
        data: {'otp': otp},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        print(" REQUEST OTP ERROR: ${e.response?.data}");
      }
      throw _handleError(e);
    }
  }

  /// VERIFY OTP
  Future<ApiResponse<dynamic>> verifyOtp(String email, String otp) async {
    try {
      print(" VERIFY OTP FOR: $email");
      print(" OTP: $otp");

      // Using FormData as per the Kotlin implementation
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

      print(" VERIFY OTP RESPONSE: ${response.data}");

      // Parse the response
      final responseData = response.data is String
          ? _parseJsonString(response.data)
          : response.data;

      // Create ApiResponse wrapper
      final status = responseData['status'] ?? false;
      final message = responseData['message'] ?? 'OTP verification failed';

      print(" Verification Status: $status");
      print(" Message: $message");

      return ApiResponse(
        status: status,
        message: message,
        data: null,
      );
    } on DioException catch (e) {
      if (e.response != null) {
        print(" VERIFY OTP ERROR: ${e.response?.data}");
      }
      throw _handleError(e);
    }
  }

  /// Helper method to parse JSON string response
  Map<String, dynamic> _parseJsonString(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      print("JSON Parse Error: $e");
      return {};
    }
  }

  /// CHECK SESSION - Validate with backend using generic ApiResponse
  Future<bool> checkSessionWithBackend() async {
    try {
      print(" CHECKING SESSION WITH BACKEND");

      final email = await _storage.read(StorageKeys.userEmail);
      final deviceUniqueId = await _storage.read(StorageKeys.deviceUniqueId);
      final storedSessionId = await _storage.read(StorageKeys.loginSessionId);

      if (email == null ||
          email.isEmpty ||
          deviceUniqueId == null ||
          deviceUniqueId.isEmpty ||
          storedSessionId == null ||
          storedSessionId.isEmpty) {
        print(" Missing required session data");
        return false;
      }

      print(" Email: $email");
      print(" Device ID: $deviceUniqueId");
      print(" Stored Session ID: $storedSessionId");

      final response = await _dioClient.get(
        ApiConstants.sessionCheck,
        queryParameters: {
          'email_id': email,
          'device_unique_id': deviceUniqueId,
        },
      );

      print("SESSION CHECK RESPONSE: ${response.statusCode}");
      print("Response Data: ${response.data}");

      // ApiResponse with SessionData
      final apiResponse = ApiResponse.fromJson(
        response.data,
            (data) => SessionData.fromJson(data),
      );

      if (apiResponse.status && apiResponse.data != null) {
        final backendSessionId = apiResponse.data!.loginSessionId.toString();

        print(" Backend Session ID: $backendSessionId");
        print(" Stored Session ID: $storedSessionId");

        // Compare session IDs
        if (backendSessionId == storedSessionId) {
          print(" SESSION VALID - IDs match");
          return true;
        } else {
          print(" SESSION MISMATCH - Different session IDs");
          return false;
        }
      } else {
        print(" NO ACTIVE SESSION: ${apiResponse.message}");
        return false;
      }
    } on DioException catch (e) {
      print(" SESSION CHECK FAILED: ${e.type}");
      if (e.response != null) {
        print("Error Response: ${e.response?.data}");
      }
      return false;
    } catch (e) {
      print(" SESSION CHECK ERROR: $e");
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
        print(" Local session invalid");
        return false;
      }

      // Validate with backend
      print(" Validating session with backend...");
      final isBackendValid = await checkSessionWithBackend();

      if (!isBackendValid) {
        print(" Backend session validation failed");
        return false;
      }

      print(" Session valid (local + backend)");
      return true;
    } catch (e) {
      print(" Session validation error: $e");
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
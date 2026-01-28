import 'package:dio/dio.dart';
import 'package:task_manager/features/auth/models/api_response.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/storage/storage_keys.dart';
import '../../../core/constants/api_constants.dart';

import '../models/auth_request.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  final StorageService _storage;

  AuthRepository(this._dioClient, this._storage);

  /// LOGIN → Call API & return LoginResponse

Future<LoginResponse> login(AuthRequest request) async {
  try {
    print("LOGIN REQUEST BODY: ${request.toJson()}");

    final response = await _dioClient.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    print("LOGIN RESPONSE BODY: ${response.data}");

    final apiResponse = ApiResponse.fromJson(
      response.data,
      (data) => LoginResponse.fromJson(data),
    );

    // Backend already wraps data inside ApiResponse
    if (apiResponse.status && apiResponse.data != null) {
      return apiResponse.data!;
    } else {
      throw apiResponse.message.isNotEmpty
          ? apiResponse.message
          : (apiResponse.error ?? "Unknown login error");
    }
  } on DioException catch (e) {
    if (e.response != null) {
      print("LOGIN ERROR BODY: ${e.response?.data}");
    }
    throw _handleError(e);
  }
}



  /// SAVE USER → Store selected or single account user
  Future<void> saveUser(UserModel user) async {
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
        StorageKeys.userAccAutoCreate, user.userAccAutoCreate.toString());
    await _storage.write(
        StorageKeys.refCandidateId, user.refCandidateId.toString());
    await _storage.write(StorageKeys.userFixId, user.userFixId.toString());
    await _storage.write(StorageKeys.profileType, user.profileType);
    await _storage.write(StorageKeys.userProfileUrl, user.userProfileUrl);

    await _storage.write(StorageKeys.companyId, user.companyId.toString());
    await _storage.write(StorageKeys.companyName, user.companyName);
    await _storage.write(StorageKeys.companyType, user.companyType);
    await _storage.write(StorageKeys.companyLogoUrl, user.companyLogoUrl);

    await _storage.write(StorageKeys.userPassword, user.userPassword);
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


  /// RESTORE USER
  Future<UserModel?> getSavedUser() async {
    final isLoggedIn = await _storage.read(StorageKeys.isLoggedIn);
    if (isLoggedIn != 'true') return null;

    return UserModel(
      userName: await _storage.read(StorageKeys.userName) ?? '',
      userId:
          int.tryParse(await _storage.read(StorageKeys.userId) ?? '0') ?? 0,
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
          int.tryParse(await _storage.read(StorageKeys.refCandidateId) ?? '0') ??
              0,
      userFixId:
          int.tryParse(await _storage.read(StorageKeys.userFixId) ?? '0') ?? 0,
      userPassword: await _storage.read(StorageKeys.userPassword) ?? '',
      loginSessionId: await _storage.read(StorageKeys.loginSessionId) ?? '',
    );
  }

  /// ERROR HANDLER
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

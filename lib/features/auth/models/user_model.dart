import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String userName;
  final int userId;
  final int userType;
  final String userTypeName;
  final int companyId;
  final String companyName;
  final String companyType;
  final String companyLogoUrl;
  final String userProfileUrl;
  final String profileType;
  final String userMobileNumber;
  final String userEmail;
  final String designation;
  final bool userAccAutoCreate;
  final int refCandidateId;
  final int userFixId;
  final String userPassword;
  final String loginSessionId;

  const UserModel({
    required this.userName,
    required this.userId,
    required this.userType,
    required this.userTypeName,
    required this.companyId,
    required this.companyName,
    required this.companyType,
    required this.companyLogoUrl,
    required this.userProfileUrl,
    required this.profileType,
    required this.userMobileNumber,
    required this.userEmail,
    required this.designation,
    required this.userAccAutoCreate,
    required this.refCandidateId,
    required this.userFixId,
    required this.userPassword,
    required this.loginSessionId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
    bool toBool(dynamic v) => v == true || v.toString() == "true";

    return UserModel(
      userName: json['user_name']?.toString() ?? '',
      userId: toInt(json['user_id']),
      userType: toInt(json['user_type']),
      userTypeName: json['user_type_name']?.toString() ?? '',

      companyId: toInt(json['company_id']),
      companyName: json['company_name']?.toString() ?? '',
      companyType: json['company_type']?.toString() ?? '',
      companyLogoUrl: json['company_logo_url']?.toString() ?? '',

      userProfileUrl: json['user_profile_url']?.toString() ?? '',
      profileType: json['profile_type']?.toString() ?? '',

      userMobileNumber: json['user_mobile_number']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',

      userAccAutoCreate: toBool(json['user_acc_auto_create']),
      refCandidateId: toInt(json['ref_candidate_id']),
      userFixId: toInt(json['user_fix_id']),

      userPassword: json['user_password']?.toString() ?? '',

      loginSessionId: json['login_session_id']?.toString() ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'user_id': userId,
      'user_type': userType,
      'user_type_name': userTypeName,
      'company_id': companyId,
      'company_name': companyName,
      'company_type': companyType,
      'company_logo_url': companyLogoUrl,
      'user_profile_url': userProfileUrl,
      'profile_type': profileType,
      'user_mobile_number': userMobileNumber,
      'user_email': userEmail,
      'designation': designation,
      'user_acc_auto_create': userAccAutoCreate,
      'ref_candidate_id': refCandidateId,
      'user_fix_id': userFixId,
      'user_password': userPassword,
      'login_session_id': loginSessionId,
    };
  }



  @override
  List<Object?> get props => [
        userId,
        userName,
        userEmail,
        companyId,
        loginSessionId,
        userTypeName,
        companyName,
        companyType,
        companyLogoUrl,
        userProfileUrl,
        profileType,
        userMobileNumber,
        designation,
        userAccAutoCreate,
        refCandidateId,
        userFixId,
        userPassword,
        userType,
      ];

  @override
  String toString() {
    return 'UserModel{userName: $userName, userId: $userId, userType: $userType, userTypeName: $userTypeName, companyId: $companyId, companyName: $companyName, companyType: $companyType, companyLogoUrl: $companyLogoUrl, userProfileUrl: $userProfileUrl, profileType: $profileType, userMobileNumber: $userMobileNumber, userEmail: $userEmail, designation: $designation, userAccAutoCreate: $userAccAutoCreate, refCandidateId: $refCandidateId, userFixId: $userFixId, userPassword: $userPassword, loginSessionId: $loginSessionId}';
  }
}

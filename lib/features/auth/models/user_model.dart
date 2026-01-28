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
    int _toInt(dynamic v) => v == null ? 0 : int.tryParse(v.toString()) ?? 0;
    bool _toBool(dynamic v) => v == true || v.toString() == "true";

    return UserModel(
      userName: json['user_name']?.toString() ?? '',
      userId: _toInt(json['user_id']),
      userType: _toInt(json['user_type']),
      userTypeName: json['user_type_name']?.toString() ?? '',

      companyId: _toInt(json['company_id']),
      companyName: json['company_name']?.toString() ?? '',
      companyType: json['company_type']?.toString() ?? '',
      companyLogoUrl: json['company_logo_url']?.toString() ?? '',

      userProfileUrl: json['user_profile_url']?.toString() ?? '',
      profileType: json['profile_type']?.toString() ?? '',

      userMobileNumber: json['user_mobile_number']?.toString() ?? '',
      userEmail: json['user_email']?.toString() ?? '',
      designation: json['designation']?.toString() ?? '',

      userAccAutoCreate: _toBool(json['user_acc_auto_create']),
      refCandidateId: _toInt(json['ref_candidate_id']),
      userFixId: _toInt(json['user_fix_id']),

      userPassword: json['user_password']?.toString() ?? '',

      loginSessionId: json['login_session_id']?.toString() ?? '',
    );
  }


  @override
  List<Object?> get props => [
        userId,
        userName,
        userEmail,
        companyId,
        loginSessionId,
      ];
}

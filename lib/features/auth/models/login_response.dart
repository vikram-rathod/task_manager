import 'package:task_manager/features/auth/models/user_model.dart';

class LoginResponse {
  final bool isMulti;
  final UserModel? userInfo;
  final List<UserModel> accountList;

  LoginResponse({
    required this.isMulti,
    this.userInfo,
    required this.accountList,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      isMulti: json['is_multi'] ?? false,
      userInfo: json['user_info'] != null
          ? UserModel.fromJson(json['user_info'])
          : null,
      accountList: (json['account_list'] as List<dynamic>? ?? [])
          .map((e) => UserModel.fromJson(e))
          .toList(),
    );
  }
  @override
  String toString() {
    return 'LoginResponse('
        'isMulti: $isMulti, '
        'userInfo: $userInfo, '
        'accountList: $accountList'
        ')';
  }

}

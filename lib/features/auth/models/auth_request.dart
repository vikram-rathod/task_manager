class AuthRequest {
  final String username;
  final String password;
  final String deviceName;
  final String deviceType;
  final String deviceUniqueId;
  final String deviceToken;
  final bool isForce;
  final bool isSwitch;
  final String appType;

  AuthRequest({
    required this.username,
    required this.password,
    required this.deviceName,
    required this.deviceType,
    required this.deviceUniqueId,
    required this.deviceToken,
    required this.isForce,
    required this.isSwitch,
    required this.appType,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'device_name': deviceName,
      'device_type': deviceType,
      'device_unique_id': deviceUniqueId,
      'device_token': deviceToken,
      'isForce': isForce,
      'isSwitch': isSwitch,
      'app_type': appType,
    };
  }
}

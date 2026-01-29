
class SessionData {
  final int loginSessionId;

  SessionData({required this.loginSessionId});

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      loginSessionId: json['login_session_id'] ?? 0,
    );
  }
}
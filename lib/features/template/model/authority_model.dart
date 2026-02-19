class AuthorityModel {
  final int userId;
  final String userName;
  final bool selected;

  AuthorityModel({
    required this.userId,
    required this.userName,
    required this.selected,
  });

  factory AuthorityModel.fromJson(Map<String, dynamic> json) {
    return AuthorityModel(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      selected: json['selected'] ?? false,
    );
  }
}

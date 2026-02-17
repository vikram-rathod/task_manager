class MentionedUser {
  final String userName;
  final String userId;
  final String profileUrl;

  MentionedUser({
    required this.userName,
    required this.userId,
    required this.profileUrl,
  });

  factory MentionedUser.fromJson(Map<String, dynamic> json) {
    return MentionedUser(
      userName: json['user_name'] ?? '',
      userId: json['user_id']?.toString() ?? '',
      profileUrl: json['profile_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'user_id': userId,
      'profile_url': profileUrl,
    };
  }
}
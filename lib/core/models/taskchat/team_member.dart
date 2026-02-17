// Team member model for mentions
class TeamMember {
  final String userId;
  final String userName;
  final String profileUrl;
  final String role;

  TeamMember({
    required this.userId,
    required this.userName,
    required this.profileUrl,
    required this.role,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] ?? '',
      profileUrl: json['profile_url'] ?? '',
      role: json['role'] ?? '',
    );
  }
}
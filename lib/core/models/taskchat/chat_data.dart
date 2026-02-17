import 'mention_user.dart';

class ChatData {
  final int chatId;
  final int userId;
  final String userName;
  final String case_;
  final String message;
  final List<MentionedUser> mentionedUsers;
  final List<String> documentUrls;
  final String userProfileUrl;
  final String cdate;
  final int replyToId;
  final String replyText;
  final String replyUser;
  final List<dynamic> replyFiles;
  final List<dynamic> replySrc;

  ChatData({
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.case_,
    required this.message,
    required this.mentionedUsers,
    required this.documentUrls,
    required this.userProfileUrl,
    required this.cdate,
    required this.replyToId,
    required this.replyText,
    required this.replyUser,
    required this.replyFiles,
    required this.replySrc,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) {
    return ChatData(
      chatId: json['chat_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? '',
      case_: json['case'] ?? '',
      message: json['message'] ?? '',
      mentionedUsers: (json['mentioned_users'] as List?)
          ?.map((user) => MentionedUser.fromJson(user))
          .toList() ??
          [],
      documentUrls: (json['document_urls'] as List?)
          ?.map((url) => url.toString())
          .toList() ??
          [],
      userProfileUrl: json['user_profile_url'] ?? '',
      cdate: json['cdate'] ?? '',
      replyToId: json['reply_to_id'] ?? 0,
      replyText: json['reply_text'] ?? '',
      replyUser: json['reply_user'] ?? '',
      replyFiles: json['reply_files'] ?? [],
      replySrc: json['reply_src'] ?? [],
    );
  }
}
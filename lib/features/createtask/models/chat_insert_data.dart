class ChatInsertData {
  final int chatId;

  ChatInsertData({required this.chatId});

  factory ChatInsertData.fromJson(Map<String, dynamic> json) {
    return ChatInsertData(chatId: json['insert_id']);
  }
}

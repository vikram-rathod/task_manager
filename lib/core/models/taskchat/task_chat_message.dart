import 'package:task_manager/features/home/model/task_history_model.dart';

import 'chat_data.dart';

class TimelineItem {
  final String type; // 'chat' or 'history'
  final ChatData? chatData;
  final TaskHistoryModel? historyData;

  TimelineItem({
    required this.type,
    this.chatData,
    this.historyData,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return TimelineItem(
      type: type,
      chatData: type == 'chat' ? ChatData.fromJson(json) : null,
      historyData: type == 'history' ? TaskHistoryModel.fromJson(json) : null,
    );
  }

  bool get isChat => type == 'chat';
  bool get isHistory => type == 'history';
}






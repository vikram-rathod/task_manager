import 'package:task_manager/core/models/taskchat/bcstep_task_model.dart';

class AppNotificationResponseModel {
  final String type;
  final List<BcstepTaskModel> list;

  AppNotificationResponseModel({
    required this.type,
    required this.list,
  });

  factory AppNotificationResponseModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationResponseModel(
      type: json['type']?.toString() ?? '',
      list: (json['list'] as List<dynamic>?)
          ?.map((e) => BcstepTaskModel.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'list': list.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'AppNotificationAcknowModel(type: $type, list: $list)';
  }
}

class TaskRequestBody {
  final int userId;
  final int compId;
  final int userType;
  final int page;
  final int size;
  final int? makerId;
  final int? checkerId;
  final int? pcEngineerId;
  final String? projectId;
  final String? taskStatus;
  final String? registrationDate;
  final String? searchDescription;

  const TaskRequestBody({
    this.userId = 0,
    this.compId = 0,
    this.userType = 0,
    this.page = 1,
    this.size = 50,
    this.makerId,
    this.checkerId,
    this.pcEngineerId,
    this.projectId,
    this.taskStatus,
    this.registrationDate,
    this.searchDescription,
  });

  factory TaskRequestBody.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) =>
        v == null ? 0 : int.tryParse(v.toString()) ?? 0;

    return TaskRequestBody(
      userId: toInt(json['user_id']),
      compId: toInt(json['comp_id']),
      userType: toInt(json['user_type']),
      page: toInt(json['page']),
      size: toInt(json['size']),
      makerId: json['maker_id'] != null ? toInt(json['maker_id']) : null,
      checkerId:
      json['checker_id'] != null ? toInt(json['checker_id']) : null,
      pcEngineerId: json['pc_engr_id'] != null
          ? toInt(json['pc_engr_id'])
          : null,
      projectId: json['project_id']?.toString(),
      taskStatus: json['task_status']?.toString(),
      registrationDate: json['registration_date']?.toString(),
      searchDescription: json['search_description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'comp_id': compId,
      'user_type': userType,
      'page': page,
      'size': size,
      if (makerId != null) 'maker_id': makerId,
      if (checkerId != null) 'checker_id': checkerId,
      if (pcEngineerId != null) 'pc_engr_id': pcEngineerId,
      if (projectId != null && projectId!.isNotEmpty)
        'project_id': projectId,
      if (taskStatus != null) 'task_status': taskStatus,
      if (registrationDate != null)
        'registration_date': registrationDate,
      if (searchDescription != null)
        'search_description': searchDescription,
    };
  }
}

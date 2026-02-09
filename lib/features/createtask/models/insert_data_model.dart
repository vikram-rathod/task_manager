class InsertIdData {
  final int insertId;

  InsertIdData({required this.insertId});

  factory InsertIdData.fromJson(Map<String, dynamic> json) {
    return InsertIdData(insertId: json['insert_id']);
  }
}

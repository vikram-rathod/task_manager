import 'employee_count_model.dart';

class EmployeeCountListData {

  final List<EmployeeModel> list;
  final int total;

  EmployeeCountListData({
    required this.list,
    required this.total,
  });

  factory EmployeeCountListData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    final rawList = json['list'] as List? ?? [];

    return EmployeeCountListData(
      list: rawList
          .map((e) => EmployeeModel.fromJson(e))
          .toList(),
      total: parseInt(json['total']),
    );
  }
}
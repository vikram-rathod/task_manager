import 'package:flutter/material.dart';

import '../../../core/models/task_model.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TMTasksModel taskModel;

  const TaskDetailsScreen({super.key, required this.taskModel});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

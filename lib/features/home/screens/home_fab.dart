import 'package:flutter/material.dart';
import '../../createtask/screen/create_task_screen.dart';

class HomeFab extends StatelessWidget {
  const HomeFab({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: 64,
      child: FloatingActionButton(
        elevation: 10,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }
}

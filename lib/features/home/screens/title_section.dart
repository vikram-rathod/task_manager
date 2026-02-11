
import 'package:flutter/material.dart';
import 'package:task_manager/animations/header_text_animation.dart';
import 'package:task_manager/features/auth/models/user_model.dart';

class TitleSection extends StatelessWidget {
  final UserModel user;

  const TitleSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "TASK ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: "MANAGER",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        HeaderTextAnimation(
          designation: user.designation,
          companyText: user.companyName.isEmpty
              ? user.userName
              : "${user.companyName} • ${user.companyType}",
        ),
        const SizedBox(height: 4),
        Container(
          width: 120,
          height: 0.5,
          color: const Color(0xFFB5E5B6),
        ),
      ],
    );
  }
}
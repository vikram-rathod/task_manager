import 'package:flutter/material.dart';
import 'package:task_manager/animations/header_text_animation.dart';
import 'package:task_manager/features/auth/models/user_model.dart';

class TitleSection extends StatelessWidget {
  final UserModel user;

  const TitleSection({super.key, required this.user});

  String get _subtitleText {
    if (user.companyName.isEmpty) return user.userName;
    return "${user.companyName} • ${user.companyType}";
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "TASK ",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: scheme.onSurface,
                ),
              ),
              TextSpan(
                text: "MANAGER",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        Flexible(
          child: HeaderTextAnimation(
            designation: user.designation,
            companyText: _subtitleText,
          ),
        ),
      ],
    );
  }
}
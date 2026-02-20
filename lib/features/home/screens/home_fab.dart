import 'dart:math';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  HomeFab
// ─────────────────────────────────────────────
class HomeFab extends StatelessWidget {
  const HomeFab({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FloatingActionButton(
      onPressed: () => Navigator.pushNamed(context, '/createTask'),
      backgroundColor: cs.primary,
      foregroundColor: cs.onPrimary,
      elevation: 4,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, size: 28),
    );
  }
}
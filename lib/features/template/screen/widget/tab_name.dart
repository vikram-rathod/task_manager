import 'package:flutter/material.dart';

import 'card_decoration.dart';

Widget buildTabName(ColorScheme scheme, String tabName) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: cardDecoration(scheme),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.tab_rounded,
            size: 18,
            color: scheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            tabName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}
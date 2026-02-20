import 'package:flutter/material.dart';

BoxDecoration cardDecoration(ColorScheme scheme) {
  return BoxDecoration(
    color: scheme.surface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.green.withOpacity(0.5), width: 0.3),
  );
}
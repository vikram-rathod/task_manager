import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Tab configuration
class TaskTab extends Equatable {
  final String id;
  final String label;
  final IconData icon;

  const TaskTab({
    required this.id,
    required this.label,
    required this.icon,
  });

  @override
  List<Object?> get props => [id, label, icon];
}
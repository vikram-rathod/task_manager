import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class QuickActionModel extends Equatable {
  final String id;
  final IconData icon;
  final String label;
  final bool isHighlighted;
  final int count;
  final int pendingAtMe;
  final int pendingAtOthers;

  final VoidCallback onTap;

  const QuickActionModel({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
    this.count = 0,
    this.pendingAtMe = 0,
    this.pendingAtOthers = 0,
  });

  QuickActionModel copyWith({
    int? count,
    int? pendingAtMe,
    int? pendingAtOthers,
  }) {
    return QuickActionModel(
      id: id,
      icon: icon,
      label: label,
      isHighlighted: isHighlighted,
      onTap: onTap,
      count: count ?? this.count,
      pendingAtMe: pendingAtMe ?? this.pendingAtMe,
      pendingAtOthers: pendingAtOthers ?? this.pendingAtOthers,
    );
  }

  @override
  List<Object?> get props => [
    id,
    label,
    isHighlighted,
    count,
    pendingAtMe,
    pendingAtOthers,
  ];
}

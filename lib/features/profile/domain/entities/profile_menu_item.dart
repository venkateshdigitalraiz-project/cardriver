import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

class ProfileMenuItem extends Equatable {
  final String title;
  final String subtitle;
  final IconData icon;

  const ProfileMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  List<Object?> get props => [title, subtitle, icon];
}

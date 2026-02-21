import 'package:flutter/material.dart';

/// Dashboard menu item model
class DashboardItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final int? badgeCount;

  const DashboardItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    this.badgeCount,
  });
}

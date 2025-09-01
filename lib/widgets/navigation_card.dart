import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class NavigationCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final AppTheme theme;
  final VoidCallback onTap;
  final int badgeCount;

  const NavigationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.theme,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(icon, size: 48, color: Colors.white);

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(badgeCount.toString()),
        child: iconWidget,
      );
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      color: theme.primaryColor.withOpacity(0.8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

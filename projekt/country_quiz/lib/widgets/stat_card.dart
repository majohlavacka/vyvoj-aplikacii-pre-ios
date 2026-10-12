import 'package:flutter/material.dart';

/// Malá štatistická karta (história hier).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: scheme.onSecondaryContainer),
            const SizedBox(height: 6),
            Text(
              value,
              style: text.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSecondaryContainer,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: text.labelMedium
                  ?.copyWith(color: scheme.onSecondaryContainer),
            ),
          ],
        ),
      ),
    );
  }
}

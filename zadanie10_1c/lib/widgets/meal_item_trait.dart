import 'package:flutter/material.dart';

// Mala informacia o jedle (ikona + text), napr. cas, narocnost, cena
class MealItemTrait extends StatelessWidget {
  final IconData icon;
  final String label;

  const MealItemTrait({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: Colors.white),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

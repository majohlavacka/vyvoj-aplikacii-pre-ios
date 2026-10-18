import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';

class MealDetailsScreen extends StatefulWidget {
  final Meal meal;
  final void Function(Meal meal) onToggleFavorite;
  final bool isFavorite;

  const MealDetailsScreen({
    super.key,
    required this.meal,
    required this.onToggleFavorite,
    required this.isFavorite,
  });

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  late bool _isFavorite = widget.isFavorite; // stav hviezdicky na tejto obrazovke

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final headingStyle = Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        );
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: Text(meal.title),
        actions: [
          IconButton(
            onPressed: () {
              widget.onToggleFavorite(meal);
              setState(() {
                _isFavorite = !_isFavorite;
              });
            },
            icon: Icon(_isFavorite ? Icons.star : Icons.star_border),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              meal.imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.black26,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 64),
              ),
            ),
            const SizedBox(height: 14),
            Text('Ingredients', style: headingStyle),
            const SizedBox(height: 14),
            for (final ingredient in meal.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(ingredient, style: TextStyle(color: textColor)),
              ),
            const SizedBox(height: 24),
            Text('Steps', style: headingStyle),
            const SizedBox(height: 14),
            for (final step in meal.steps)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  step,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor),
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

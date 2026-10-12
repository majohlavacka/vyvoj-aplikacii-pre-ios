import 'package:flutter/material.dart';

import '../models/game_mode.dart';

IconData modeIcon(GameMode mode) => switch (mode) {
      GameMode.flag => Icons.flag_rounded,
      GameMode.capital => Icons.location_city_rounded,
      GameMode.map => Icons.travel_explore_rounded,
    };

/// Karta na výber herného režimu. Výber oznamuje rodičovi cez callback [onTap].
class ModeCard extends StatelessWidget {
  const ModeCard({
    super.key,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final GameMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: selected ? scheme.primaryContainer : scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor:
                    selected ? scheme.primary : scheme.secondaryContainer,
                foregroundColor:
                    selected ? scheme.onPrimary : scheme.onSecondaryContainer,
                child: Icon(modeIcon(mode)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.title,
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(mode.description, style: text.bodyMedium),
                  ],
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: scheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

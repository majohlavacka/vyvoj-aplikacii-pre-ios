import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../models/question.dart';
import '../utils/formatters.dart';
import 'country_map.dart';
import 'flag_image.dart';

/// Zobrazí "zadanie" otázky podľa herného režimu.
class QuestionView extends StatelessWidget {
  const QuestionView({super.key, required this.question, required this.mode});

  final Question question;
  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          mode.prompt,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Expanded(child: _buildContent(context)),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final country = question.correct;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    switch (mode) {
      case GameMode.flag:
        return Center(
          child: FlagImage(
            key: ValueKey(country.code),
            url: country.flagUrl,
            borderRadius: 12,
          ),
        );
      case GameMode.capital:
        return Center(
          child: Card(
            elevation: 0,
            color: scheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_city_rounded,
                      size: 48, color: scheme.onTertiaryContainer),
                  const SizedBox(height: 12),
                  Text(
                    country.capital,
                    textAlign: TextAlign.center,
                    style: text.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kontinent: ${regionLabel(country.region)}',
                    style: text.bodyLarge
                        ?.copyWith(color: scheme.onTertiaryContainer),
                  ),
                ],
              ),
            ),
          ),
        );
      case GameMode.map:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CountryMap(
            key: ValueKey(country.code),
            latitude: country.latitude!,
            longitude: country.longitude!,
            zoom: 3.5,
            showLabels: false,
          ),
        );
    }
  }
}

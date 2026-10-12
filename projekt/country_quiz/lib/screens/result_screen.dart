import 'package:flutter/material.dart';

import '../models/game_result.dart';
import '../models/question.dart';
import '../widgets/flag_image.dart';
import 'country_detail_screen.dart';

/// 3. obrazovka – výsledok hry a prehľad odpovedí.
/// Dáta dostáva cez konštruktor, rozhodnutie vracia cez Navigator.pop.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.questions,
  });

  final GameResult result;
  final List<Question> questions;

  String get _message {
    final p = result.percentRounded;
    if (p >= 90) return 'Výborne, svet poznáš naozaj dobre!';
    if (p >= 60) return 'Dobrá práca!';
    if (p >= 30) return 'Nie je to zlé, skús to ešte raz.';
    return 'Chce to ešte trochu cestovania po atlase.';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Výsledok')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        '${result.score}/${result.total}',
                        style: text.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        '${result.percentRounded} %',
                        style: text.titleMedium
                            ?.copyWith(color: scheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _message,
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${result.playerName}, režim ${result.mode.title}',
                          style: TextStyle(color: scheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ťukni na krajinu a zobrazí sa jej detail.',
                style: text.bodySmall,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: questions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final q = questions[index];
                  return ListTile(
                    leading: FlagImage(
                      url: q.correct.flagUrl,
                      width: 56,
                      height: 36,
                      borderRadius: 4,
                    ),
                    title: Text('${index + 1}. ${q.correct.name}'),
                    subtitle: Text(
                      q.isCorrect
                          ? 'Správne'
                          : 'Tvoja odpoveď: ${q.selected?.name ?? '–'}',
                    ),
                    trailing: Icon(
                      q.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: q.isCorrect
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CountryDetailScreen(country: q.correct),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.home_outlined),
                      label: const Text('Domov'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.replay),
                      label: const Text('Hrať znova'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

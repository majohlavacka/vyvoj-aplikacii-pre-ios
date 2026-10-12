import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../utils/formatters.dart';
import '../widgets/mode_card.dart';
import '../widgets/stat_card.dart';

/// História odohraných hier (uložená v SharedPreferences).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vymazať históriu?'),
        content: const Text('Všetky uložené výsledky sa natrvalo odstránia.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Zrušiť'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Vymazať'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<HistoryProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<HistoryProvider>();
    final results = history.results;
    final best = history.bestResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('História hier'),
        actions: [
          IconButton(
            tooltip: 'Vymazať históriu',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: results.isEmpty ? null : () => _confirmClear(context),
          ),
        ],
      ),
      body: results.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Zatiaľ tu nie sú žiadne hry. Odohraj prvú a výsledok sa uloží sem.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Odohrané hry',
                          value: '${history.gamesPlayed}',
                          icon: Icons.sports_esports_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Priemerná úspešnosť',
                          value: '${history.averagePercent} %',
                          icon: Icons.percent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          label: 'Najlepšia hra',
                          value: best == null ? '–' : '${best.percentRounded} %',
                          icon: Icons.emoji_events_outlined,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = results[index];
                      final good = r.percent >= 0.6;
                      return ListTile(
                        leading: CircleAvatar(child: Icon(modeIcon(r.mode))),
                        title: Text('${r.playerName}, ${r.mode.title}'),
                        subtitle: Text(formatDate(r.date)),
                        trailing: Text(
                          '${r.score}/${r.total}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: good
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

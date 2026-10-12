import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../providers/countries_provider.dart';
import '../providers/game_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/mode_card.dart';
import 'countries_list_screen.dart';
import 'game_screen.dart';
import 'history_screen.dart';

/// 1. obrazovka – formulár (meno hráča), výber režimu a počtu otázok.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final HistoryProvider _history;

  GameMode _selectedMode = GameMode.flag;
  int _questionCount = 10;
  static const _countOptions = [5, 10, 15, 20];

  @override
  void initState() {
    super.initState();
    // Predvyplnenie mena z lokálneho úložiska.
    _history = context.read<HistoryProvider>();
    if (_history.isLoaded) {
      _nameController.text = _history.lastPlayerName;
    } else {
      _history.addListener(_onHistoryLoaded);
    }
  }

  void _onHistoryLoaded() {
    if (!_history.isLoaded) return;
    _history.removeListener(_onHistoryLoaded);
    if (_nameController.text.isEmpty) {
      _nameController.text = _history.lastPlayerName;
    }
  }

  @override
  void dispose() {
    _history.removeListener(_onHistoryLoaded);
    _nameController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Zadaj svoje meno';
    if (name.length < 2) return 'Meno musí mať aspoň 2 znaky';
    if (name.length > 20) return 'Meno môže mať najviac 20 znakov';
    return null;
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startGame() async {
    if (!_formKey.currentState!.validate()) return;

    final countries = context.read<CountriesProvider>();
    if (!countries.isLoaded) {
      _showSnack('Krajiny sa ešte načítavajú, chvíľu počkaj.');
      return;
    }

    final name = _nameController.text.trim();
    FocusScope.of(context).unfocus();
    await _history.rememberPlayer(name);
    if (!mounted) return;

    final game = context.read<GameProvider>();
    game.startGame(
      countries: countries.countries,
      mode: _selectedMode,
      questionCount: _questionCount,
      playerName: name,
    );
    if (!game.hasGame) {
      _showSnack('Pre tento režim nie je dosť krajín.');
      return;
    }

    // Navigator.push vracia hodnotu, ktorú GameScreen pošle cez Navigator.pop.
    final result = await Navigator.push<GameResult>(
      context,
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
    if (!mounted || result == null) return;
    _showSnack(
      '${result.playerName}, máš ${result.score}/${result.total} bodov '
      '(${result.percentRounded} %). Výsledok je uložený v histórii.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final countries = context.watch<CountriesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hádaj krajinu'),
        actions: [
          IconButton(
            tooltip: 'Atlas krajín',
            icon: const Icon(Icons.public),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CountriesListScreen()),
            ),
          ),
          IconButton(
            tooltip: 'História hier',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;
            final settings = _buildSettings(context);
            final modes = _buildModes(context);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _DataStatusBanner(),
                      const SizedBox(height: 16),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: settings),
                            const SizedBox(width: 24),
                            Expanded(child: modes),
                          ],
                        )
                      else ...[
                        settings,
                        const SizedBox(height: 24),
                        modes,
                      ],
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: countries.isLoaded ? _startGame : null,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text(
                            'Začať hru',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettings(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final best = context.watch<HistoryProvider>().bestFor(_selectedMode);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Koľko krajín sveta spoznáš?',
            style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Zadaj meno, vyber režim a počet otázok. Každá otázka má štyri možnosti.',
            style: text.bodyMedium,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            validator: _validateName,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            decoration: const InputDecoration(
              labelText: 'Meno hráča',
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (_) => _startGame(),
          ),
          const SizedBox(height: 12),
          Text('Počet otázok', style: text.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              segments: [
                for (final count in _countOptions)
                  ButtonSegment(value: count, label: Text('$count')),
              ],
              selected: {_questionCount},
              onSelectionChanged: (selection) =>
                  setState(() => _questionCount = selection.first),
            ),
          ),
          const SizedBox(height: 16),
          if (best != null)
            Row(
              children: [
                const Icon(Icons.emoji_events_outlined, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tvoj najlepší výsledok v režime ${_selectedMode.title}: '
                    '${best.score}/${best.total} (${best.percentRounded} %)',
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildModes(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Herný režim', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final mode in GameMode.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ModeCard(
              mode: mode,
              selected: mode == _selectedMode,
              // callback: dieťa (ModeCard) oznámi výber rodičovi
              onTap: () => setState(() => _selectedMode = mode),
            ),
          ),
      ],
    );
  }
}

/// Stav načítania dát z API / cache.
class _DataStatusBanner extends StatelessWidget {
  const _DataStatusBanner();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountriesProvider>();
    final scheme = Theme.of(context).colorScheme;

    if (provider.isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Načítavam krajiny z apicountries.com…'),
              SizedBox(height: 12),
              LinearProgressIndicator(),
            ],
          ),
        ),
      );
    }

    if (provider.status == LoadStatus.error) {
      return Card(
        color: scheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.wifi_off, color: scheme.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  provider.errorMessage ?? 'Chyba pri načítaní.',
                  style: TextStyle(color: scheme.onErrorContainer),
                ),
              ),
              TextButton(
                onPressed: () => provider.loadCountries(forceRefresh: true),
                child: const Text('Skúsiť znova'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.isLoaded) {
      final source = provider.isFromCache ? 'z lokálneho úložiska' : 'z API';
      return Row(
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: scheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Pripravených ${provider.countries.length} krajín ($source)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

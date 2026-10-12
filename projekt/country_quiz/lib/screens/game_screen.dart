import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/country.dart';
import '../models/question.dart';
import '../providers/game_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/answer_button.dart';
import '../widgets/question_view.dart';
import 'result_screen.dart';

/// 2. obrazovka – samotná hra.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _finishing = false;

  Future<bool> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ukončiť hru?'),
        content: const Text('Rozohraná hra sa neuloží do histórie.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hrať ďalej'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ukončiť'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _onNext(GameProvider game) async {
    if (!game.isLastQuestion) {
      game.nextQuestion();
      return;
    }
    await _finishGame(game);
  }

  Future<void> _finishGame(GameProvider game) async {
    if (_finishing) return;
    _finishing = true;

    final result = game.buildResult();
    final questions = game.questions;
    await context.read<HistoryProvider>().addResult(result);
    if (!mounted) return;

    // Dáta odovzdávame do ResultScreen cez konštruktor,
    // späť dostaneme bool: true = hrať znova, false/null = domov.
    final playAgain = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(result: result, questions: questions),
      ),
    );
    if (!mounted) return;
    _finishing = false;

    if (playAgain == true) {
      game.restart();
    } else {
      Navigator.pop(context, result); // výsledok sa vráti na HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final question = game.currentQuestion;

    if (question == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hra nie je pripravená.')),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await _confirmExit();
        if (leave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Otázka ${game.currentIndex + 1} z ${game.total}'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: const Icon(Icons.star_rounded, size: 18),
                label: Text('${game.score}'),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: LinearProgressIndicator(value: game.progress),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final prompt = QuestionView(question: question, mode: game.mode);
                final answers = _AnswersPanel(
                  question: question,
                  isLast: game.isLastQuestion,
                  onAnswer: game.answer,
                  onNext: () => _onNext(game),
                );

                if (isWide) {
                  // široká obrazovka / tablet / landscape
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: prompt),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: SingleChildScrollView(child: answers),
                        ),
                      ),
                    ],
                  );
                }
                // úzka obrazovka / telefón
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: prompt),
                    const SizedBox(height: 16),
                    answers,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Mriežka 2×2 s odpoveďami + spätná väzba a tlačidlo "Ďalej".
class _AnswersPanel extends StatelessWidget {
  const _AnswersPanel({
    required this.question,
    required this.isLast,
    required this.onAnswer,
    required this.onNext,
  });

  final Question question;
  final bool isLast;
  final ValueChanged<Country> onAnswer;
  final VoidCallback onNext;

  AnswerState _stateFor(Country option) {
    if (!question.isAnswered) return AnswerState.idle;
    if (option.code == question.correct.code) return AnswerState.correct;
    if (option.code == question.selected!.code) return AnswerState.wrong;
    return AnswerState.disabled;
  }

  @override
  Widget build(BuildContext context) {
    final options = question.options;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < options.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                for (var j = i; j < i + 2 && j < options.length; j++) ...[
                  if (j > i) const SizedBox(width: 12),
                  Expanded(
                    child: AnswerButton(
                      label: options[j].name,
                      state: _stateFor(options[j]),
                      onPressed: question.isAnswered
                          ? null
                          : () => onAnswer(options[j]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (question.isAnswered) ...[
          Card(
            elevation: 0,
            color: question.isCorrect
                ? scheme.primaryContainer
                : scheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                question.isCorrect
                    ? 'Správne! ${question.correct.name}'
                        '${question.correct.hasCapital ? ', hlavné mesto ${question.correct.capital}' : ''}.'
                    : 'Nesprávne. Správna odpoveď je ${question.correct.name}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: question.isCorrect
                      ? scheme.onPrimaryContainer
                      : scheme.onErrorContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: onNext,
              icon: Icon(isLast ? Icons.emoji_events : Icons.arrow_forward),
              label: Text(isLast ? 'Zobraziť výsledky' : 'Ďalšia otázka'),
            ),
          ),
        ],
      ],
    );
  }
}

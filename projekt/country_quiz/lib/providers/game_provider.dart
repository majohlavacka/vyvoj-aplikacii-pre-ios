import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/country.dart';
import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../models/question.dart';

/// Stavová vrstva – priebeh jednej hry (otázky, odpovede, skóre).
class GameProvider extends ChangeNotifier {
  GameProvider({Random? random}) : _random = random ?? Random();

  static const int optionsCount = 4;

  final Random _random;

  List<Question> _questions = [];
  int _currentIndex = 0;
  GameMode _mode = GameMode.flag;
  String _playerName = '';
  List<Country> _sourceCountries = [];
  int _requestedCount = 10;

  List<Question> get questions => List.unmodifiable(_questions);
  Question? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];
  int get currentIndex => _currentIndex;
  int get total => _questions.length;
  int get score => _questions.where((q) => q.isCorrect).length;
  bool get hasGame => _questions.isNotEmpty;
  bool get isLastQuestion => _currentIndex >= _questions.length - 1;
  GameMode get mode => _mode;
  String get playerName => _playerName;

  double get progress {
    if (total == 0) return 0;
    final answered = currentQuestion?.isAnswered == true ? 1 : 0;
    return (_currentIndex + answered) / total;
  }

  /// Či sa krajina dá použiť v danom režime (napr. má hlavné mesto).
  static bool isPlayable(Country c, GameMode mode) => switch (mode) {
        GameMode.flag => c.flagUrl.isNotEmpty,
        GameMode.capital => c.hasCapital,
        GameMode.map => c.hasLocation,
      };

  void startGame({
    required List<Country> countries,
    required GameMode mode,
    required int questionCount,
    required String playerName,
  }) {
    _sourceCountries = countries;
    _mode = mode;
    _requestedCount = questionCount;
    _playerName = playerName;
    _generateQuestions();
    notifyListeners();
  }

  /// Nová hra s rovnakými nastaveniami.
  void restart() {
    _generateQuestions();
    notifyListeners();
  }

  void _generateQuestions() {
    final pool = _sourceCountries.where((c) => isPlayable(c, _mode)).toList()
      ..shuffle(_random);
    _currentIndex = 0;
    if (pool.length < optionsCount) {
      _questions = [];
      return;
    }
    final picked = pool.take(min(_requestedCount, pool.length));
    _questions = picked
        .map((c) => Question(correct: c, options: _buildOptions(c, pool)))
        .toList();
  }

  /// Nesprávne možnosti berieme prednostne z rovnakého regiónu,
  /// aby hra nebola príliš jednoduchá.
  List<Country> _buildOptions(Country correct, List<Country> pool) {
    final others = pool.where((c) => c.code != correct.code);
    final sameRegion = others.where((c) => c.region == correct.region).toList()
      ..shuffle(_random);
    final otherRegions =
        others.where((c) => c.region != correct.region).toList()
          ..shuffle(_random);
    final wrong = [...sameRegion, ...otherRegions].take(optionsCount - 1);
    return [correct, ...wrong]..shuffle(_random);
  }

  void answer(Country choice) {
    final question = currentQuestion;
    if (question == null || question.isAnswered) return;
    _questions[_currentIndex] = question.answer(choice);
    notifyListeners();
  }

  void nextQuestion() {
    if (isLastQuestion) return;
    _currentIndex++;
    notifyListeners();
  }

  GameResult buildResult() => GameResult(
        playerName: _playerName,
        mode: _mode,
        score: score,
        total: total,
        date: DateTime.now(),
      );
}

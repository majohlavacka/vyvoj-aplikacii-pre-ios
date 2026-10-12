import 'country.dart';

/// Jedna otázka kvízu: správna krajina + ponúknuté možnosti.
/// Model je nemenný – po odpovedi vznikne nová inštancia cez [answer].
class Question {
  const Question({
    required this.correct,
    required this.options,
    this.selected,
  });

  final Country correct;
  final List<Country> options;
  final Country? selected;

  bool get isAnswered => selected != null;
  bool get isCorrect => selected != null && selected!.code == correct.code;

  Question answer(Country choice) =>
      Question(correct: correct, options: options, selected: choice);
}

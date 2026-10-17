import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:english_words/english_words.dart' as words;
import 'wordle.dart';

class HurdleProvider extends ChangeNotifier {
  // Generator nahodnych cisel (vyber cieloveho slova)
  final random = Random.secure();

  // Vsetky 5-pismenove slova
  List<String> totalWords = [];

  // Pismena v aktualnom riadku
  List<String> rowInputs = [];

  // Pismena, ktore nie su v cielovom slove
  List<String> excludedLetters = [];

  // Herne pole: 30 policok (6 riadkov x 5 pismen)
  List<Wordle> hurdleBoard = [];

  // Cielove slovo
  String targetWord = '';

  int count = 0; // pocet pismen v aktualnom riadku
  int index = 0; // pozicia v mriezke
  final int lettersPerRow = 5;

  final int totalAttempts = 6;
  int attempts = 0;
  bool wins = false;

  // ------------------------- GETTERY -------------------------
  bool get isValidWord =>
      totalWords.contains(rowInputs.join('').toLowerCase());

  bool get shouldCheckForAnswer => rowInputs.length == lettersPerRow;

  bool get noAttemptsLeft => attempts == totalAttempts;

  // ------------------------- INICIALIZACIA -------------------------
  void init() {
    totalWords = words.all.where((element) => element.length == 5).toList();
    generateBoard();
    generateRandomWord();
  }

  void generateBoard() {
    hurdleBoard = List.generate(30, (index) => Wordle(letter: ''));
  }

  void generateRandomWord() {
    targetWord = totalWords[random.nextInt(totalWords.length)].toUpperCase();
    debugPrint(targetWord);
  }

  // ------------------------- VSTUP -------------------------
  void inputLetter(String letter) {
    // po skonceni hry sa uz nedaju pridavat pismena
    if (wins || noAttemptsLeft) return;

    if (count < lettersPerRow) {
      rowInputs.add(letter);
      hurdleBoard[index] = Wordle(letter: letter);
      count++;
      index++;
      notifyListeners();
    }
  }

  void deleteLetter() {
    if (rowInputs.isNotEmpty) {
      rowInputs.removeAt(rowInputs.length - 1);
    }

    if (count > 0) {
      hurdleBoard[index - 1] = Wordle(letter: '');
      count--;
      index--;
    }
    notifyListeners();
  }

  // ------------------------- VYHODNOTENIE -------------------------
  void checkAnswer() {
    final input = rowInputs.join('');
    if (targetWord == input) {
      wins = true;
      _markLettersOnBoard();
    } else {
      _markLettersOnBoard();
      if (attempts < totalAttempts) {
        _goToNextRow();
      }
    }
  }

  void _markLettersOnBoard() {
    for (int i = 0; i < hurdleBoard.length; i++) {
      if (hurdleBoard[i].letter.isNotEmpty &&
          targetWord.contains(hurdleBoard[i].letter)) {
        hurdleBoard[i].existsInTarget = true;
      } else if (hurdleBoard[i].letter.isNotEmpty &&
          !targetWord.contains(hurdleBoard[i].letter)) {
        hurdleBoard[i].doesNotExistInTarget = true;
        if (!excludedLetters.contains(hurdleBoard[i].letter)) {
          excludedLetters.add(hurdleBoard[i].letter);
        }
      }
    }
    notifyListeners();
  }

  void _goToNextRow() {
    attempts++;
    count = 0;
    rowInputs.clear();
  }

  // ------------------------- RESTART -------------------------
  void reset() {
    count = 0;
    index = 0;
    rowInputs.clear();
    hurdleBoard.clear();
    excludedLetters.clear();
    attempts = 0;
    wins = false;
    targetWord = '';
    generateBoard();
    generateRandomWord();
    notifyListeners();
  }
}

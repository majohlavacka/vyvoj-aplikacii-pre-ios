import 'package:flutter/material.dart';

import 'data/questions.dart';
import 'questions_screen.dart';
import 'results_screen.dart';
import 'start_screen.dart';

enum QuizScreen { start, questions, results }

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List<String> _selectedAnswers = [];
  QuizScreen _activeScreen = QuizScreen.start;

  void _startQuiz() {
    setState(() {
      _activeScreen = QuizScreen.questions;
    });
  }

  void _chooseAnswer(String answer) {
    _selectedAnswers.add(answer);

    if (_selectedAnswers.length == questions.length) {
      setState(() {
        _activeScreen = QuizScreen.results;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _selectedAnswers = [];
      _activeScreen = QuizScreen.questions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget screenWidget = switch (_activeScreen) {
      QuizScreen.start => StartScreen(onStart: _startQuiz),
      QuizScreen.questions => QuestionsScreen(onSelectAnswer: _chooseAnswer),
      QuizScreen.results => ResultsScreen(
          chosenAnswers: _selectedAnswers,
          onRestart: _restartQuiz,
        ),
    };

    return MaterialApp(
      title: 'Quiz App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1B2A4A),
        body: SafeArea(child: screenWidget),
      ),
    );
  }
}

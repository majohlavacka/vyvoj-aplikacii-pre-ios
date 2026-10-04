class QuizQuestion {
  const QuizQuestion(this.text, this.answers);

  final String text;

  /// Prvá odpoveď v zozname je vždy tá správna.
  final List<String> answers;

  List<String> get shuffledAnswers {
    final shuffledList = List.of(answers);
    shuffledList.shuffle();
    return shuffledList;
  }
}

const questions = [
  // Cestovanie
  QuizQuestion(
    'Ktoré mesto je hlavným mestom Austrálie?',
    ['Canberra', 'Sydney', 'Melbourne', 'Perth'],
  ),
  QuizQuestion(
    'V ktorej krajine sa nachádza Machu Picchu?',
    ['Peru', 'Bolívia', 'Čile', 'Ekvádor'],
  ),
  QuizQuestion(
    'Akou menou sa platí v Japonsku?',
    ['Jen', 'Won', 'Jüan', 'Baht'],
  ),
  QuizQuestion(
    'Ktorý je najvyšší vrch Slovenska?',
    ['Gerlachovský štít', 'Lomnický štít', 'Kriváň', 'Rysy'],
  ),

  // IT
  QuizQuestion(
    'Čo znamená skratka HTML?',
    [
      'HyperText Markup Language',
      'High Transfer Machine Language',
      'Home Tool Markup Language',
      'HyperLink Text Management Logic',
    ],
  ),
  QuizQuestion(
    'Ktorá firma vyvíja Flutter?',
    ['Google', 'Microsoft', 'Meta', 'Apple'],
  ),
  QuizQuestion(
    'Koľko bitov má jeden bajt?',
    ['8', '4', '16', '32'],
  ),
  QuizQuestion(
    'Ktorý príkaz odošle commity do vzdialeného repozitára?',
    ['git push', 'git pull', 'git commit', 'git clone'],
  ),

  // Zaujímavosti
  QuizQuestion(
    'Koľko sŕdc má chobotnica?',
    ['3', '1', '2', '8'],
  ),
  QuizQuestion(
    'Ktoré zviera prespí až okolo 20 hodín denne?',
    ['Koala', 'Mačka', 'Delfín', 'Žirafa'],
  ),
  QuizQuestion(
    'Ktoré z týchto ovocí je z botanického hľadiska bobuľa?',
    ['Banán', 'Jahoda', 'Malina', 'Čerešňa'],
  ),
  QuizQuestion(
    'Koľko nôh má pavúk?',
    ['8', '6', '10', '12'],
  ),
];

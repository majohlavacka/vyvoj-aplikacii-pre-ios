/// Herný režim – podľa čoho hráč háda krajinu.
enum GameMode {
  flag(
    title: 'Vlajka',
    description: 'Uhádni krajinu podľa jej vlajky',
    prompt: 'Ktorej krajine patrí táto vlajka?',
  ),
  capital(
    title: 'Hlavné mesto',
    description: 'Priraď hlavné mesto k správnej krajine',
    prompt: 'Ktorej krajine patrí toto hlavné mesto?',
  ),
  map(
    title: 'Mapa',
    description: 'Rozpoznaj krajinu podľa polohy na mape',
    prompt: 'Ktorá krajina je označená na mape?',
  );

  const GameMode({
    required this.title,
    required this.description,
    required this.prompt,
  });

  final String title;
  final String description;
  final String prompt;

  static GameMode fromName(String? name) => GameMode.values.firstWhere(
        (m) => m.name == name,
        orElse: () => GameMode.flag,
      );
}

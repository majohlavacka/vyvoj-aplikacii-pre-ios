import 'game_mode.dart';

/// Výsledok jednej odohranej hry – ukladá sa do histórie.
class GameResult {
  const GameResult({
    required this.playerName,
    required this.mode,
    required this.score,
    required this.total,
    required this.date,
  });

  final String playerName;
  final GameMode mode;
  final int score;
  final int total;
  final DateTime date;

  double get percent => total == 0 ? 0 : score / total;
  int get percentRounded => (percent * 100).round();

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        playerName: json['playerName'] as String? ?? '',
        mode: GameMode.fromName(json['mode'] as String?),
        score: (json['score'] as num?)?.toInt() ?? 0,
        total: (json['total'] as num?)?.toInt() ?? 0,
        date: DateTime.tryParse(json['date'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'playerName': playerName,
        'mode': mode.name,
        'score': score,
        'total': total,
        'date': date.toIso8601String(),
      };
}

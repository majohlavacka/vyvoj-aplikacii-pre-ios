import 'package:flutter/foundation.dart';

import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../services/storage_service.dart';

/// Stavová vrstva – história hier a meno hráča (trvalo uložené).
class HistoryProvider extends ChangeNotifier {
  HistoryProvider(this._storage);

  final StorageService _storage;

  List<GameResult> _results = [];
  String _lastPlayerName = '';
  bool _loaded = false;

  List<GameResult> get results => List.unmodifiable(_results);
  String get lastPlayerName => _lastPlayerName;
  bool get isLoaded => _loaded;
  int get gamesPlayed => _results.length;

  int get averagePercent {
    if (_results.isEmpty) return 0;
    final sum = _results.fold<double>(0, (acc, r) => acc + r.percent);
    return (sum / _results.length * 100).round();
  }

  GameResult? get bestResult => _best(_results);

  GameResult? bestFor(GameMode mode) =>
      _best(_results.where((r) => r.mode == mode));

  GameResult? _best(Iterable<GameResult> list) {
    if (list.isEmpty) return null;
    return list.reduce((a, b) => b.percent > a.percent ? b : a);
  }

  Future<void> load() async {
    _results = await _storage.loadResults();
    _lastPlayerName = await _storage.loadPlayerName() ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> addResult(GameResult result) async {
    _results.insert(0, result);
    notifyListeners();
    await _storage.saveResults(_results);
  }

  Future<void> rememberPlayer(String name) async {
    _lastPlayerName = name;
    await _storage.savePlayerName(name);
  }

  Future<void> clear() async {
    _results.clear();
    notifyListeners();
    await _storage.saveResults(_results);
  }
}

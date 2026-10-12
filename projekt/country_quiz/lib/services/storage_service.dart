import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/country.dart';
import '../models/game_result.dart';

/// Lokálne ukladanie dát pomocou SharedPreferences.
class StorageService {
  static const _countriesKey = 'countries_cache_v3';
  static const _resultsKey = 'game_results_v1';
  static const _playerKey = 'player_name';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ---------- krajiny (offline cache) ----------

  Future<void> saveCountries(List<Country> countries) async {
    final prefs = await _prefs;
    final encoded = jsonEncode(countries.map((c) => c.toJson()).toList());
    await prefs.setString(_countriesKey, encoded);
  }

  Future<List<Country>?> loadCountries() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_countriesKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Country.fromJson)
          .toList();
    } catch (_) {
      return null; // poškodená cache -> načítame znova z API
    }
  }

  // ---------- história hier ----------

  Future<void> saveResults(List<GameResult> results) async {
    final prefs = await _prefs;
    await prefs.setString(
      _resultsKey,
      jsonEncode(results.map((r) => r.toJson()).toList()),
    );
  }

  Future<List<GameResult>> loadResults() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_resultsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map(GameResult.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ---------- meno hráča ----------

  Future<void> savePlayerName(String name) async {
    final prefs = await _prefs;
    await prefs.setString(_playerKey, name);
  }

  Future<String?> loadPlayerName() async {
    final prefs = await _prefs;
    return prefs.getString(_playerKey);
  }
}

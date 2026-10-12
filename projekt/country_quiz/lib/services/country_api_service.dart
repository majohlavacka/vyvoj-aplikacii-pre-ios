import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/country.dart';
import '../models/country_details.dart';

class CountryApiException implements Exception {
  CountryApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Dátová vrstva – volanie REST API apicountries.com (bez API kľúča).
///
/// Endpointy:
///   GET /countries     – zoznam všetkých krajín
///   GET /alpha/{kód}   – detail jednej krajiny (ISO alpha-2 alebo alpha-3)
///
/// Doména www.apicountries.com presmerúva na countries.dev,
/// preto voláme priamo cieľovú adresu (o jedno presmerovanie menej).
class CountryApiService {
  CountryApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://countries.dev';

  /// GET /countries
  Future<List<Country>> fetchCountries() async {
    final decoded = await _getJson(Uri.parse('$_baseUrl/countries'));
    if (decoded is! List) {
      throw CountryApiException('Neočakávaný formát odpovede');
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Country.fromApiJson)
        .where((c) => c.code.isNotEmpty && c.name.isNotEmpty)
        .toList();
  }

  /// GET /alpha/{kód}
  Future<CountryDetails> fetchDetails(String code) async {
    final decoded = await _getJson(
      Uri.parse('$_baseUrl/alpha/${Uri.encodeComponent(code)}'),
    );
    // Endpoint vracia objekt, pre istotu zvládneme aj zoznam.
    final Object? data =
        decoded is List && decoded.isNotEmpty ? decoded.first : decoded;
    if (data is! Map<String, dynamic>) {
      throw CountryApiException('Neočakávaný formát odpovede');
    }
    return CountryDetails.fromJson(data);
  }

  /// Spoločná časť: HTTP GET + kontrola stavu + dekódovanie JSON.
  Future<dynamic> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw CountryApiException('API nie je dostupné ($e)');
    }

    if (response.statusCode == 404) {
      throw CountryApiException('Požadované dáta sa v API nenašli');
    }
    if (response.statusCode != 200) {
      throw CountryApiException('API vrátilo chybu ${response.statusCode}');
    }

    // bodyBytes + utf8 kvôli správnym znakom (napr. "Brasília")
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}

/// Doplňujúce údaje o krajine z REST API apicountries.com
/// (endpoint /alpha/{kód}). Načítavajú sa až pri otvorení detailu.
class CountryDetails {
  const CountryDetails({
    required this.population,
    required this.subregion,
    required this.languages,
    required this.borders,
    required this.timezones,
    required this.callingCodes,
    this.populationDensity,
  });

  final int population;
  final String subregion;
  final List<String> languages;

  /// Kódy susedných krajín (ISO alpha-3), napr. ["AUT", "CZE"].
  final List<String> borders;
  final List<String> timezones;
  final List<String> callingCodes;
  final double? populationDensity;

  factory CountryDetails.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic value) =>
        (value as List?)?.whereType<String>().where((s) => s.isNotEmpty).toList() ??
        <String>[];

    final languages = (json['languages'] as List?)
            ?.whereType<Map>()
            .map((l) => l['name'] as String? ?? '')
            .where((name) => name.isNotEmpty)
            .toList() ??
        <String>[];

    return CountryDetails(
      population: (json['population'] as num?)?.toInt() ?? 0,
      subregion: json['subregion'] as String? ?? '',
      languages: languages,
      borders: strings(json['borders']),
      timezones: strings(json['timezones']),
      callingCodes: strings(json['callingCodes']),
      populationDensity: (json['populationDensity'] as num?)?.toDouble(),
    );
  }
}

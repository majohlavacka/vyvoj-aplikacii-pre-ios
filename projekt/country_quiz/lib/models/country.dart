/// Vlastný dátový model krajiny.
///
/// [Country.fromApiJson] spracuje odpoveď z apicountries.com (GET /countries),
/// [Country.fromJson] / [toJson] slúžia na lokálne ukladanie (cache).
class Country {
  const Country({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.capital,
    required this.region,
    required this.area,
    required this.flagUrl,
    required this.currencies,
    this.latitude,
    this.longitude,
  });

  /// Trojpísmenový kód ISO 3166-1 alpha-3 (napr. SVK).
  final String code;
  final String name;

  /// Názov v domácom jazyku (napr. "Slovensko").
  final String nativeName;
  final String capital;
  final String region;

  /// Rozloha v km².
  final double area;
  final String flagUrl;
  final List<String> currencies;
  final double? latitude;
  final double? longitude;

  bool get hasCapital => capital.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;

  factory Country.fromApiJson(Map<String, dynamic> json) {
    final latlng = (json['latlng'] as List?)
            ?.whereType<num>()
            .map((e) => e.toDouble())
            .toList() ??
        <double>[];

    final currencies = (json['currencies'] as List?)
            ?.whereType<Map>()
            .map((c) {
              final code = c['code'] as String? ?? '';
              final name = c['name'] as String? ?? code;
              final symbol = c['symbol'] as String?;
              return symbol == null ? '$name ($code)' : '$name ($code, $symbol)';
            })
            .toList() ??
        <String>[];

    // Vlajky jednotne z flagcdn.com podľa dvojpísmenového kódu,
    // ak kód chýba, použijeme URL priamo z API.
    final alpha2 = (json['alpha2Code'] as String? ?? '').toLowerCase();
    final apiFlag = (json['flags'] as Map?)?['png'] as String? ?? '';

    return Country(
      code: json['alpha3Code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nativeName: json['nativeName'] as String? ?? '',
      capital: json['capital'] as String? ?? '',
      region: json['region'] as String? ?? '',
      area: (json['area'] as num?)?.toDouble() ?? 0,
      flagUrl:
          alpha2.isNotEmpty ? 'https://flagcdn.com/w320/$alpha2.png' : apiFlag,
      currencies: currencies,
      latitude: latlng.length >= 2 ? latlng[0] : null,
      longitude: latlng.length >= 2 ? latlng[1] : null,
    );
  }

  /// Načítanie z lokálnej cache (SharedPreferences).
  factory Country.fromJson(Map<String, dynamic> json) => Country(
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? '',
        nativeName: json['nativeName'] as String? ?? '',
        capital: json['capital'] as String? ?? '',
        region: json['region'] as String? ?? '',
        area: (json['area'] as num?)?.toDouble() ?? 0,
        flagUrl: json['flagUrl'] as String? ?? '',
        currencies: (json['currencies'] as List?)
                ?.whereType<String>()
                .toList() ??
            <String>[],
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'nativeName': nativeName,
        'capital': capital,
        'region': region,
        'area': area,
        'flagUrl': flagUrl,
        'currencies': currencies,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  bool operator ==(Object other) => other is Country && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Country($code, $name)';
}

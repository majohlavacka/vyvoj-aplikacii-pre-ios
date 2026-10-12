import 'package:flutter/foundation.dart';

import '../models/country.dart';
import '../models/country_details.dart';
import '../services/country_api_service.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';

enum LoadStatus { initial, loading, loaded, error }

/// Stavová vrstva – zoznam krajín, načítanie, vyhľadávanie a filter.
class CountriesProvider extends ChangeNotifier {
  CountriesProvider(this._api, this._storage);

  final CountryApiService _api;
  final StorageService _storage;

  /// Už stiahnuté detaily – pri opätovnom otvorení sa API nevolá znova.
  final Map<String, CountryDetails> _detailsCache = {};

  List<Country> _countries = [];
  LoadStatus _status = LoadStatus.initial;
  String? _errorMessage;
  bool _fromCache = false;
  String _search = '';
  String? _region;

  List<Country> get countries => List.unmodifiable(_countries);
  LoadStatus get status => _status;
  bool get isLoading => _status == LoadStatus.loading;
  bool get isLoaded => _status == LoadStatus.loaded && _countries.isNotEmpty;
  String? get errorMessage => _errorMessage;
  bool get isFromCache => _fromCache;
  String get search => _search;
  String? get selectedRegion => _region;

  List<String> get regions {
    final set = _countries.map((c) => c.region).where((r) => r.isNotEmpty);
    return set.toSet().toList()..sort();
  }

  List<Country> get filteredCountries {
    final query = normalize(_search.trim());
    return _countries.where((c) {
      final regionOk = _region == null || c.region == _region;
      final searchOk = query.isEmpty ||
          normalize(c.name).contains(query) ||
          normalize(c.capital).contains(query) ||
          normalize(c.nativeName).contains(query);
      return regionOk && searchOk;
    }).toList();
  }

  Country? countryByCode(String code) {
    for (final c in _countries) {
      if (c.code == code) return c;
    }
    return null;
  }

  /// Volanie REST API pre detail jednej krajiny (s pamäťovou cache).
  Future<CountryDetails> loadDetails(String code) async {
    final cached = _detailsCache[code];
    if (cached != null) return cached;
    final details = await _api.fetchDetails(code);
    _detailsCache[code] = details;
    return details;
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setRegion(String? region) {
    _region = region;
    notifyListeners();
  }

  /// Najprv skúsi lokálnu cache, inak (alebo pri [forceRefresh]) volá API.
  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (isLoading) return;
    _status = LoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    if (!forceRefresh) {
      final cached = await _storage.loadCountries();
      if (cached != null && cached.isNotEmpty) {
        _countries = cached;
        _fromCache = true;
        _status = LoadStatus.loaded;
        notifyListeners();
        return;
      }
    }

    try {
      final fetched = await _api.fetchCountries();
      fetched.sort((a, b) => normalize(a.name).compareTo(normalize(b.name)));
      _countries = fetched;
      _fromCache = false;
      _status = LoadStatus.loaded;
      await _storage.saveCountries(fetched);
    } catch (e) {
      if (_countries.isNotEmpty) {
        _status = LoadStatus.loaded;
        _errorMessage = 'Obnova zlyhala, zobrazujem uložené dáta.';
      } else {
        _status = LoadStatus.error;
        _errorMessage =
            'Krajiny sa nepodarilo načítať. Skontroluj pripojenie na internet.\n$e';
      }
    }
    notifyListeners();
  }
}

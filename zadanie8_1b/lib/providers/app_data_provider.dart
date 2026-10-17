import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

import '../models/earthquake_model.dart';
import '../utils/helper_functions.dart';

class AppDataProvider with ChangeNotifier {
  final Uri _baseUrl =
      Uri.parse('https://earthquake.usgs.gov/fdsnws/event/1/query');
  Map<String, dynamic> _queryParams = {};
  double _maxRadiusKm = 500.0;
  final double _latitude = 0.0;
  final double _longitude = 0.0;
  String _startTime = '';
  String _endTime = '';
  String _orderBy = 'time'; // predvolene triedenie podla casu
  String? _currentCity;
  final double _maxRadiusThreshold = 20001.6; // max. hodnota podla dokumentacie
  final bool _shouldUseLocation = false;
  EarthquakeModel? _earthquakeModel;

  // ------------------------- GETTERY -------------------------
  double get maxRadiusKm => _maxRadiusKm;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get startTime => _startTime;
  String get endTime => _endTime;
  String get orderBy => _orderBy;
  String? get currentCity => _currentCity;
  double get maxRadiusThreshold => _maxRadiusThreshold;
  bool get shouldUseLocation => _shouldUseLocation;
  EarthquakeModel? get earthquakeModel => _earthquakeModel;

  bool get hasDataLoaded => _earthquakeModel != null;

  // ------------------------- PARAMETRE DOTAZU -------------------------
  void _setQueryParams() {
    _queryParams = {
      'format': 'geojson',
      'starttime': _startTime,
      'endtime': _endTime,
      'minmagnitude': '4',
      'orderby': _orderBy,
      'limit': '500',
    };
    // Poloha sa posiela iba vtedy, ked ju chceme pouzit.
    // Inak by sa hladalo len okolo bodu 0,0 a zoznam by bol casto prazdny.
    if (_shouldUseLocation) {
      _queryParams['latitude'] = '$_latitude';
      _queryParams['longitude'] = '$_longitude';
      _queryParams['maxradiuskm'] = '$_maxRadiusKm';
    }
  }

  // ------------------------- INICIALIZACIA -------------------------
  void init() {
    final now = DateTime.now();
    final earlier = now.subtract(const Duration(days: 10));
    _startTime = getFormattedDateTime(earlier.millisecondsSinceEpoch);
    _endTime = getFormattedDateTime(now.millisecondsSinceEpoch);
    _maxRadiusKm = _maxRadiusThreshold;
    _setQueryParams();
    getEarthquakeData();
  }

  // ------------------------- NACITANIE DAT Z API -------------------------
  Future<void> getEarthquakeData() async {
    final uri = Uri.https(_baseUrl.authority, _baseUrl.path, _queryParams);
    EasyLoading.show(status: 'Loading...');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        _earthquakeModel = EarthquakeModel.fromJson(json);
        debugPrint('Pocet zemetraseni: ${_earthquakeModel!.features!.length}');
        EasyLoading.dismiss();
        notifyListeners();
      } else {
        debugPrint('Chyba servera: ${response.statusCode}');
        EasyLoading.showError('Server error ${response.statusCode}');
      }
    } catch (error) {
      debugPrint(error.toString());
      EasyLoading.showError('Could not load data');
    }
  }

  // ------------------------- FARBA PODLA ALERTU -------------------------
  Color getAlertColor(String color) {
    return switch (color) {
      'green' => Colors.green,
      'yellow' => Colors.yellow,
      'orange' => Colors.orange,
      _ => Colors.red,
    };
  }

  // ------------------------- TRIEDENIE -------------------------
  void setOrder(String value) {
    _orderBy = value;
    notifyListeners();
    _setQueryParams();
    getEarthquakeData();
  }

  // ------------------------- DATUMY -------------------------
  void setStartTime(String date) {
    _startTime = date;
    _setQueryParams();
    notifyListeners();
  }

  void setEndTime(String date) {
    _endTime = date;
    _setQueryParams();
    notifyListeners();
  }
}

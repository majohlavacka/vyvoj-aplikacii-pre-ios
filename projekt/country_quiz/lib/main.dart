import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/countries_provider.dart';
import 'providers/game_provider.dart';
import 'providers/history_provider.dart';
import 'screens/home_screen.dart';
import 'services/country_api_service.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  final api = CountryApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CountriesProvider(api, storage)..loadCountries(),
        ),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(storage)..load(),
        ),
      ],
      child: const CountryQuizApp(),
    ),
  );
}

class CountryQuizApp extends StatelessWidget {
  const CountryQuizApp({super.key});

  static const _seed = Color(0xFF1B6B73); // "atlasová" morská modrozelená

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hádaj krajinu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seed,
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/country.dart';
import '../providers/countries_provider.dart';
import '../utils/formatters.dart';
import '../widgets/country_tile.dart';
import 'country_detail_screen.dart';

/// Atlas – zoznam všetkých krajín s vyhľadávaním a filtrom kontinentu.
class CountriesListScreen extends StatefulWidget {
  const CountriesListScreen({super.key});

  @override
  State<CountriesListScreen> createState() => _CountriesListScreenState();
}

class _CountriesListScreenState extends State<CountriesListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: context.read<CountriesProvider>().search,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Country country) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CountryDetailScreen(country: country)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CountriesProvider>();
    final list = provider.filteredCountries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas krajín'),
        actions: [
          IconButton(
            tooltip: 'Stiahnuť znova z API',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading
                ? null
                : () => provider.loadCountries(forceRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearch,
              decoration: InputDecoration(
                hintText: 'Hľadaj krajinu alebo hlavné mesto',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.setSearch('');
                        },
                      ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _regionChip(provider, null, 'Všetky'),
                for (final region in provider.regions)
                  _regionChip(provider, region, regionLabel(region)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Zobrazené krajiny: ${list.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (provider.isFromCache)
                  Text(
                    'offline dáta',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          Expanded(child: _buildList(provider, list)),
        ],
      ),
    );
  }

  Widget _regionChip(CountriesProvider provider, String? region, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: provider.selectedRegion == region,
        onSelected: (_) => provider.setRegion(region),
      ),
    );
  }

  Widget _buildList(CountriesProvider provider, List<Country> list) {
    if (provider.countries.isEmpty && provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.countries.isEmpty && provider.status == LoadStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.errorMessage ?? 'Chyba', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => provider.loadCountries(forceRefresh: true),
                child: const Text('Skúsiť znova'),
              ),
            ],
          ),
        ),
      );
    }
    if (list.isEmpty) {
      return const Center(child: Text('Žiadna krajina nezodpovedá hľadaniu.'));
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCountries(forceRefresh: true),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => CountryTile(
          country: list[index],
          onTap: _openDetail, // callback s odovzdaním objektu Country
        ),
      ),
    );
  }
}

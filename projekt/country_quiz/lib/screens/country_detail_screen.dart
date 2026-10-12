import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/country.dart';
import '../models/country_details.dart';
import '../providers/countries_provider.dart';
import '../utils/formatters.dart';
import '../widgets/country_map.dart';
import '../widgets/flag_image.dart';
import '../widgets/info_row.dart';

/// Detail krajiny – objekt Country prichádza cez konštruktor,
/// doplňujúce údaje sa načítajú z REST API (GET /alpha/{kód}).
class CountryDetailScreen extends StatefulWidget {
  const CountryDetailScreen({super.key, required this.country});

  final Country country;

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  late Future<CountryDetails> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    _detailsFuture =
        context.read<CountriesProvider>().loadDetails(widget.country.code);
  }

  void _retry() => setState(_loadDetails);

  void _openNeighbor(Country neighbor) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CountryDetailScreen(country: neighbor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final country = widget.country;

    return Scaffold(
      appBar: AppBar(title: Text(country.name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;

          final flag = Center(
            child: Hero(
              tag: 'flag-${country.code}',
              child: FlagImage(
                url: country.flagUrl,
                height: 160,
                borderRadius: 12,
              ),
            ),
          );
          final info = _InfoCard(country: country);
          final apiCard = _ApiDetailsCard(
            future: _detailsFuture,
            onRetry: _retry,
            onNeighborTap: _openNeighbor, // callback s objektom Country
          );
          final map = _MapCard(country: country);

          if (isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        flag,
                        const SizedBox(height: 16),
                        info,
                        const SizedBox(height: 16),
                        apiCard,
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(child: map),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              flag,
              const SizedBox(height: 16),
              info,
              const SizedBox(height: 16),
              apiCard,
              const SizedBox(height: 16),
              map,
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InfoRow(
              icon: Icons.badge_outlined,
              label: 'Názov v domácom jazyku',
              value: country.nativeName.isEmpty ? '–' : country.nativeName,
            ),
            InfoRow(
              icon: Icons.location_city,
              label: 'Hlavné mesto',
              value: country.hasCapital ? country.capital : 'neuvedené',
            ),
            InfoRow(
              icon: Icons.public,
              label: 'Kontinent',
              value: regionLabel(country.region),
            ),
            InfoRow(
              icon: Icons.square_foot,
              label: 'Rozloha',
              value: '${formatNumber(country.area.round())} km²',
            ),
            InfoRow(
              icon: Icons.payments_outlined,
              label: 'Mena',
              value: country.currencies.isEmpty
                  ? 'neuvedená'
                  : country.currencies.join('\n'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Karta s údajmi z REST API – stav načítania rieši FutureBuilder.
class _ApiDetailsCard extends StatelessWidget {
  const _ApiDetailsCard({
    required this.future,
    required this.onRetry,
    required this.onNeighborTap,
  });

  final Future<CountryDetails> future;
  final VoidCallback onRetry;
  final ValueChanged<Country> onNeighborTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<CountryDetails>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Načítavam ďalšie údaje z API…'),
                  SizedBox(height: 12),
                  LinearProgressIndicator(),
                ],
              );
            }

            if (snapshot.hasError) {
              return Row(
                children: [
                  Icon(Icons.cloud_off, color: scheme.error),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ďalšie údaje sa nepodarilo načítať.\n${snapshot.error}',
                    ),
                  ),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Skúsiť znova'),
                  ),
                ],
              );
            }

            final details = snapshot.data!;
            final countries = context.read<CountriesProvider>();
            final neighbors = details.borders
                .map(countries.countryByCode)
                .whereType<Country>()
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Údaje z apicountries.com',
                  style: text.labelMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                InfoRow(
                  icon: Icons.groups_outlined,
                  label: 'Počet obyvateľov',
                  value: formatNumber(details.population),
                ),
                if (details.populationDensity != null)
                  InfoRow(
                    icon: Icons.density_medium,
                    label: 'Hustota obyvateľstva',
                    value:
                        '${details.populationDensity!.toStringAsFixed(1)} obyv./km²',
                  ),
                if (details.subregion.isNotEmpty)
                  InfoRow(
                    icon: Icons.travel_explore,
                    label: 'Podregión',
                    value: details.subregion,
                  ),
                if (details.languages.isNotEmpty)
                  InfoRow(
                    icon: Icons.translate,
                    label: 'Jazyky',
                    value: details.languages.join(', '),
                  ),
                if (details.callingCodes.isNotEmpty)
                  InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Telefónna predvoľba',
                    value: details.callingCodes.map((c) => '+$c').join(', '),
                  ),
                if (details.timezones.isNotEmpty)
                  InfoRow(
                    icon: Icons.schedule,
                    label: 'Časové pásma',
                    value: details.timezones.join(', '),
                  ),
                const SizedBox(height: 8),
                Text('Susedné krajiny', style: text.titleSmall),
                const SizedBox(height: 8),
                if (neighbors.isEmpty)
                  const Text('Žiadne pozemné hranice.')
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final neighbor in neighbors)
                        ActionChip(
                          avatar: FlagImage(
                            url: neighbor.flagUrl,
                            width: 24,
                            height: 16,
                            borderRadius: 2,
                          ),
                          label: Text(neighbor.name),
                          onPressed: () => onNeighborTap(neighbor),
                        ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  const _MapCard({required this.country});

  final Country country;

  @override
  Widget build(BuildContext context) {
    if (!country.hasLocation) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Poloha krajiny nie je k dispozícii.'),
        ),
      );
    }
    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CountryMap(
          latitude: country.latitude!,
          longitude: country.longitude!,
          zoom: 4,
        ),
      ),
    );
  }
}

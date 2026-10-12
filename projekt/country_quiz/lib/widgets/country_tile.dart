import 'package:flutter/material.dart';

import '../models/country.dart';
import '../utils/formatters.dart';
import 'flag_image.dart';

/// Riadok zoznamu krajín. Po kliknutí odovzdá krajinu cez callback [onTap].
class CountryTile extends StatelessWidget {
  const CountryTile({super.key, required this.country, required this.onTap});

  final Country country;
  final ValueChanged<Country> onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (country.hasCapital) country.capital,
      regionLabel(country.region),
    ].join(', ');

    return ListTile(
      leading: Hero(
        tag: 'flag-${country.code}',
        child: FlagImage(
          url: country.flagUrl,
          width: 56,
          height: 36,
          borderRadius: 4,
        ),
      ),
      title: Text(country.name),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => onTap(country),
    );
  }
}

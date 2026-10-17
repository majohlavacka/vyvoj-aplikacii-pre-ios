import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data_provider.dart';
import '../settings_page.dart';
import '../utils/helper_functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _initialized = false; // aby sa init() zavolal iba raz

  @override
  void didChangeDependencies() {
    if (!_initialized) {
      Provider.of<AppDataProvider>(context, listen: false).init();
      _initialized = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake App'),
        actions: [
          IconButton(
            onPressed: _showSortingDialog,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          // 1. Data sa este nacitavaju
          if (!provider.hasDataLoaded) {
            return const Center(child: Text('Please wait...'));
          }

          // 2. Data su nacitane, ale zoznam je prazdny
          if (provider.earthquakeModel!.features!.isEmpty) {
            return const Center(child: Text('No records found.'));
          }

          // 3. Zoznam zemetraseni
          return ListView.builder(
            itemCount: provider.earthquakeModel!.features!.length,
            itemBuilder: (context, index) {
              final data =
                  provider.earthquakeModel!.features![index].properties!;
              return ListTile(
                title: Text(data.place ?? data.title ?? 'Unknown'),
                subtitle: Text(
                  data.time == null
                      ? '-'
                      : getFormattedDateTime(
                          data.time!, 'EEE MMM dd yyyy hh:mm a'),
                ),
                trailing: Chip(
                  avatar: data.alert == null
                      ? null
                      : CircleAvatar(
                          backgroundColor: provider.getAlertColor(data.alert!),
                        ),
                  label: Text('${data.mag ?? '-'}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSortingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Consumer<AppDataProvider>(
          builder: (context, provider, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SortRadioItem(
                groupValue: provider.orderBy,
                value: 'magnitude',
                label: 'Magnitude-Desc',
                onChange: (value) => provider.setOrder(value),
              ),
              SortRadioItem(
                groupValue: provider.orderBy,
                value: 'magnitude-asc',
                label: 'Magnitude-Asc',
                onChange: (value) => provider.setOrder(value),
              ),
              SortRadioItem(
                groupValue: provider.orderBy,
                value: 'time',
                label: 'Time-Desc',
                onChange: (value) => provider.setOrder(value),
              ),
              SortRadioItem(
                groupValue: provider.orderBy,
                value: 'time-asc',
                label: 'Time-Asc',
                onChange: (value) => provider.setOrder(value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Jedna moznost v dialogu triedenia (vlastny "radio" riadok).
// Nazov SortRadioItem, aby nevznikol konflikt s RadioGroup z Fluttera.
class SortRadioItem extends StatelessWidget {
  final String groupValue;
  final String value;
  final String label;
  final Function(String) onChange;

  const SortRadioItem({
    super.key,
    required this.groupValue,
    required this.value,
    required this.label,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(label),
      onTap: () => onChange(value),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mapa s vyznačenou polohou krajiny (OpenStreetMap, bez API kľúča).
///
/// V hre používame podklad BEZ popisov ([showLabels] = false),
/// aby mapa neprezradila správnu odpoveď – satelitná mapa Esri World Imagery
/// (bez API kľúča, bez názvov krajín a miest).
class CountryMap extends StatelessWidget {
  const CountryMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 4,
    this.showLabels = true,
    this.interactive = true,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final bool showLabels;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return FlutterMap(
      options: MapOptions(
        initialCenter: point,
        initialZoom: zoom,
        minZoom: 1,
        maxZoom: 12,
        interactionOptions: InteractionOptions(
          flags: interactive
              ? InteractiveFlag.all & ~InteractiveFlag.rotate
              : InteractiveFlag.none,
        ),
      ),
      children: [
        TileLayer(
          // Pozor: Esri používa poradie {z}/{y}/{x}.
          urlTemplate: showLabels
              ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
              : 'https://server.arcgisonline.com/ArcGIS/rest/services/'
                  'World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'sk.student.country_quiz',
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: point,
              width: 48,
              height: 48,
              alignment: Alignment.topCenter,
              child: const Icon(
                Icons.location_pin,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              showLabels
                  ? 'OpenStreetMap contributors'
                  : 'Esri, Maxar, Earthstar Geographics',
            ),
          ],
        ),
      ],
    );
  }
}

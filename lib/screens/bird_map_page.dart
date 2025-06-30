import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BirdMapPage extends StatelessWidget {
  const BirdMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Example marker for a sighting
    final List<Marker> birdMarkers = [
      Marker(
        width: 40,
        height: 40,
        point: LatLng(40.7128, -74.0060), // NYC
        child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
      ),
      Marker(
        width: 40,
        height: 40,
        point: LatLng(34.0522, -118.2437), // LA
        child: const Icon(Icons.location_pin, color: Colors.green, size: 40),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bird Map')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(39.8283, -98.5795), // Center of USA
              initialZoom: 4.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.chirp',
              ),
              MarkerLayer(markers: birdMarkers),
            ],
          ),
          // Example overlay: draggable drawer, legend, or filter
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Open filter modal (future)
              },
              child: const Icon(Icons.filter_alt),
            ),
          ),
        ],
      ),
    );
  }
}

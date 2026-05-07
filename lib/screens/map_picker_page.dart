import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPickerPage({super.key, this.initialLatitude, this.initialLongitude});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  late GoogleMapController _mapController;
  LatLng? selectedLocation;
  late LatLng initialLocation;

  @override
  void initState() {
    super.initState();
    // Set initial location to provided coordinates or default
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      initialLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      selectedLocation = initialLocation;
    } else {
      // Default to center of USA
      initialLocation = const LatLng(39.8283, -98.5795);
      selectedLocation = initialLocation;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Sighting Location"),
        actions: [
          if (selectedLocation != null)
            TextButton(
              onPressed: () => Navigator.pop(context, selectedLocation),
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: initialLocation,
              zoom: 13.0,
            ),
            markers:
                selectedLocation != null
                    ? {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: selectedLocation!,
                        infoWindow: InfoWindow(
                          title: 'Sighting Location',
                          snippet:
                              'Lat: ${selectedLocation!.latitude.toStringAsFixed(4)}, '
                              'Lng: ${selectedLocation!.longitude.toStringAsFixed(4)}',
                        ),
                      ),
                    }
                    : {},
            onTap: (LatLng location) {
              setState(() {
                selectedLocation = location;
              });
            },
          ),
          // Bottom sheet with coordinates
          if (selectedLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sighting Location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Latitude: ${selectedLocation!.latitude.toStringAsFixed(6)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                "Longitude: ${selectedLocation!.longitude.toStringAsFixed(6)}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context, selectedLocation),
                      icon: const Icon(Icons.check),
                      label: const Text("Confirm Location"),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

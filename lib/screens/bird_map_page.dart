import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/bird_sighting.dart';
import '../models/bird.dart';
import '../utils/sighting_repository.dart';
import '../utils/bird_repository.dart';
import 'sighting_detail_page.dart';

class BirdMapPage extends StatefulWidget {
  const BirdMapPage({super.key});

  @override
  State<BirdMapPage> createState() => _BirdMapPageState();
}

class _BirdMapPageState extends State<BirdMapPage> {
  GoogleMapController? mapController;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<BirdSighting> sightings = [];
  Set<Marker> birdMarkers = {};
  bool isLoading = true;

  PersistentBottomSheetController? _bottomSheetController;
  String? _selectedMarkerId;

  final Map<String, Bird?> _birdCache = {};

  @override
  void initState() {
    super.initState();
    _loadSightings();
  }

  Future<void> _loadSightings() async {
    try {
      final fetchedSightings = await SightingRepository.fetchSightings();

      final sightingsWithLocation =
          fetchedSightings
              .where((s) => s.latitude != null && s.longitude != null)
              .toList();

      final uniqueSpeciesCodes =
          sightingsWithLocation
              .map((s) => s.speciesCode)
              .whereType<String>()
              .toSet();

      for (final code in uniqueSpeciesCodes) {
        try {
          _birdCache[code] = await BirdRepository().getBirdBySpeciesCodeAsync(
            code,
          );
        } catch (e) {
          debugPrint('Could not preload bird for $code: $e');
          _birdCache[code] = null;
        }
      }

      if (!mounted) return;

      setState(() {
        sightings = sightingsWithLocation;
        isLoading = false;
      });

      _rebuildMarkers();
    } catch (e) {
      debugPrint('Error loading sightings: $e');

      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading sightings: $e')));
    }
  }

  void _rebuildMarkers() {
    final markers = <Marker>{};

    for (int i = 0; i < sightings.length; i++) {
      final sighting = sightings[i];
      final markerIdValue = 'sighting_${sighting.id ?? i}';
      final isSelected = _selectedMarkerId == markerIdValue;

      markers.add(
        Marker(
          markerId: MarkerId(markerIdValue),
          position: LatLng(sighting.latitude!, sighting.longitude!),
          consumeTapEvents: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
          zIndex: isSelected ? 2 : 1,
          onTap: () => _onMarkerTapped(sighting, markerIdValue),
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      birdMarkers = markers;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _dismissBottomSheet() async {
    _bottomSheetController?.close();
    _bottomSheetController = null;

    if (mounted && _selectedMarkerId != null) {
      setState(() {
        _selectedMarkerId = null;
      });
      _rebuildMarkers();
    }
  }

  Future<void> _onMarkerTapped(BirdSighting sighting, String markerId) async {
    final alreadySelected = _selectedMarkerId == markerId;

    if (alreadySelected) {
      return;
    }

    _bottomSheetController?.close();
    _bottomSheetController = null;

    if (!mounted) return;

    setState(() {
      _selectedMarkerId = markerId;
    });
    _rebuildMarkers();

    Bird? bird;
    if (sighting.speciesCode != null) {
      bird = _birdCache[sighting.speciesCode!];
      if (bird == null) {
        try {
          bird = await BirdRepository().getBirdBySpeciesCodeAsync(
            sighting.speciesCode!,
          );
          _birdCache[sighting.speciesCode!] = bird;
        } catch (e) {
          debugPrint('Could not load bird on marker tap: $e');
        }
      }
    }

    if (!mounted) return;

    try {
      await mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(sighting.latitude!, sighting.longitude!)),
      );
    } catch (e) {
      debugPrint('Could not animate camera: $e');
    }

    final scaffoldState = _scaffoldKey.currentState;
    if (scaffoldState == null) return;

    _bottomSheetController = scaffoldState.showBottomSheet(
      (context) => _SightingCard(
        sighting: sighting,
        bird: bird,
        onClose: () async {
          await _dismissBottomSheet();
        },
        onViewDetails: () async {
          await _dismissBottomSheet();

          if (!mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SightingDetailPage(sighting: sighting),
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );

    _bottomSheetController!.closed.then((_) {
      if (!mounted) return;

      if (_selectedMarkerId == markerId) {
        setState(() {
          _selectedMarkerId = null;
        });
        _rebuildMarkers();
      }

      _bottomSheetController = null;
    });
  }

  @override
  void dispose() {
    _bottomSheetController?.close();
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: const Text('Bird Sightings Map')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : sightings.isEmpty
              ? const Center(
                child: Text('No bird sightings with locations yet'),
              )
              : Stack(
                children: [
                  GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(39.8283, -98.5795),
                      zoom: 4.0,
                    ),
                    markers: birdMarkers,
                    mapType: MapType.terrain,
                    onTap: (_) => _dismissBottomSheet(),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Filter feature coming soon!'),
                          ),
                        );
                      },
                      child: const Icon(Icons.filter_alt),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        '${sightings.length} sightings',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _SightingCard extends StatelessWidget {
  final BirdSighting sighting;
  final Bird? bird;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const _SightingCard({
    required this.sighting,
    required this.bird,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl =
        (sighting.photoUrls?.isNotEmpty == true)
            ? sighting.photoUrls!.first
            : bird?.photoUrl;

    final scientificName =
        bird?.scientificName?.trim().isNotEmpty == true
            ? bird!.scientificName!
            : null;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                if (photoUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: _buildImage(photoUrl),
                  )
                else
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    child: Container(
                      height: 170,
                      color: Colors.green.shade50,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 56,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sighting.birdName ?? 'Unknown Bird',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  if (scientificName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      scientificName,
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: sighting.locationName ?? 'Unknown Location',
                  ),
                  if (sighting.seenBy != null) ...[
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Seen by ${sighting.seenBy}',
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: bird != null ? onViewDetails : null,
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('View Sighting Details'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        height: 170,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholderImage(),
      );
    }

    return Image.asset(
      url,
      height: 170,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholderImage(),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 170,
      color: Colors.green.shade50,
      child: const Center(
        child: Icon(Icons.broken_image_outlined, size: 48, color: Colors.green),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

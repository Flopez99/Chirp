import 'package:chirp/screens/bird_detail_page.dart';
import 'package:chirp/utils/bird_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/sighting_repository.dart';
import '../models/bird_sighting.dart';

class LatestFindsPage extends StatefulWidget {
  const LatestFindsPage({super.key});

  @override
  State<LatestFindsPage> createState() => _LatestFindsPageState();
}

class _LatestFindsPageState extends State<LatestFindsPage> {
  List<BirdSighting> sightings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSightings();
  }

  Future<void> loadSightings() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedSightings = await SightingRepository.fetchSightings();
      setState(() {
        sightings = fetchedSightings.reversed.toList();
      });
    } catch (e) {
      print("Error loading latest sightings: $e");
      setState(() {
        sightings = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Latest Sightings")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : sightings.isEmpty
              ? const Center(child: Text("No sightings logged yet."))
              : ListView.builder(
                itemCount: sightings.length,
                itemBuilder: (context, index) {
                  final sighting = sightings[index];

                  final photoUrl =
                      (sighting.photoUrls != null &&
                              sighting.photoUrls!.isNotEmpty)
                          ? sighting.photoUrls!.first
                          : 'assets/images/placeholder_bird.png';

                  final sightingDate = sighting.loggedAt;

                  final bird = BirdRepository().getBirdByScientificName(
                    sighting.birdName ?? '',
                  );

                  return ListTile(
                    onTap: () {
                      if (bird != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BirdDetailPage(bird: bird),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bird info not found')),
                        );
                      }
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          photoUrl.startsWith('http')
                              ? Image.network(
                                photoUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                    ),
                              )
                              : Image.asset(
                                photoUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                    ),
                    title: Text(sighting.birdName ?? 'Unknown Bird'),
                    subtitle: Text(
                      "${DateFormat('MM/dd/yyyy - hh:mm a').format(sightingDate)} at ${sighting.locationName ?? 'Unknown Location'}",
                    ),
                  );
                },
              ),
    );
  }
}

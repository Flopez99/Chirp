import 'package:chirp/screens/bird_detail_page.dart';
import 'package:chirp/utils/bird_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/sighting_repository.dart';

class LatestFindsPage extends StatelessWidget {
  const LatestFindsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sightings = SightingRepository.getSightings().reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Latest Sightings")),
      body:
          sightings.isEmpty
              ? const Center(child: Text("No sightings logged yet."))
              : ListView.builder(
                itemCount: sightings.length,
                itemBuilder: (context, index) {
                  final sighting = sightings[index];
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => BirdDetailPage(
                                bird:
                                    BirdRepository().getBirdByScientificName(
                                      sighting.birdName,
                                    )!,
                              ),
                        ),
                      );
                    },
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          (sighting.imagePath.startsWith('http')
                              ? Image.network(
                                sighting.imagePath,
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
                                sighting.imagePath,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )),
                    ),
                    title: Text(sighting.birdName),
                    subtitle: Text(
                      "${DateFormat('MM/dd/yyyy - hh:mm a').format(sighting.dateTime)} at ${sighting.locationName}",
                    ),
                  );
                },
              ),
    );
  }
}

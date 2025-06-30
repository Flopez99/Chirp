import 'package:chirp/screens/bird_detail_page.dart';
import 'package:chirp/utils/bird_repository.dart';
import 'package:flutter/material.dart';
import '../utils/sighting_repository.dart';

class LatestFindsPage extends StatelessWidget {
  const LatestFindsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sightings = SightingRepository.getSightings();

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
                    leading: Image.asset(
                      sighting.imagePath,
                      width: 50,
                      height: 50,
                    ),
                    title: Text(sighting.birdName),
                    subtitle: Text(
                      "${sighting.dateTime.toLocal()} • ${sighting.locationName}",
                    ),
                  );
                },
              ),
    );
  }
}

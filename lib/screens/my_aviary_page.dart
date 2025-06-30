import 'package:chirp/screens/bird_detail_page.dart';
import 'package:chirp/utils/bird_repository.dart';
import 'package:flutter/material.dart';
import 'log_sighting_page.dart';
import '../utils/sighting_repository.dart';
import '../models/bird_sighting.dart';

class MyAviaryPage extends StatefulWidget {
  const MyAviaryPage({super.key});

  @override
  State<MyAviaryPage> createState() => _MyAviaryPageState();
}

class _MyAviaryPageState extends State<MyAviaryPage> {
  List<BirdSighting> sightings = [];

  @override
  void initState() {
    super.initState();
    loadSightings();
  }

  void loadSightings() {
    sightings = SightingRepository.getMySightings().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Aviary')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogSightingPage()),
          );

          if (result == true) {
            setState(() {
              loadSightings(); // reload after returning
            });
          }
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Log Sighting'),
      ),
      body:
          sightings.isEmpty
              ? const Center(child: Text("No sightings yet."))
              : ListView.builder(
                itemCount: sightings.length,
                itemBuilder: (context, index) {
                  final sighting = sightings[index];
                  return ListTile(
                    onTap:
                        () => Navigator.push(
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
                        ),
                    leading: Image.asset(
                      sighting.imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
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

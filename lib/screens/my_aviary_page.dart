import 'package:chirp/providers/user_provider.dart';
import 'package:chirp/screens/bird_detail_page.dart';
import 'package:chirp/utils/bird_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    loadSightings(userId.toString());
  }

  Future<void> loadSightings(String userId) async {
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch sightings from backend, filter by user if possible
      final fetchedSightings = await SightingRepository.fetchSightings(
        userId: userId,
      );
      setState(() {
        sightings = fetchedSightings.reversed.toList();
      });
    } catch (e) {
      // handle error, show toast/snackbar or whatever you want
      print("Error loading sightings: $e");
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
    final userId = Provider.of<UserProvider>(context).userId;

    return Scaffold(
      appBar: AppBar(title: const Text('My Aviary')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogSightingPage()),
          );

          if (result == true) {
            await loadSightings(userId); // reload after returning
          }
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Log Sighting'),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : sightings.isEmpty
              ? const Center(child: Text("No sightings yet."))
              : ListView.builder(
                itemCount: sightings.length,
                itemBuilder: (context, index) {
                  final sighting = sightings[index];

                  // Pick first photo URL or placeholder
                  final photoUrl =
                      (sighting.photoUrls != null &&
                              sighting.photoUrls!.isNotEmpty)
                          ? sighting.photoUrls!.first
                          : 'assets/images/placeholder_bird.png'; // put a placeholder in assets

                  // Use loggedAt datetime
                  final sightingDate = sighting.loggedAt;

                  return ListTile(
                    onTap: () async {
                      print("TAP sighting id=${sighting.id} name=${sighting.birdName} code=${sighting.speciesCode}");

                      final code = sighting.speciesCode ?? '';
                      print("CODE: $code");

                      if (code.isEmpty) {
                        print("EARLY RETURN: missing species code");
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Missing species code')),
                        );
                        return;
                      }

                      try {
                        print("FETCH bird by code...");
                        final bird = await BirdRepository().getBirdBySpeciesCodeAsync(code);
                        print("FETCH DONE. bird=${bird?.name} sci=${bird?.scientificName}");

                        if (!mounted) return;

                        if (bird == null) {
                          print("EARLY RETURN: bird null (404?)");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bird info not found')),
                          );
                          return;
                        }

                        print("NAVIGATING...");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => BirdDetailPage(bird: bird)),
                        );
                      } catch (e, st) {
                        print("ERROR loading bird: $e");
                        print("STACK: $st");
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error loading bird: $e')),
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

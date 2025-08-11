import 'package:flutter/material.dart';
import '../models/bird.dart';
import 'bird_detail_page.dart'; // Create this next
import '../utils/bird_repository.dart';

class BirdCataloguePage extends StatefulWidget {
  const BirdCataloguePage({super.key});

  @override
  State<BirdCataloguePage> createState() => _BirdCataloguePageState();
}

class _BirdCataloguePageState extends State<BirdCataloguePage> {
  late Future<List<Bird>> birdFuture;
  final Set<String> trackedBirds = {};

  @override
  void initState() {
    super.initState();
    birdFuture = BirdRepository().getBirds();
  }

  void toggleTracked(Bird bird) {
    setState(() {
      if (trackedBirds.contains(bird.scientificName)) {
        trackedBirds.remove(bird.scientificName);
      } else {
        trackedBirds.add(bird.scientificName);
      }
    });
  }

  bool isTracked(Bird bird) => trackedBirds.contains(bird.scientificName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bird Catalogue')),
      body: FutureBuilder<List<Bird>>(
        future: birdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading birds: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No birds found.'));
          }

          final birds = snapshot.data!;
          return ListView.builder(
            itemCount: birds.length,
            itemBuilder: (context, index) {
              final bird = birds[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BirdDetailPage(bird: bird),
                    ),
                  );
                },
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      bird.photoUrl != null
                          ? (bird.photoUrl!.startsWith('http')
                              ? Image.network(
                                bird.photoUrl!,
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
                                bird.photoUrl!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ))
                          : const Icon(Icons.image_not_supported, size: 40),
                ),
                title: Text(bird.name),
                subtitle: Text(bird.scientificName),
                trailing: Text(
                  bird.rarity,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

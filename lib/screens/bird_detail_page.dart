import 'package:flutter/material.dart';
import '../models/bird.dart';

class BirdDetailPage extends StatelessWidget {
  final Bird bird;

  const BirdDetailPage({required this.bird, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bird.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            bird.photoUrl != null
                ? (bird.photoUrl!.startsWith('http')
                    ? Image.network(
                      bird.photoUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 40),
                    )
                    : Image.asset(
                      bird.photoUrl!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ))
                : const Icon(Icons.image_not_supported, size: 40),
            const SizedBox(height: 16),
            Text(
              bird.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              bird.scientificName,
              style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            if (bird.description != null)
              Text(bird.description!, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(
                    'Conservation Status: ${bird.conservationStatus}',
                  ),
                ),
                const SizedBox(width: 8),
                if (bird.endangered)
                  const Chip(
                    label: Text('Endangered'),
                    backgroundColor: Colors.redAccent,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            //if (bird.commonlySeen) const Chip(label: Text('Commonly Seen')),
          ],
        ),
      ),
    );
  }
}

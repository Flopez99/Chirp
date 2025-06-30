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
            if (bird.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(bird.photoUrl!, height: 200),
              ),
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
                Chip(label: Text('Rarity: ${bird.rarity}')),
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
            if (bird.commonlySeen) const Chip(label: Text('Commonly Seen')),
          ],
        ),
      ),
    );
  }
}

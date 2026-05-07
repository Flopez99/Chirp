import 'package:flutter/material.dart';
import '../models/bird.dart';

class BirdDetailPage extends StatelessWidget {
  final Bird bird;

  const BirdDetailPage({required this.bird, super.key});

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Colors.green;
      case 'uncommon':
        return Colors.blue;
      case 'rare':
        return Colors.orange;
      case 'very rare':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRarityIcon(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return Icons.trending_up;
      case 'uncommon':
        return Icons.visibility;
      case 'rare':
        return Icons.visibility_off;
      case 'very rare':
        return Icons.hide_source;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(bird.name), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section (responsive: center & constrain on wide screens)
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                final image =
                    bird.photoUrl != null
                        ? (bird.photoUrl!.startsWith('http')
                            ? Image.network(
                              bird.photoUrl!,
                              fit: isWide ? BoxFit.contain : BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder:
                                  (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.broken_image, size: 64),
                                  ),
                            )
                            : Image.asset(
                              bird.photoUrl!,
                              fit: isWide ? BoxFit.contain : BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ))
                        : const Center(
                          child: Icon(Icons.image_not_supported, size: 64),
                        );

                if (isWide) {
                  // On wide screens constrain the image so it doesn't stretch across the entire page
                  return Container(
                    color: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 900,
                          maxHeight: 480,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AspectRatio(aspectRatio: 16 / 9, child: image),
                        ),
                      ),
                    ),
                  );
                }

                // Mobile / narrow: full-bleed banner
                return Container(
                  width: double.infinity,
                  height: 320,
                  color: Colors.grey[200],
                  child: ClipRRect(
                    borderRadius: BorderRadius.zero,
                    child: image,
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Scientific Name
                  Text(
                    bird.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bird.scientificName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Status Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Rarity Badge
                      Chip(
                        avatar: Icon(_getRarityIcon(bird.rarity)),
                        label: Text(bird.rarity),
                        backgroundColor: _getRarityColor(
                          bird.rarity,
                        ).withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _getRarityColor(bird.rarity),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Conservation Status Badge
                      if (bird.conservationStatus != null &&
                          bird.conservationStatus!.isNotEmpty)
                        Chip(
                          avatar: const Icon(Icons.eco),
                          label: Text(bird.conservationStatus!),
                          backgroundColor: Colors.green.withOpacity(0.2),
                          labelStyle: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      // Endangered Badge
                      if (bird.endangered)
                        const Chip(
                          avatar: Icon(Icons.warning),
                          label: Text('Endangered'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      // Commonly Seen Badge
                      if (bird.commonlySeen)
                        const Chip(
                          avatar: Icon(Icons.favorite),
                          label: Text('Commonly Seen'),
                          backgroundColor: Colors.pink,
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Taxonomy Section
                  Text(
                    'Classification',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          if (bird.order != null && bird.order!.isNotEmpty)
                            _InfoRow('Order', bird.order!),
                          if (bird.family != null && bird.family!.isNotEmpty)
                            _InfoRow('Family', bird.family!),
                          if (bird.genus != null && bird.genus!.isNotEmpty)
                            _InfoRow('Genus', bird.genus!),
                          if (bird.category != null &&
                              bird.category!.isNotEmpty)
                            _InfoRow('Category', bird.category!),
                          _InfoRow('Species Code', bird.speciesCode),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Physical Characteristics
                  if (bird.wingspanCm != null ||
                      bird.heightCmRange != null ||
                      bird.weightKgRange != null ||
                      bird.topSpeedKmh != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Physical Characteristics',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                // Wingspan
                                if (bird.wingspanCm != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.unfold_more,
                                          size: 28,
                                          color: Colors.blueAccent,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Wingspan',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${bird.wingspanCm!.toStringAsFixed(1)} cm',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                // Height
                                if (bird.heightCmRange != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.height,
                                          size: 28,
                                          color: Colors.teal,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Height',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${bird.heightCmRange![0].toStringAsFixed(1)}-${bird.heightCmRange![1].toStringAsFixed(1)} cm',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                // Weight
                                if (bird.weightKgRange != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 16.0,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.scale,
                                          size: 28,
                                          color: Colors.orange,
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Weight',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${bird.weightKgRange![0].toStringAsFixed(1)}-${bird.weightKgRange![1].toStringAsFixed(1)} kg',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                // Top Speed
                                if (bird.topSpeedKmh != null)
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.speed,
                                        size: 28,
                                        color: Colors.redAccent,
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Top Speed',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${bird.topSpeedKmh!.toStringAsFixed(1)} km/h',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Enhanced Description Section (AI-generated) or fallback to original
                  if (bird.descriptionEnhanced != null &&
                      bird.descriptionEnhanced!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.deepPurple.withOpacity(0.05),
                          ),
                          child: Text(
                            bird.descriptionEnhanced!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  else if (bird.description != null &&
                      bird.description!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[50],
                          ),
                          child: Text(
                            bird.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Fun Facts Section
                  if (bird.funFacts != null && bird.funFacts!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fun Facts',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...bird.funFacts!.asMap().entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.amber.withOpacity(
                                        0.2,
                                      ),
                                      child: Text(
                                        '${entry.key + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.amber,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Identification Tips Section
                  if (bird.identificationTips != null &&
                      bird.identificationTips!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identification Tips',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...bird.identificationTips!.asMap().entries.map((
                          entry,
                        ) {
                          final icons = [
                            Icons.visibility,
                            Icons.audiotrack,
                            Icons.location_on,
                          ];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      icons[entry.key % icons.length],
                                      size: 24,
                                      color: Colors.teal,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Habitat & Behavior Section
                  if ((bird.habitatSummary != null &&
                          bird.habitatSummary!.isNotEmpty) ||
                      (bird.behaviorSummary != null &&
                          bird.behaviorSummary!.isNotEmpty))
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Habitat & Behavior',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (bird.habitatSummary != null &&
                                    bird.habitatSummary!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 20,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Habitat',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        bird.habitatSummary!,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                      if (bird.behaviorSummary != null &&
                                          bird.behaviorSummary!.isNotEmpty)
                                        const SizedBox(height: 16),
                                    ],
                                  ),
                                if (bird.behaviorSummary != null &&
                                    bird.behaviorSummary!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.pets,
                                            size: 20,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Behavior',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        bird.behaviorSummary!,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Diet Section
                  if (bird.dietSummary != null && bird.dietSummary!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Diet',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bird.dietSummary!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                if (bird.dietItems != null &&
                                    bird.dietItems!.isNotEmpty)
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Diet Items:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children:
                                            bird.dietItems!.map((item) {
                                              return Chip(
                                                label: Text(item),
                                                backgroundColor: Colors.green
                                                    .withOpacity(0.1),
                                                labelStyle: const TextStyle(
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList(),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Range Section
                  if (bird.regionSummary != null &&
                      bird.regionSummary!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Range',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.public,
                                  size: 24,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    bird.regionSummary!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Special Traits Section
                  if (bird.specialTraits != null &&
                      bird.specialTraits!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Special Traits',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              bird.specialTraits!.map((trait) {
                                return Chip(
                                  avatar: const Icon(Icons.star, size: 18),
                                  label: Text(trait),
                                  backgroundColor: Colors.purple.withOpacity(
                                    0.1,
                                  ),
                                  labelStyle: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // Beginner Tip Section
                  if (bird.beginnerTip != null && bird.beginnerTip!.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beginner Tip',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.amber[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.amber.withOpacity(0.1),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.amber,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  bird.beginnerTip!,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

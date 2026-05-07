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
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedFamilies = {};
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    birdFuture = BirdRepository().getBirds();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<Bird> _filterBirds(List<Bird> birds) {
    String searchQuery = _searchController.text.toLowerCase();

    return birds.where((bird) {
      // Check search query
      final matchesSearch =
          searchQuery.isEmpty ||
          bird.name.toLowerCase().contains(searchQuery) ||
          bird.scientificName.toLowerCase().contains(searchQuery);

      // Check family filter
      final matchesFamily =
          _selectedFamilies.isEmpty ||
          (bird.family != null && _selectedFamilies.contains(bird.family));

      return matchesSearch && matchesFamily;
    }).toList();
  }

  Set<String> _getUniqueFamilies(List<Bird> birds) {
    return birds
        .where((b) => b.family != null && b.family!.isNotEmpty)
        .map((b) => b.family!)
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bird Catalogue')),
      body: Column(
        children: [
          // Search and Filter Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name or species...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon:
                        _searchController.text.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter Toggle Button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showFilters
                            ? Icons.filter_list
                            : Icons.filter_list_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_selectedFamilies.isNotEmpty)
                      Chip(
                        label: Text(_selectedFamilies.length.toString()),
                        onDeleted: () {
                          setState(() {
                            _selectedFamilies.clear();
                          });
                        },
                      ),
                  ],
                ),
                // Filter Options
                if (_showFilters)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: FutureBuilder<List<Bird>>(
                      future: birdFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox();
                        }
                        final uniqueFamilies =
                            _getUniqueFamilies(snapshot.data!).toList()..sort();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Family',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 36,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children:
                                    uniqueFamilies.map((family) {
                                      final isSelected = _selectedFamilies
                                          .contains(family);
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: FilterChip(
                                          label: Text(family),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              if (selected) {
                                                _selectedFamilies.add(family);
                                              } else {
                                                _selectedFamilies.remove(
                                                  family,
                                                );
                                              }
                                            });
                                          },
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          // Bird List
          Expanded(
            child: FutureBuilder<List<Bird>>(
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
                final filteredBirds = _filterBirds(birds);

                if (filteredBirds.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No birds found matching your search',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredBirds.length,
                  itemBuilder: (context, index) {
                    final bird = filteredBirds[index];
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
                                          (context, error, stackTrace) =>
                                              const Icon(
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
                                : const Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                ),
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
          ),
        ],
      ),
    );
  }
}

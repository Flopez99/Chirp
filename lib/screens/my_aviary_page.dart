import 'package:chirp/providers/user_provider.dart';
import 'package:chirp/screens/sighting_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'log_sighting_page.dart';
import '../utils/sighting_repository.dart';
import '../models/bird_sighting.dart';
import '../models/bird.dart';
import '../utils/bird_repository.dart';

class MyAviaryPage extends StatefulWidget {
  const MyAviaryPage({super.key});

  @override
  State<MyAviaryPage> createState() => _MyAviaryPageState();
}

class _MyAviaryPageState extends State<MyAviaryPage> {
  List<BirdSighting> sightings = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedLocations = {};
  DateTime? _selectedDate;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<UserProvider>(context, listen: false).userId;
    loadSightings(userId.toString());
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<BirdSighting> _filterSightings(List<BirdSighting> sightings) {
    String searchQuery = _searchController.text.toLowerCase();

    return sightings.where((sighting) {
      // Check search query (bird name and location)
      final matchesSearch =
          searchQuery.isEmpty ||
          (sighting.birdName?.toLowerCase().contains(searchQuery) ?? false) ||
          (sighting.locationName?.toLowerCase().contains(searchQuery) ?? false);

      // Check location filter
      final matchesLocation =
          _selectedLocations.isEmpty ||
          _selectedLocations.contains(sighting.locationName);

      // Check date filter
      final matchesDate =
          _selectedDate == null ||
          _isSameDay(sighting.loggedAt, _selectedDate!);

      return matchesSearch && matchesLocation && matchesDate;
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Set<String> _getUniqueLocations() {
    return sightings
        .where((s) => s.locationName != null && s.locationName!.isNotEmpty)
        .map((s) => s.locationName!)
        .toSet();
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Provider.of<UserProvider>(context).userId;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Aviary')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogSightingPage()),
            );

            if (result == true) {
              await loadSightings(userId.toString());
            }
          },
          icon: const Icon(Icons.add_location_alt),
          label: const Text('Log Sighting'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (sightings.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Aviary')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogSightingPage()),
            );

            if (result == true) {
              await loadSightings(userId.toString());
            }
          },
          icon: const Icon(Icons.add_location_alt),
          label: const Text('Log Sighting'),
        ),
        body: const Center(child: Text("No sightings yet.")),
      );
    }

    final filteredSightings = _filterSightings(sightings);
    final uniqueLocations = _getUniqueLocations();

    return Scaffold(
      appBar: AppBar(title: const Text('My Aviary')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LogSightingPage()),
          );

          if (result == true) {
            await loadSightings(userId.toString());
          }
        },
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Log Sighting'),
      ),
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
                    hintText: 'Search by bird or location...',
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
                    if (_selectedLocations.isNotEmpty || _selectedDate != null)
                      Chip(
                        label: Text(
                          (_selectedLocations.length +
                                  (_selectedDate != null ? 1 : 0))
                              .toString(),
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedLocations.clear();
                            _selectedDate = null;
                          });
                        },
                      ),
                  ],
                ),
                // Filter Options
                if (_showFilters)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date Filter
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              FilterChip(
                                label: const Text('Any Date'),
                                selected: _selectedDate == null,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedDate = null;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Today'),
                                selected:
                                    _selectedDate != null &&
                                    _isSameDay(_selectedDate!, DateTime.now()),
                                onSelected: (_) {
                                  setState(() {
                                    _selectedDate = DateTime.now();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: Text(
                                  _selectedDate != null
                                      ? DateFormat(
                                        'MM/dd/yyyy',
                                      ).format(_selectedDate!)
                                      : 'Pick Date',
                                ),
                                onSelected: (_) {
                                  _showDatePicker();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Location Filter
                        if (uniqueLocations.isNotEmpty) ...[
                          Text(
                            'Locations',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children:
                                uniqueLocations.map((location) {
                                  final isSelected = _selectedLocations
                                      .contains(location);
                                  return FilterChip(
                                    label: Text(location),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          _selectedLocations.add(location);
                                        } else {
                                          _selectedLocations.remove(location);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Sightings List
          Expanded(
            child:
                filteredSightings.isEmpty
                    ? Center(
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
                            'No sightings found matching your filters',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredSightings.length,
                      itemBuilder: (context, index) {
                        final sighting = filteredSightings[index];
                        final sightingDate = sighting.loggedAt;

                        return ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        SightingDetailPage(sighting: sighting),
                              ),
                            );
                          },
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _SightingPhoto(sighting: sighting),
                          ),
                          title: Text(sighting.birdName ?? 'Unknown Bird'),
                          subtitle: Text(
                            "${DateFormat('MM/dd/yyyy - hh:mm a').format(sightingDate)} at ${sighting.locationName ?? 'Unknown Location'}",
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

/// Widget that displays the appropriate photo for a sighting
/// Uses custom photo if available, otherwise fetches and displays the bird's default photo
class _SightingPhoto extends StatefulWidget {
  final BirdSighting sighting;

  const _SightingPhoto({required this.sighting});

  @override
  State<_SightingPhoto> createState() => _SightingPhotoState();
}

class _SightingPhotoState extends State<_SightingPhoto> {
  Bird? bird;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // If no custom photo, fetch bird info to get default photo
    if (widget.sighting.photoUrls == null ||
        widget.sighting.photoUrls!.isEmpty) {
      _fetchBird();
    }
  }

  Future<void> _fetchBird() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedBird = await BirdRepository().getBirdBySpeciesCodeAsync(
        widget.sighting.speciesCode!,
      );
      if (mounted) {
        setState(() {
          bird = fetchedBird;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If custom photo exists, display it
    if (widget.sighting.photoUrls != null &&
        widget.sighting.photoUrls!.isNotEmpty) {
      final photoUrl = widget.sighting.photoUrls!.first;
      return Image.network(
        photoUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder:
            (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 40),
      );
    }

    // Otherwise display bird's default photo
    if (isLoading) {
      return const Icon(Icons.image, size: 40);
    }

    if (bird?.photoUrl != null) {
      final photoUrl = bird!.photoUrl!;
      return photoUrl.startsWith('http')
          ? Image.network(
            photoUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 40),
          )
          : Image.asset(photoUrl, width: 60, height: 60, fit: BoxFit.cover);
    }

    // Fallback placeholder
    return const Icon(Icons.image, size: 40);
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bird_sighting.dart';
import '../models/bird.dart';
import '../utils/bird_repository.dart';
import 'bird_detail_page.dart';

class SightingDetailPage extends StatefulWidget {
  final BirdSighting sighting;

  const SightingDetailPage({required this.sighting, super.key});

  @override
  State<SightingDetailPage> createState() => _SightingDetailPageState();
}

class _SightingDetailPageState extends State<SightingDetailPage> {
  Bird? bird;
  bool isLoadingBird = false;
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadBirdInfo();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadBirdInfo() async {
    setState(() {
      isLoadingBird = true;
    });
    try {
      final fetchedBird = await BirdRepository().getBirdBySpeciesCodeAsync(
        widget.sighting.speciesCode ?? '',
      );
      if (mounted) {
        setState(() {
          bird = fetchedBird;
          isLoadingBird = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingBird = false;
        });
      }
    }
  }

  void _openFullScreenGallery({
    required List<String> photoUrls,
    required int initialIndex,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => FullScreenImageGallery(
              photoUrls: photoUrls,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sighting = widget.sighting;
    final formattedDate = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(sighting.loggedAt);
    final formattedTime = DateFormat('hh:mm a').format(sighting.loggedAt);

    return Scaffold(
      appBar: AppBar(title: Text(sighting.birdName ?? 'Sighting')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (sighting.photoUrls != null && sighting.photoUrls!.isNotEmpty)
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: sighting.photoUrls!.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPhotoIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final photoUrl = sighting.photoUrls![index];
                        return GestureDetector(
                          onTap: () {
                            _openFullScreenGallery(
                              photoUrls: sighting.photoUrls!,
                              initialIndex: index,
                            );
                          },
                          child: Container(
                            color: Colors.black12,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Hero(
                                  tag: 'sighting-photo-$index-$photoUrl',
                                  child: Image.network(
                                    photoUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 48,
                                              ),
                                            ),
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.fullscreen,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Tap to expand',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (sighting.photoUrls!.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(sighting.photoUrls!.length, (
                          index,
                        ) {
                          final isActive = index == _currentPhotoIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  isActive
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey[400],
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              )
            else
              Container(
                height: 300,
                color: Colors.grey[300],
                child: Center(
                  child:
                      isLoadingBird
                          ? const CircularProgressIndicator()
                          : bird?.photoUrl != null
                          ? (bird!.photoUrl!.startsWith('http')
                              ? Image.network(
                                bird!.photoUrl!,
                                fit: BoxFit.contain,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image, size: 48),
                                            SizedBox(height: 12),
                                            Text('Failed to load bird photo'),
                                          ],
                                        ),
                              )
                              : Image.asset(
                                bird!.photoUrl!,
                                fit: BoxFit.contain,
                              ))
                          : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported, size: 48),
                              SizedBox(height: 12),
                              Text('No photo available'),
                            ],
                          ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sighting.birdName ?? 'Unknown Bird',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                formattedDate,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                formattedTime,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sighting.locationName ?? 'Unknown Location',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (sighting.seenBy != null && sighting.seenBy!.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.person, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Spotted by ${sighting.seenBy}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (sighting.seenBy != null && sighting.seenBy!.isNotEmpty)
                    const SizedBox(height: 16),

                  if (sighting.notes != null && sighting.notes!.isNotEmpty) ...[
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sighting.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (sighting.description != null &&
                      sighting.description!.isNotEmpty) ...[
                    Text(
                      'Experience',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        sighting.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          isLoadingBird || bird == null
                              ? null
                              : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BirdDetailPage(bird: bird!),
                                  ),
                                );
                              },
                      icon: const Icon(Icons.info),
                      label: const Text('View Bird Info'),
                    ),
                  ),

                  if (isLoadingBird)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Center(
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
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

class FullScreenImageGallery extends StatefulWidget {
  final List<String> photoUrls;
  final int initialIndex;

  const FullScreenImageGallery({
    super.key,
    required this.photoUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageGallery> createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1} / ${widget.photoUrls.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.photoUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final photoUrl = widget.photoUrls[index];
          return Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Hero(
                tag: 'sighting-photo-$index-$photoUrl',
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

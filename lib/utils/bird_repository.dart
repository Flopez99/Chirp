import 'dart:async';
import 'dart:convert';
import 'package:chirp/config/api_config.dart';
import 'package:chirp/services/bird_api.dart';
import 'package:http/http.dart' as http;
import '../models/bird.dart';

class BirdRepository {
  static final BirdRepository _instance = BirdRepository._internal();
  factory BirdRepository() => _instance;
  BirdRepository._internal();

  // Cache
  final Map<String, Bird> _byScientificName = {};
  final List<Bird> _loadedList = [];

  bool _isLoadingPage = false;
  bool _allLoaded = false;
  int? _nextCursor; // cursor-based pagination

  Completer<List<Bird>>? _loadAllCompleter;

  // -----------------------------
  // New: paged fetch
  // -----------------------------
  Future<List<Bird>> fetchNextPage({int limit = 50}) async {
    if (_allLoaded) return const [];
    if (_isLoadingPage) return const []; // simple guard

    _isLoadingPage = true;
    try {
      final page = await BirdApiService.fetchBirdsPage(
        limit: limit,
        cursor: _nextCursor,
      );

      // merge into cache
      for (final b in page.items) {
        _byScientificName[b.scientificName] = b;
      }

      _loadedList.addAll(page.items);
      _nextCursor = page.nextCursor;
      if (_nextCursor == null) _allLoaded = true;

      // If someone is waiting on getBirds() (load-all), keep loading in background style:
      // NOTE: not actually background; it just allows getBirds() to continue when awaited.
      // We won't auto-fetch more here — getBirds() controls full loading.

      return page.items;
    } finally {
      _isLoadingPage = false;
    }
  }

  bool get hasMore => !_allLoaded;
  int? get nextCursor => _nextCursor;

  // -----------------------------
  // Backward-compatible: getBirds()
  // Loads ALL birds (but now uses paging internally)
  // Only screens that truly need all birds will pay the cost.
  // -----------------------------
  Future<List<Bird>> getBirds({int pageSize = 200}) async {
    // if already fully loaded, return immediately
    if (_allLoaded) return _loadedList;

    // If already in the process of loading-all, share the same future
    if (_loadAllCompleter != null) return _loadAllCompleter!.future;

    _loadAllCompleter = Completer<List<Bird>>();

    try {
      // keep fetching pages until done
      while (!_allLoaded) {
        await fetchNextPage(limit: pageSize);
      }
      _loadAllCompleter!.complete(_loadedList);
    } catch (e) {
      _loadAllCompleter!.completeError(e);
      rethrow;
    } finally {
      _loadAllCompleter = null;
    }

    return _loadedList;
  }

  // -----------------------------
  // Backward-compatible: lookup
  // If not found yet, you have two choices:
  // A) throw (current behavior)
  // B) provide an async version that can load missing bird by query
  // We'll keep sync for compatibility and add async helper.
  // -----------------------------

  Future<Bird?> getBirdBySpeciesCodeAsync(String code) async {
    final uri = ApiConfig.uri("/birds/by-species/$code");
    final res = await http.get(uri);

    if (res.statusCode == 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return Bird.fromJson(map);
    }

    if (res.statusCode == 404) return null;

    throw Exception(
      "Failed to fetch bird ($code): ${res.statusCode} ${res.body}",
    );
  }

  Bird getBirdByScientificName(String scientificName) {
    final bird = _byScientificName[scientificName];
    if (bird == null) {
      throw Exception("Bird '$scientificName' not in cache yet.");
    }
    return bird;
  }

  Future<Bird?> getBirdByScientificNameAsync(String scientificName) async {
    // 1) cache hit
    final cached = _byScientificName[scientificName];
    if (cached != null) return cached;

    // 2) fetch from backend
    final bird = await BirdApiService.fetchBirdByScientificName(scientificName);
    if (bird != null) {
      _byScientificName[bird.scientificName] = bird;
    }
    return bird;
  }

  void clearCache() {
    _byScientificName.clear();
    _loadedList.clear();
    _isLoadingPage = false;
    _allLoaded = false;
    _nextCursor = null;
    _loadAllCompleter = null;
  }
}

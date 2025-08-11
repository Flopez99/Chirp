import 'dart:async';
import 'package:chirp/services/bird_api.dart';
import '../models/bird.dart';

class BirdRepository {
  static final BirdRepository _instance = BirdRepository._internal();

  factory BirdRepository() => _instance;

  BirdRepository._internal();

  List<Bird>? _birds;
  bool _isLoading = false;
  Completer<List<Bird>>? _loadCompleter;

  Future<List<Bird>> getBirds() async {
    if (_birds != null) return _birds!;

    if (_isLoading && _loadCompleter != null) {
      return _loadCompleter!.future;
    }

    _isLoading = true;
    _loadCompleter = Completer<List<Bird>>();

    try {
      final birds = await BirdApiService.fetchBirds();
      _birds = birds;
      _loadCompleter!.complete(birds);
    } catch (e) {
      _loadCompleter!.completeError(e);
      rethrow;
    } finally {
      _isLoading = false;
    }

    return _birds!;
  }

  Bird getBirdByScientificName(String name) {
    if (_birds == null) {
      throw Exception("Birds not loaded yet.");
    }
    return _birds!.firstWhere(
      (b) => b.name == name,
      orElse: () => throw Exception('Bird not found'),
    );
  }

  void clearCache() {
    _birds = null;
    _loadCompleter = null;
  }
}

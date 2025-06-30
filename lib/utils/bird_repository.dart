import '../models/bird.dart';
import '../utils/bird_loader.dart';

class BirdRepository {
  static final BirdRepository _instance = BirdRepository._internal();

  factory BirdRepository() => _instance;

  BirdRepository._internal();

  List<Bird>? _birds;

  Future<List<Bird>> getBirds() async {
    _birds ??= await loadBirdCatalogue(); // Only loads once
    return _birds!;
  }

  Bird? getBirdByScientificName(String name) {
    return _birds?.firstWhere((b) => b.name == name);
  }
}

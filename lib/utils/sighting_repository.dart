import '../models/bird_sighting.dart';

class SightingRepository {
  static final List<BirdSighting> _sightings = [];

  static List<BirdSighting> getSightings() => List.unmodifiable(_sightings);

  static void addSighting(BirdSighting sighting) {
    _sightings.add(sighting);
  }

  static List<BirdSighting> getMySightings() {
    // For now, return all. Later: filter by user.
    return List.unmodifiable(_sightings);
  }
}

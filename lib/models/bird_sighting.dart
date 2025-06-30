class BirdSighting {
  final String birdName;
  final String imagePath; // Can be local or network
  final DateTime dateTime;
  final String locationName; // You can use this or coordinates later
  final String? notes;

  BirdSighting({
    required this.birdName,
    required this.imagePath,
    required this.dateTime,
    required this.locationName,
    this.notes,
  });
}

class Bird {
  final String name; // Common name
  final String scientificName;
  final String? photoUrl;
  final String? description;
  final String? conservationStatus;
  final bool commonlySeen;
  final String rarity; // e.g. "Common", "Rare", "Very Rare", "Mythic"
  final bool endangered;

  Bird({
    required this.name,
    required this.scientificName,
    this.photoUrl,
    this.description,
    required this.commonlySeen,
    required this.rarity,
    required this.endangered,
    required this.conservationStatus,
  });

  factory Bird.fromJson(Map<String, dynamic> json) {
    return Bird(
      name: json['name'],
      scientificName: json['scientificName'],
      photoUrl: json['photoUrl'],
      description: json['description'],
      commonlySeen: json['commonlySeen'] ?? false,
      rarity: json['rarity'] ?? 'Unknown',
      endangered: json['endangered'] ?? false,
      conservationStatus: json['conservationStatus'] ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scientificName': scientificName,
      'photoUrl': photoUrl,
      'description': description,
      'commonlySeen': commonlySeen,
      'rarity': rarity,
      'endangered': endangered,
      'conservation_status': conservationStatus,
    };
  }
}

class BirdSighting {
  final int? id;
  final int? userId;
  final int? birdId;
  final DateTime loggedAt;
  final double? latitude;
  final double? longitude;
  final List<String>? photoUrls;
  final String? notes;
  final String? description;

  final String? speciesCode;
  // Optional fields for UI display:
  final String? birdName;
  final String? seenBy;
  final String? locationName;

  BirdSighting({
    this.id,
    this.userId,
    this.birdId,
    this.speciesCode,
    required this.loggedAt,
    this.latitude,
    this.longitude,
    this.photoUrls,
    this.notes,
    this.description,
    this.birdName,
    this.seenBy,
    this.locationName,
  });

  factory BirdSighting.fromJson(Map<String, dynamic> json) {
    // accept either casing
    final loggedAtRaw = json['loggedAt'] ?? json['logged_at'];
    final speciesRaw = json['speciesCode'] ?? json['species_code'];

    if (loggedAtRaw == null) {
      throw Exception("Missing loggedAt/logged_at in response: $json");
    }

    return BirdSighting(
      id: (json['id'] ?? json['sightingId']) as int?,
      userId: (json['userId'] ?? json['user_id']) as int?,
      birdId: (json['birdId'] ?? json['bird_id']) as int?,
      speciesCode: speciesRaw?.toString(), // ✅ nullable
      loggedAt: DateTime.parse(loggedAtRaw.toString()),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      photoUrls:
          (json['photoUrls'] ?? json['photo_urls']) == null
              ? []
              : List<String>.from(
                (json['photoUrls'] ?? json['photo_urls']) as List,
              ),
      notes: json['notes']?.toString(),
      description: (json['description'])?.toString(),
      birdName: (json['birdName'] ?? json['bird_name'])?.toString(),
      seenBy: (json['seenBy'] ?? json['seen_by'])?.toString(),
      locationName: (json['locationName'] ?? json['location_name'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (birdId != null) 'birdId': birdId,
      if (speciesCode != null) 'speciesCode': speciesCode,
      'loggedAt': loggedAt.toIso8601String(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (photoUrls != null) 'photoUrls': photoUrls,
      if (notes != null) 'notes': notes,
      if (description != null) 'description': description,
      if (birdName != null) 'birdName': birdName,
      if (seenBy != null) 'seenBy': seenBy,
      if (locationName != null) 'locationName': locationName,
    };
  }
}

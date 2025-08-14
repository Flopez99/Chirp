class BirdSighting {
  final int? id;
  final int? userId;
  final int? birdId;
  final DateTime loggedAt;
  final double? latitude;
  final double? longitude;
  final List<String>? photoUrls;
  final String? notes;

  // Optional fields for UI display:
  final String? birdName;
  final String? seenBy;
  final String? locationName;

  BirdSighting({
    this.id,
    this.userId,
    this.birdId,
    required this.loggedAt,
    this.latitude,
    this.longitude,
    this.photoUrls,
    this.notes,
    this.birdName,
    this.seenBy,
    this.locationName,
  });

  factory BirdSighting.fromJson(Map<String, dynamic> json) {
    return BirdSighting(
      id: json['id'] as int?,
      userId: json['userId'] as int?,
      birdId: json['birdId'] as int?,
      loggedAt: DateTime.parse(json['loggedAt']),
      latitude:
          (json['latitude'] != null)
              ? (json['latitude'] as num).toDouble()
              : null,
      longitude:
          (json['longitude'] != null)
              ? (json['longitude'] as num).toDouble()
              : null,
      photoUrls:
          (json['photoUrls'] != null)
              ? List<String>.from(json['photoUrls'])
              : null,
      notes: json['notes'] as String?,
      birdName:
          json['birdName'] as String?, // Optional, if your backend provides
      seenBy: json['seenBy'] as String?, // Optional, if your backend provides
      locationName: json['locationName'] as String?, // Optional
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (birdId != null) 'birdId': birdId,
      'loggedAt': loggedAt.toIso8601String(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (photoUrls != null) 'photoUrls': photoUrls,
      if (notes != null) 'notes': notes,
      if (birdName != null) 'birdName': birdName,
      if (seenBy != null) 'seenBy': seenBy,
      if (locationName != null) 'locationName': locationName,
    };
  }
}

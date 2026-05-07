class Bird {
  final int id;
  final String name; // Common name
  final String speciesCode;
  final String scientificName;
  final String? photoUrl;
  final String? description;
  final String? conservationStatus;
  final bool commonlySeen;
  final String rarity; // e.g. "Common", "Rare", "Very Rare", "Mythic"
  final bool endangered;
  final String? family; // e.g. "Accipitridae (Hawks, Eagles, and Kites)"
  final String? genus;
  final String? order; // e.g. "Accipitriformes"
  final double? wingspanCm;
  final String? category; // e.g. "species", "subspecies"

  // AI Enrichment Fields
  final String? descriptionEnhanced;
  final List<String>? funFacts;
  final List<String>? identificationTips;
  final String? habitatSummary;
  final String? behaviorSummary;
  final String? dietSummary;
  final String? regionSummary;
  final String? beginnerTip;
  final List<double>? heightCmRange; // [min, max]
  final List<double>? weightKgRange; // [min, max]
  final double? topSpeedKmh;
  final List<String>? dietItems;
  final List<String>? specialTraits;
  final bool aiGenerated;

  Bird({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.speciesCode,
    this.photoUrl,
    this.description,
    required this.commonlySeen,
    required this.rarity,
    required this.endangered,
    required this.conservationStatus,
    this.family,
    this.genus,
    this.order,
    this.wingspanCm,
    this.category,
    this.descriptionEnhanced,
    this.funFacts,
    this.identificationTips,
    this.habitatSummary,
    this.behaviorSummary,
    this.dietSummary,
    this.regionSummary,
    this.beginnerTip,
    this.heightCmRange,
    this.weightKgRange,
    this.topSpeedKmh,
    this.dietItems,
    this.specialTraits,
    this.aiGenerated = false,
  });

  factory Bird.fromJson(Map<String, dynamic> json) {
    // Parse extracted facts if present (backend returns camelCase)
    final extractedFacts =
        json['extractedFacts'] as Map<String, dynamic>? ?? {};

    // Helper to parse ranges from lists
    List<double>? parseRange(dynamic value) {
      if (value is List && value.length == 2) {
        return [(value[0] as num).toDouble(), (value[1] as num).toDouble()];
      }
      return null;
    }

    return Bird(
      id: json['id'],
      name: json['name'],
      speciesCode: json['speciesCode'],
      scientificName: json['scientificName'],
      photoUrl: json['photoUrl'],
      description: json['description'],
      commonlySeen: json['commonlySeen'] ?? false,
      rarity: json['rarity'] ?? 'Unknown',
      endangered: json['endangered'] ?? false,
      conservationStatus: json['conservationStatus'] ?? 'Unknown',
      family: json['family'],
      genus: json['genus'],
      order: json['order'],
      wingspanCm: (json['wingspanCm'] as num?)?.toDouble(),
      category: json['category'],
      descriptionEnhanced: json['descriptionEnhanced'],
      funFacts:
          json['funFacts'] is List ? List<String>.from(json['funFacts']) : null,
      identificationTips:
          json['identificationTips'] is List
              ? List<String>.from(json['identificationTips'])
              : null,
      habitatSummary: json['habitatSummary'],
      behaviorSummary: json['behaviorSummary'],
      dietSummary: json['dietSummary'],
      regionSummary: json['regionSummary'],
      beginnerTip: json['beginnerTip'],
      heightCmRange: parseRange(extractedFacts['heightCmRange']),
      weightKgRange: parseRange(extractedFacts['weightKgRange']),
      topSpeedKmh: (extractedFacts['topSpeedKmh'] as num?)?.toDouble(),
      dietItems:
          extractedFacts['dietItems'] is List
              ? List<String>.from(extractedFacts['dietItems'])
              : null,
      specialTraits:
          extractedFacts['specialTraits'] is List
              ? List<String>.from(extractedFacts['specialTraits'])
              : null,
      aiGenerated: json['aiGenerated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'photoUrl': photoUrl,
      'description': description,
      'commonlySeen': commonlySeen,
      'rarity': rarity,
      'endangered': endangered,
      'conservation_status': conservationStatus,
      'family': family,
      'genus': genus,
      'order': order,
      'wingspanCm': wingspanCm,
      'category': category,
      'description_enhanced': descriptionEnhanced,
      'fun_facts': funFacts,
      'identification_tips': identificationTips,
      'habitat_summary': habitatSummary,
      'behavior_summary': behaviorSummary,
      'diet_summary': dietSummary,
      'region_summary': regionSummary,
      'beginner_tip': beginnerTip,
      'ai_generated': aiGenerated,
      'extracted_facts': {
        'heightCmRange': heightCmRange,
        'weightKgRange': weightKgRange,
        'topSpeedKmh': topSpeedKmh,
        'dietItems': dietItems,
        'specialTraits': specialTraits,
      },
    };
  }
}

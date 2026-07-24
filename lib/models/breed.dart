class Breed {
  final int id;
  final String name;
  final String bredFor;
  final String breedGroup;
  final String lifeSpan;
  final String temperament;
  final String origin;
  final String? referenceImageId;
  final String weightMetric;
  final String heightMetric;
  String? imageUrl;

  Breed({
    required this.id,
    required this.name,
    required this.bredFor,
    required this.breedGroup,
    required this.lifeSpan,
    required this.temperament,
    required this.origin,
    this.referenceImageId,
    required this.weightMetric,
    required this.heightMetric,
    this.imageUrl,
  });

  String get shortDescription {
    if (bredFor.isNotEmpty) return bredFor;
    if (temperament.isNotEmpty) {
      return temperament.split(',').take(2).join(', ').trim();
    }
    return 'A wonderful companion breed.';
  }

  List<String> get temperamentTags {
    return temperament
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  double? get averageWeightKg {
    final match = RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)').firstMatch(weightMetric);
    if (match == null) return null;
    final min = double.tryParse(match.group(1)!);
    final max = double.tryParse(match.group(2)!);
    if (min == null || max == null) return null;
    return (min + max) / 2;
  }

  String get sizeCategory {
    final avg = averageWeightKg;
    if (avg == null) return 'unknown';
    if (avg < 10) return 'small';
    if (avg < 25) return 'medium';
    return 'large';
  }

  bool get isActive {
    final lower = temperament.toLowerCase();
    return lower.contains('active') ||
        lower.contains('energetic') ||
        lower.contains('playful');
  }

  bool get isFamilyFriendly {
    final lower = temperament.toLowerCase();
    return lower.contains('friendly') ||
        lower.contains('gentle') ||
        lower.contains('loyal') ||
        lower.contains('affectionate') ||
        lower.contains('patient');
  }

  factory Breed.fromJson(Map<String, dynamic> json) {
    final weight = json['weight'] as Map<String, dynamic>?;
    final height = json['height'] as Map<String, dynamic>?;

    return Breed(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String? ?? 'Unknown',
      bredFor: json['bred_for'] as String? ?? '',
      breedGroup: json['breed_group'] as String? ?? 'Unknown',
      lifeSpan: json['life_span'] as String? ?? 'Unknown',
      temperament: json['temperament'] as String? ?? '',
      origin: json['origin'] as String? ?? 'Unknown',
      referenceImageId: json['reference_image_id'] as String?,
      weightMetric: weight?['metric'] as String? ?? 'Unknown',
      heightMetric: height?['metric'] as String? ?? 'Unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bred_for': bredFor,
      'breed_group': breedGroup,
      'life_span': lifeSpan,
      'temperament': temperament,
      'origin': origin,
      'reference_image_id': referenceImageId,
      'weight': {'metric': weightMetric},
      'height': {'metric': heightMetric},
      'image_url': imageUrl,
    };
  }

  factory Breed.fromCacheJson(Map<String, dynamic> json) {
    final breed = Breed.fromJson(json);
    breed.imageUrl = json['image_url'] as String?;
    return breed;
  }

  Breed copyWith({String? imageUrl}) {
    return Breed(
      id: id,
      name: name,
      bredFor: bredFor,
      breedGroup: breedGroup,
      lifeSpan: lifeSpan,
      temperament: temperament,
      origin: origin,
      referenceImageId: referenceImageId,
      weightMetric: weightMetric,
      heightMetric: heightMetric,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

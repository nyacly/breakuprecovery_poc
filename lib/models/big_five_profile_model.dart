class BigFiveProfileModel {
  final String id;
  final Map<String, int> scores; // O, C, E, A, N scores (0-20)
  final DateTime createdAt;
  final int itemCount;

  const BigFiveProfileModel({
    required this.id,
    required this.scores,
    required this.createdAt,
    required this.itemCount,
  });

  Map<String, dynamic> toJson() => {
    'scores': scores,
    'createdAt': createdAt.toIso8601String(),
    'itemCount': itemCount,
  };

  factory BigFiveProfileModel.fromJson(String id, Map<String, dynamic> json) => BigFiveProfileModel(
    id: id,
    scores: Map<String, int>.from(json['scores'] ?? {}),
    createdAt: DateTime.parse(json['createdAt']),
    itemCount: json['itemCount'] ?? 0,
  );

  // Helper methods for trait interpretation
  String getTraitLabel(String trait) {
    final score = scores[trait] ?? 0;
    final isHigh = score >= 12; // Above 60%
    
    switch (trait) {
      case 'O': return isHigh ? 'High Openness' : 'Low Openness';
      case 'C': return isHigh ? 'High Conscientiousness' : 'Low Conscientiousness';
      case 'E': return isHigh ? 'High Extraversion' : 'Low Extraversion';
      case 'A': return isHigh ? 'High Agreeableness' : 'Low Agreeableness';
      case 'N': return isHigh ? 'High Neuroticism' : 'Low Neuroticism';
      default: return trait;
    }
  }

  String getShortLabel(String trait) {
    final score = scores[trait] ?? 0;
    final isHigh = score >= 12;
    return isHigh ? 'High $trait' : 'Low $trait';
  }

  List<String> getTopTraits() {
    final sortedTraits = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTraits.take(2).map((e) => getShortLabel(e.key)).toList();
  }

  BigFiveProfileModel copyWith({
    String? id,
    Map<String, int>? scores,
    DateTime? createdAt,
    int? itemCount,
  }) => BigFiveProfileModel(
    id: id ?? this.id,
    scores: scores ?? this.scores,
    createdAt: createdAt ?? this.createdAt,
    itemCount: itemCount ?? this.itemCount,
  );
}
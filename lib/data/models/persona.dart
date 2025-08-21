class Persona {
  final String userId;
  final List<String> selectedTags;
  final String summary;
  final List<String> traits;
  final String moodBias; // e.g., "平静/敏感/外向/内向"

  const Persona({
    required this.userId,
    required this.selectedTags,
    required this.summary,
    required this.traits,
    required this.moodBias,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'selectedTags': selectedTags,
        'summary': summary,
        'traits': traits,
        'moodBias': moodBias,
      };

  factory Persona.fromJson(Map<String, dynamic> json) => Persona(
        userId: json['userId'] as String,
        selectedTags: (json['selectedTags'] as List).map((e) => e as String).toList(),
        summary: json['summary'] as String,
        traits: (json['traits'] as List).map((e) => e as String).toList(),
        moodBias: json['moodBias'] as String,
      );
}



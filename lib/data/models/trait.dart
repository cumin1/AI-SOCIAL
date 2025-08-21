class UserTrait {
  final String id; // stable id for local use
  final String title; // short title, e.g., "温和而坚定"
  final String description; // 1-2 sentences detail
  final List<String> evidenceTags; // tags or cues

  const UserTrait({
    required this.id,
    required this.title,
    required this.description,
    required this.evidenceTags,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'evidenceTags': evidenceTags,
      };

  factory UserTrait.fromJson(Map<String, dynamic> json) => UserTrait(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        evidenceTags: (json['evidenceTags'] as List).map((e) => e as String).toList(),
      );
}



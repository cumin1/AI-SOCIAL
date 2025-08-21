class Profile {
  final String userId;
  final String displayName;
  final int avatarSeed; // simple seed to derive avatar color/emoji
  final bool isAnonymous;

  const Profile({
    required this.userId,
    required this.displayName,
    required this.avatarSeed,
    required this.isAnonymous,
  });

  Profile copyWith({
    String? userId,
    String? displayName,
    int? avatarSeed,
    bool? isAnonymous,
  }) => Profile(
        userId: userId ?? this.userId,
        displayName: displayName ?? this.displayName,
        avatarSeed: avatarSeed ?? this.avatarSeed,
        isAnonymous: isAnonymous ?? this.isAnonymous,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'displayName': displayName,
        'avatarSeed': avatarSeed,
        'isAnonymous': isAnonymous,
      };

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        userId: json['userId'] as String,
        displayName: json['displayName'] as String,
        avatarSeed: json['avatarSeed'] as int,
        isAnonymous: json['isAnonymous'] as bool,
      );
}



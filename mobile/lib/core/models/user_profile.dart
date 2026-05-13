enum UserProfileType {
  blind,
  deaf,
  explore;

  static UserProfileType fromStorage(String? value) {
    return UserProfileType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => UserProfileType.explore,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.type,
    required this.createdAt,
    this.preferredLanguage,
  });

  final UserProfileType type;
  final String? preferredLanguage;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      type: UserProfileType.fromStorage(json['type'] as String?),
      preferredLanguage: json['preferredLanguage'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

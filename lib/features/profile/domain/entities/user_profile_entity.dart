class UserProfileEntity {
  final String id;
  final String name;
  final String avatarUrl;
  final String coverUrl;
  final String bio;
  final String location;
  final String link;
  final bool isOnline;

  UserProfileEntity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.coverUrl,
    required this.bio,
    required this.location,
    required this.link,
    this.isOnline = false,
  });

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    String? location,
    String? link,
    bool? isOnline,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      link: link ?? this.link,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}

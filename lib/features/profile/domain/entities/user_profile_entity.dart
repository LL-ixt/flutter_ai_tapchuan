class UserProfileEntity {
  final String id;
  final String name;
  final String avatarUrl;
  final String coverUrl;
  final String bio;
  final String location;
  final String link;
  final String role;
  final bool isOnline;
  final String isRelated;
  final String listing;
  final String followed;

  UserProfileEntity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.coverUrl,
    required this.bio,
    required this.location,
    required this.link,
    this.role = '',
    this.isOnline = false,
    this.isRelated = '0',
    this.listing = '0',
    this.followed = '0',
  });

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? coverUrl,
    String? bio,
    String? location,
    String? link,
    String? role,
    bool? isOnline,
    String? isRelated,
    String? listing,
    String? followed,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      link: link ?? this.link,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      isRelated: isRelated ?? this.isRelated,
      listing: listing ?? this.listing,
      followed: followed ?? this.followed,
    );
  }
}

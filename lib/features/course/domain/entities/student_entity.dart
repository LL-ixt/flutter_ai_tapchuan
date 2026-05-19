class StudentEntity {
  final String id;
  final String name;
  final String avatarUrl;
  final String status; // 'pending', 'approved', 'rejected'
  final String joinDate;

  StudentEntity({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.status,
    required this.joinDate,
  });

  StudentEntity copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? status,
    String? joinDate,
  }) {
    return StudentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class NotificationEntity {
  final String id;
  final String senderName;
  final String senderAvatarUrl;
  final String content;
  final String time;
  final bool isRead;
  final String type; // 'like', 'comment', 'system'

  NotificationEntity({
    required this.id,
    required this.senderName,
    required this.senderAvatarUrl,
    required this.content,
    required this.time,
    required this.isRead,
    required this.type,
  });

  NotificationEntity copyWith({
    String? id,
    String? senderName,
    String? senderAvatarUrl,
    String? content,
    String? time,
    bool? isRead,
    String? type,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      content: content ?? this.content,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

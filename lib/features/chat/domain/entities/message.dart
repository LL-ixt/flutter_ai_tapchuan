class Message {
  final String messageId;
  final String senderId;
  final String message;
  final String createdAt;
  final bool isMe;

  Message({
    required this.messageId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    required this.isMe,
  });
}

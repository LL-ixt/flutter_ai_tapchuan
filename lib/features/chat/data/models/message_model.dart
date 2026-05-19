import '../../domain/entities/message.dart';

class MessageModel extends Message {
  MessageModel({
    required super.messageId,
    required super.senderId,
    required super.message,
    required super.createdAt,
    required super.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String myUserId) {
    final senderObj = json['sender'] ?? {};
    final senderId = senderObj['id']?.toString() ?? '';
    
    return MessageModel(
      messageId: json['message_id']?.toString() ?? '',
      senderId: senderId,
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? 'Vừa xong',
      isMe: senderId == myUserId,
    );
  }
}

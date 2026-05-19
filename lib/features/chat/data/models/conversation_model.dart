import '../../domain/entities/conversation.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    required super.partnerId,
    required super.partnerName,
    required super.partnerAvatar,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.isUnread,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final partner = json['partner'] ?? {};
    final lastMsg = json['lastMessage'] ?? {};
    
    // Xử lý isUnread có thể trả về string "1" hoặc int 1 từ API
    bool unread = false;
    final numNewMessage = json['numNewMessage'];
    if (numNewMessage != null) {
      if (numNewMessage is String) unread = numNewMessage != '0';
      if (numNewMessage is int) unread = numNewMessage > 0;
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      partnerId: partner['id']?.toString() ?? '',
      partnerName: partner['username']?.toString() ?? 'Người dùng',
      partnerAvatar: partner['avatar']?.toString() ?? 'https://i.pravatar.cc/150',
      lastMessage: lastMsg['message']?.toString() ?? '',
      lastMessageTime: lastMsg['created_at']?.toString() ?? 'Vừa xong',
      isUnread: unread,
    );
  }
}

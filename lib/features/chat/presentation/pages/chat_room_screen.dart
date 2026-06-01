
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';

class ChatRoomDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? partnerInfo;
  final String token;
  final Map<String, dynamic>? myInfo;
  final String? conversationId;

  const ChatRoomDetailScreen({
    super.key,
    required this.partnerInfo,
    required this.token,
    this.myInfo,
    this.conversationId,
  });

  @override
  State<ChatRoomDetailScreen> createState() => _ChatRoomDetailScreenState();
}

class _ChatRoomDetailScreenState extends State<ChatRoomDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Khôi phục lịch sử tin nhắn và join phòng chat
    _loadHistoricalMessages();
  }

  Future<void> _loadHistoricalMessages() async {
    try {
      // Lấy tin nhắn quá khứ từ API (index = 0, count = 50)
      final result = await ApiService.getConversation(
        widget.token,
        0,
        50,
        partnerId: widget.partnerInfo?['id'],
        conversationId: widget.conversationId,
      );

      if (result['code'] == '1000' && mounted) {
        // Định dạng lại danh sách tin nhắn từ API response
        final List<dynamic> messagesFromApi = _extractList(result['data']);
        final List<Map<String, dynamic>> formattedMessages = 
          messagesFromApi.map<Map<String, dynamic>>((msg) {
            return {
              'messageId': msg['messageId'] ?? msg['message_id'] ?? msg['id'] ?? '',
              'content': msg['message'] ?? msg['content'] ?? msg['text'] ?? '',
              'created': msg['created'] ?? DateTime.now().toIso8601String(),
              'sender': _asMap(msg['sender']) ?? _asMap(msg['user']) ?? {},
              'receiver': _asMap(msg['receiver']) ?? {},
            };
          }).toList();

        // Cập nhật state với tin nhắn quá khứ
        context.read<ChatCubit>().updateHistoricalMessages(
          partnerInfo: widget.partnerInfo ?? {},
          messages: formattedMessages,
        );
      }
    } catch (e) {
      debugPrint("Lỗi khi lấy tin nhắn quá khứ: $e");
    }

    // Sau khi lấy tin nhắn quá khứ, mới join phòng chat
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final chatCubit = context.read<ChatCubit>();
          chatCubit.joinChatRoom(
            token: widget.token,
            myInfo: widget.myInfo ?? {},
            partnerInfo: widget.partnerInfo!,
            conversationId: widget.conversationId,
          );
        }
      });
    }
  }

  // Helper functions để trích xuất dữ liệu từ nested structures
  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
    if (data is Map) {
      final nestedData = data['data'];
      if (nestedData is List) return _extractList(nestedData);
      final messages = data['messages'];
      if (messages is List) return _extractList(messages);
    }
    return const [];
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // Gọi Cubit thực thi bắn sự kiện 'send' qua đường ống Socket
      final partnerId = context.read<ChatCubit>().state.partnerInfo?['id'] ?? '';
      context.read<ChatCubit>().sendMessage(content: text, partnerId: partnerId);
      _messageController.clear();
      
      // Cuộn xuống cuối cùng để xem tin nhắn mới
      Timer(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Lấy tên đối phương từ ChatState hiển thị lên AppBar theo chuẩn slide
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            return Text(state.partnerInfo?['username'] ?? state.partnerInfo?['name'] ?? 'Phòng Chat');
          },
        ),
      ),
      body: Column(
        children: [
          // 1. DANH SÁCH TIN NHẮN ĐẬP NHẢ THỜI GIAN THỰC
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final messages = state.messages;
                
                // Lấy ID thật của bạn để đối chiếu
                final String myId = widget.myInfo?['id'] ?? '';

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final senderMap = _asMap(msg['sender']) ?? {};
                    
                    // XÁC ĐỊNH CHÍNH XÁC TIN NHẮN CỦA MÌNH BẰNG ID THẬT
                    final String senderId = senderMap['id']?.toString() ?? '';
                    final bool isMine = (senderId == myId) || (msg['sender']['name'] == 'Tôi'); 

                    // Lấy thông tin Avatar và Tên của đối phương để hiển thị
                    final String partnerAvatar = state.partnerInfo?['avatar'] ?? '';
                    final String partnerName = state.partnerInfo?['username'] ?? state.partnerInfo?['name'] ?? 'P';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        // Nếu là của mình: Đẩy sang bên phải. Nếu của đối phương: Đẩy sang bên trái
                        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 1. HIỂN THỊ AVATAR NẾU LÀ TIN NHẮN CỦA ĐỐI PHƯƠNG
                          if (!isMine) ...[
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: partnerAvatar.isNotEmpty 
                                  ? NetworkImage(partnerAvatar) 
                                  : null,
                              child: partnerAvatar.isEmpty
                                  ? Text(
                                      partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'P',
                                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8.0),
                          ],

                          // 2. BONG BÓNG CHAT CHỨA NỘI DUNG TEXT
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                // Của mình: Màu xanh Blue. Của đối phương: Màu xám nhẹ
                                color: isMine ? AppColors.primaryBlue : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16.0),
                                  topRight: const Radius.circular(16.0),
                                  bottomLeft: Radius.circular(isMine ? 16.0 : 2.0),  // Bo góc nhọn tùy thuộc vào vị trí
                                  bottomRight: Radius.circular(isMine ? 2.0 : 16.0),
                                ),
                              ),
                              child: Text(
                                msg['content'] ?? '',
                                // Của mình: Chữ trắng. Của đối phương: Chữ đen
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black,
                                  fontSize: 15.0,
                                ),
                              ),
                            ),
                          ),
                          
                          // Đệm một khoảng trống nhỏ bên phải nếu là tin nhắn của mình để căn lề đẹp hơn
                          if (isMine) const SizedBox(width: 24.0),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 2. Ô NHẬP NỘI DUNG VÀ NÚT SEND
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                  onPressed: _onSendMessage, // Kích hoạt sự kiện send
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
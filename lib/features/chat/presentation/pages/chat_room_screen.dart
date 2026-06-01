
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';

class ChatRoomDetailScreen extends StatefulWidget {
  const ChatRoomDetailScreen({super.key});

  @override
  State<ChatRoomDetailScreen> createState() => _ChatRoomDetailScreenState();
}

class _ChatRoomDetailScreenState extends State<ChatRoomDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _onSendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // Gọi Cubit thực thi bắn sự kiện 'send' qua đường ống Socket
      context.read<ChatCubit>().sendMessage(content: text);
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
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    
                    // Xác định xem ai là người gửi dựa trên cấu trúc JSON lớp Message
                    // (Ví dụ tạm thời: so sánh id nếu id bằng id của bạn)
                    final bool isMine = msg['sender']['name'] == 'Tôi'; 

                    return Align(
                      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: isMine ? AppColors.primaryBlue : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          msg['content'] ?? '',
                          style: TextStyle(color: isMine ? Colors.white : Colors.black),
                        ),
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
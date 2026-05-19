import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../widgets/chat_bubble.dart';
import '../bloc/chat_cubit.dart';
import '../bloc/chat_state.dart';

class ChatRoomScreen extends StatefulWidget {
  final String partnerName;
  final String partnerAvatar;

  const ChatRoomScreen({
    super.key,
    required this.partnerName,
    required this.partnerAvatar,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Tạm gọi với ID đối tác giả định vì UI cũ chưa truyền partnerId
    context.read<ChatCubit>().fetchMessages("mock_partner_id");
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text;
    if (text.trim().isNotEmpty) {
      context.read<ChatCubit>().sendMessage(text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AvatarWidget(imageUrl: widget.partnerAvatar, radius: 18),
            const SizedBox(width: 12),
            Text(
              widget.partnerName,
              style: AppTextStyles.heading1.copyWith(fontSize: 18),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Khu vực tin nhắn
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                List<Map<String, dynamic>> messages = [];
                if (state is ChatInitial) {
                  messages = state.messages;
                } else if (state is ChatUpdated) {
                  messages = state.messages;
                }

                return ListView.builder(
                  reverse: true, // Tin nhắn mới nhất nằm dưới cùng
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['isMe'] as bool;
                    
                    // Nếu tin nhắn là của người khác, hiển thị avatar
                    final avatarUrl = isMe ? null : widget.partnerAvatar;

                    return ChatBubble(
                      text: msg['text'],
                      isMe: isMe,
                      avatarUrl: avatarUrl,
                    );
                  },
                );
              },
            ),
          ),
          
          // Thanh nhập tin nhắn
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(top: BorderSide(color: AppColors.dividerBorder.withValues(alpha: 0.5))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.image, color: AppColors.primaryBlue),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Nhắn tin...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(context),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                    onPressed: () => _sendMessage(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

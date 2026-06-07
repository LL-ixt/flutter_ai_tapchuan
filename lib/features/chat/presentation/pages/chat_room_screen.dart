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
  bool _showSend = false;

  @override
  void initState() {
    super.initState();
    // Reset ChatCubit state to avoid leaking previous conversation state
    context.read<ChatCubit>().reset();

    _messageController.addListener(() {
      final isNotEmpty = _messageController.text.trim().isNotEmpty;
      if (isNotEmpty != _showSend) {
        setState(() {
          _showSend = isNotEmpty;
        });
      }
    });
    // Khôi phục lịch sử tin nhắn và join phòng chat
    _loadHistoricalMessages();
  }

  Future<void> _loadHistoricalMessages() async {
    try {
      // Đánh dấu đã đọc hội thoại
      try {
        await ApiService.setReadMessage(
          widget.token,
          partnerId: widget.partnerInfo?['id'],
          conversationId: widget.conversationId,
        );
      } catch (e) {
        debugPrint("Lỗi setReadMessage: $e");
      }

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
        final List<Map<String, dynamic>> formattedMessages = messagesFromApi
            .map<Map<String, dynamic>>((msg) {
              return {
                'messageId':
                    msg['messageId'] ?? msg['message_id'] ?? msg['id'] ?? '',
                'content':
                    msg['message'] ?? msg['content'] ?? msg['text'] ?? '',
                'created': msg['created'] ?? DateTime.now().toIso8601String(),
                'sender': _asMap(msg['sender']) ?? _asMap(msg['user']) ?? {},
                'receiver': _asMap(msg['receiver']) ?? {},
              };
            })
            .toList();

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
    final String contentToSend = text.isNotEmpty ? text : "👍";

    // Gọi Cubit thực thi bắn sự kiện 'send' qua đường ống Socket
    final partnerId = context.read<ChatCubit>().state.partnerInfo?['id'] ?? '';
    context.read<ChatCubit>().sendMessage(
      content: contentToSend,
      partnerId: partnerId,
    );
    _messageController.clear();

    // Cuộn xuống cuối cùng để xem tin nhắn mới
    Timer(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  String _formatMessageTimestamp(dynamic rawTime) {
    if (rawTime == null || rawTime.toString().isEmpty) return '';
    try {
      final date = DateTime.parse(rawTime.toString()).toLocal();
      final now = DateTime.now();
      final minuteStr = date.minute < 10 ? '0${date.minute}' : '${date.minute}';
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return '${date.hour}:$minuteStr';
      } else {
        return '${date.day} thg ${date.month}, ${date.hour}:$minuteStr';
      }
    } catch (_) {
      return '';
    }
  }

  void _showDeleteMessageDialog(Map<String, dynamic> msg) {
    final String myId = widget.myInfo?['id'] ?? '';
    final senderMap = _asMap(msg['sender']) ?? {};
    final String senderId = senderMap['id']?.toString() ?? '';
    final bool isMine = (senderId == myId) || (msg['sender']['name'] == 'Tôi');

    if (!isMine) {
      // Messenger only allows un-sending your own messages
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn chỉ có thể xóa tin nhắn của chính mình.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xóa tin nhắn'),
          content: const Text('Bạn có chắc chắn muốn xóa tin nhắn này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                final messageId =
                    msg['messageId'] ?? msg['message_id'] ?? msg['id'] ?? '';
                if (messageId.isNotEmpty) {
                  try {
                    final result = await ApiService.deleteMessage(
                      widget.token,
                      messageId,
                    );
                    if (result['code'] == '1000') {
                      if (mounted) {
                        _loadHistoricalMessages();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa tin nhắn')),
                        );
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Lỗi khi xóa tin nhắn',
                            ),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
                    }
                  }
                }
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: BlocBuilder<ChatCubit, ChatState>(
          builder: (context, state) {
            final partnerName =
                state.partnerInfo?['username'] ??
                state.partnerInfo?['name'] ??
                'Phòng Chat';
            final partnerAvatar = state.partnerInfo?['avatar'] ?? '';
            return Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue[50],
                      backgroundImage: partnerAvatar.isNotEmpty
                          ? NetworkImage(partnerAvatar)
                          : null,
                      child: partnerAvatar.isEmpty
                          ? Text(
                              partnerName.isNotEmpty
                                  ? partnerName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        partnerName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'Đang hoạt động',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.videocam, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.info, color: AppColors.primaryBlue),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. DANH SÁCH TIN NHẮN ĐẬP NHẢ THỜI GIAN THỰC
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                final messages = state.messages;
                final String myId = widget.myInfo?['id'] ?? '';

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final senderMap = _asMap(msg['sender']) ?? {};
                    final String senderId = senderMap['id']?.toString() ?? '';
                    final bool isMine =
                        (senderId == myId) || (msg['sender']['name'] == 'Tôi');

                    final String partnerAvatar =
                        state.partnerInfo?['avatar'] ?? '';
                    final String partnerName =
                        state.partnerInfo?['username'] ??
                        state.partnerInfo?['name'] ??
                        'P';

                    // 1.1 Tính toán hiển thị Timestamp ở giữa
                    bool showTimestamp = false;
                    if (index == 0) {
                      showTimestamp = true;
                    } else {
                      final prevMsg = messages[index - 1];
                      final prevCreated =
                          prevMsg['created'] ?? prevMsg['createdAt'];
                      final currCreated = msg['created'] ?? msg['createdAt'];
                      if (prevCreated != null && currCreated != null) {
                        try {
                          final prevTime = DateTime.parse(
                            prevCreated.toString(),
                          );
                          final currTime = DateTime.parse(
                            currCreated.toString(),
                          );
                          if (currTime.difference(prevTime).inMinutes > 15) {
                            showTimestamp = true;
                          }
                        } catch (_) {}
                      }
                    }

                    // 1.2 Tính toán hiển thị Avatar của đối phương bên trái (chỉ hiển thị ở tin nhắn cuối cùng của nhóm tin)
                    bool showAvatar = false;
                    if (!isMine) {
                      if (index == messages.length - 1) {
                        showAvatar = true;
                      } else {
                        final nextMsg = messages[index + 1];
                        final nextSenderMap = _asMap(nextMsg['sender']) ?? {};
                        final String nextSenderId =
                            nextSenderMap['id']?.toString() ?? '';
                        final bool nextIsMine =
                            (nextSenderId == myId) ||
                            (nextMsg['sender']['name'] == 'Tôi');
                        if (nextIsMine) {
                          showAvatar = true;
                        }
                      }
                    }

                    final messageContent = msg['content'] ?? '';

                    // Kiểm tra xem tin nhắn có phải là Like "👍" không để hiển thị to hơn không có bong bóng
                    final bool isLikeEmoji = messageContent == "👍";

                    Widget bubbleChild;
                    if (isLikeEmoji) {
                      bubbleChild = const Text(
                        "👍",
                        style: TextStyle(fontSize: 36),
                      );
                    } else {
                      bubbleChild = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 10.0,
                        ),
                        decoration: BoxDecoration(
                          color: isMine
                              ? AppColors.primaryBlue
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          messageContent,
                          style: TextStyle(
                            color: isMine ? Colors.white : Colors.black87,
                            fontSize: 15.0,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        if (showTimestamp) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: Text(
                                _formatMessageTimestamp(
                                  msg['created'] ?? msg['createdAt'],
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: isMine
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Avatar đối phương (bên trái)
                              if (!isMine) ...[
                                SizedBox(
                                  width: 32,
                                  child: showAvatar
                                      ? CircleAvatar(
                                          radius: 14,
                                          backgroundColor: Colors.grey[200],
                                          backgroundImage:
                                              partnerAvatar.isNotEmpty
                                              ? NetworkImage(partnerAvatar)
                                              : null,
                                          child: partnerAvatar.isEmpty
                                              ? Text(
                                                  partnerName.isNotEmpty
                                                      ? partnerName[0]
                                                            .toUpperCase()
                                                      : 'P',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.black54,
                                                  ),
                                                )
                                              : null,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                const SizedBox(width: 8.0),
                              ],
                              // Bong bóng chat hoặc Emoji Like
                              Flexible(
                                child: GestureDetector(
                                  onLongPress: () =>
                                      _showDeleteMessageDialog(msg),
                                  onSecondaryTap: () =>
                                      _showDeleteMessageDialog(msg),
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 260,
                                    ),
                                    child: bubbleChild,
                                  ),
                                ),
                              ),
                              if (isMine) const SizedBox(width: 12.0),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // 2. Ô NHẬP NỘI DUNG VÀ CÁC NÚT TIỆN ÍCH (Capsule)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              child: Row(
                children: [
                  // Nút tiện ích bên trái ô nhập liệu
                  IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.photo,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.mic,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                    onPressed: () {},
                  ),

                  // Ô nhập liệu dạng Capsule
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: "Tin nhắn",
                                hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.sentiment_satisfied_alt,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Nút gửi (hoặc nút Like nếu ô nhập trống)
                  IconButton(
                    icon: Icon(
                      _showSend ? Icons.send : Icons.thumb_up,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                    onPressed: _onSendMessage,
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

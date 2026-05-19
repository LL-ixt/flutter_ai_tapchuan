import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import 'chat_room_screen.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả lập danh sách 5 cuộc hội thoại
    final List<Map<String, dynamic>> mockChats = [
      {
        "id": "1",
        "name": "Trần Thị B",
        "avatar": "https://i.pravatar.cc/150?u=1",
        "last_message": "Cảm ơn bạn nhé!",
        "time": "10:20",
        "unread": true,
      },
      {
        "id": "2",
        "name": "Lê Văn C",
        "avatar": "https://i.pravatar.cc/150?u=2",
        "last_message": "Tài liệu này tải ở đâu vậy bạn?",
        "time": "Hôm qua",
        "unread": true,
      },
      {
        "id": "3",
        "name": "Giảng viên D",
        "avatar": "https://i.pravatar.cc/150?u=3",
        "last_message": "Ok em.",
        "time": "Hôm qua",
        "unread": false,
      },
      {
        "id": "4",
        "name": "Nhóm Học tập Lập trình",
        "avatar": "https://i.pravatar.cc/150?u=4",
        "last_message": "Mai mọi người nhớ nộp bài tập đúng hạn nha.",
        "time": "T2",
        "unread": false,
      },
      {
        "id": "5",
        "name": "Nguyễn Văn A",
        "avatar": "https://i.pravatar.cc/150?u=5",
        "last_message": "Haha chuẩn luôn =))",
        "time": "CN",
        "unread": false,
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0.5,
        title: Text('Chat', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: AppColors.scaffoldBackground,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.textPrimary),
              onPressed: () {
                // Chức năng tạo tin nhắn mới
              },
              tooltip: 'Tạo tin nhắn mới',
            ),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: mockChats.length,
        itemBuilder: (context, index) {
          final chat = mockChats[index];
          final bool isUnread = chat['unread'] ?? false;

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                    partnerName: chat['name'],
                    partnerAvatar: chat['avatar'],
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  // Avatar người chat
                  AvatarWidget(
                    imageUrl: chat['avatar'],
                    radius: 28,
                  ),
                  const SizedBox(width: 12),
                  
                  // Thông tin người chat và tin nhắn cuối
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat['name'],
                          style: AppTextStyles.nameHeading.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${chat['last_message']} • ${chat['time']}",
                          style: AppTextStyles.subtitle.copyWith(
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            color: isUnread ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Cột bên phải: Chấm xanh nếu chưa đọc
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

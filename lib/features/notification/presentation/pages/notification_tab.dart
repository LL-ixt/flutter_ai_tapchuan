import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';

class NotificationTab extends StatefulWidget {
  const NotificationTab({super.key});

  @override
  State<NotificationTab> createState() => _NotificationTabState();
}

class _NotificationTabState extends State<NotificationTab> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    // Tạo Mock Data thông báo
    _notifications = List.generate(10, (index) {
      final isLike = index % 2 == 0;
      return {
        "id": "notif_$index",
        "sender": "Học viên $index",
        "avatar": "https://i.pravatar.cc/150?u=notif_$index",
        "action": isLike ? "đã thích bài viết của bạn." : "đã bình luận về bài viết của bạn.",
        "time": "${index + 1} giờ trước",
        "isRead": index > 2, // 3 cái đầu chưa đọc
        "type": isLike ? "like" : "comment",
      };
    });
  }

  void _markAsRead(int index) {
    if (!_notifications[index]["isRead"]) {
      setState(() {
        _notifications[index]["isRead"] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite, // Nền chung màu trắng
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0.5,
        title: Text('Thông báo', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notif = _notifications[index];
          final isRead = notif["isRead"] as bool;
          final type = notif["type"] as String;
          
          IconData badgeIcon;
          Color badgeColor;
          
          if (type == "like") {
            badgeIcon = Icons.thumb_up;
            badgeColor = AppColors.primaryBlue;
          } else {
            badgeIcon = Icons.mode_comment;
            badgeColor = AppColors.successGreen;
          }

          return InkWell(
            onTap: () => _markAsRead(index),
            child: Container(
              color: isRead ? AppColors.surfaceWhite : AppColors.secondaryBlueLight,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AvatarWidget(imageUrl: notif["avatar"], radius: 30),
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: badgeColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surfaceWhite, width: 2),
                          ),
                          child: Icon(badgeIcon, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyMain,
                            children: [
                              TextSpan(text: "${notif['sender']} ", style: AppTextStyles.nameHeading),
                              TextSpan(text: notif['action']),
                            ],
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notif['time'],
                          style: AppTextStyles.subtitle.copyWith(
                            color: isRead ? AppColors.textSecondary : AppColors.primaryBlue,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Options Icon
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
                    onPressed: () {},
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

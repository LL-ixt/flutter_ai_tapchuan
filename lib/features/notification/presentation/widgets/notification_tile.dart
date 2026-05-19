import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  Widget _buildBadgeIcon() {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case 'like':
        iconData = Icons.thumb_up;
        iconColor = AppColors.primaryBlue;
        break;
      case 'comment':
        iconData = Icons.comment;
        iconColor = AppColors.successGreen;
        break;
      case 'system':
      default:
        iconData = Icons.notifications;
        iconColor = AppColors.warningYellow;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: iconColor,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surfaceWhite, width: 2),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: Colors.white,
          size: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: notification.isRead 
            ? AppColors.surfaceWhite 
            : AppColors.secondaryBlueLight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AvatarWidget(
                  imageUrl: notification.senderAvatarUrl,
                  radius: 28,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: _buildBadgeIcon(),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: '${notification.senderName} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: notification.content,
                        ),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.time,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 13,
                      color: notification.isRead 
                          ? AppColors.textSecondary 
                          : AppColors.primaryBlue,
                      fontWeight: notification.isRead 
                          ? FontWeight.normal 
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.more_horiz, color: AppColors.primaryIconAction),
                if (!notification.isRead)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Icon(
                      Icons.circle,
                      color: AppColors.primaryBlue,
                      size: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

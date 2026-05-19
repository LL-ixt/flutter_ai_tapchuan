import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String? avatarUrl;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && avatarUrl != null) ...[
            AvatarWidget(imageUrl: avatarUrl!, radius: 14),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryBlue : AppColors.scaffoldBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
              ),
              child: Text(
                text,
                style: AppTextStyles.bodyMain.copyWith(
                  color: isMe ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
          
          // Thêm khoảng trống bên phải nếu là người khác gửi để bubble không dài kịch lề
          if (!isMe) const SizedBox(width: 48),
          if (isMe) const SizedBox(width: 8), // Padding nhẹ cho đẹp
        ],
      ),
    );
  }
}

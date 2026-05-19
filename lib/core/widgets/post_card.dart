import 'package:flutter/material.dart';
import '../constants/color_constants.dart';
import '../constants/text_style_constants.dart';
import 'avatar_widget.dart';

class PostCard extends StatelessWidget {
  final Map<String, dynamic> postData;
  final bool isLiked;
  final VoidCallback onLikeToggle;

  const PostCard({
    super.key,
    required this.postData,
    required this.isLiked,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceWhite,
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 8.0),
          if (postData['described'] != null && postData['described'].toString().isNotEmpty)
            _buildBody(),
          const SizedBox(height: 8.0),
          _buildMedia(),
          const SizedBox(height: 8.0),
          _buildStats(),
          const Divider(color: AppColors.dividerBorder, height: 1.0, thickness: 0.5),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final author = postData['author'] ?? {};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          AvatarWidget(
            imageUrl: author['avatar'] ?? '',
            radius: 20,
            isOnline: true,
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author['username'] ?? 'Người dùng',
                  style: AppTextStyles.nameHeading,
                ),
                Row(
                  children: [
                    Text(
                      postData['created_at'] ?? 'Vừa xong',
                      style: AppTextStyles.subtitle,
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(Icons.public, size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.primaryIconAction),
            onPressed: () => _showOptionsBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        postData['described'] ?? '',
        style: AppTextStyles.bodyMain,
      ),
    );
  }

  Widget _buildMedia() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.black,
      child: Row(
        children: [
          Expanded(child: _buildVideoPlaceholder()),
          Container(width: 2, color: Colors.white), // Đường kẻ chia đôi
          Expanded(child: _buildVideoPlaceholder()),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.network(
            'https://picsum.photos/300/400',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[800]),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final likeCount = postData['like'] ?? '0';
    final commentCount = postData['comment'] ?? '0';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4.0),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.thumb_up, color: Colors.white, size: 12),
              ),
              const SizedBox(width: 6.0),
              Text(
                likeCount.toString(),
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
          Text(
            '$commentCount Bình luận',
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            label: 'Thích',
            color: isLiked ? AppColors.primaryBlue : AppColors.primaryIconAction,
            onTap: onLikeToggle,
          ),
          _buildActionButton(
            icon: Icons.chat_bubble_outline,
            label: 'Bình luận',
            color: AppColors.primaryIconAction,
            onTap: () => _showCommentBottomSheet(context),
          ),
          _buildActionButton(
            icon: Icons.send_outlined,
            label: 'Nộp bài',
            color: AppColors.primaryIconAction,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.dividerBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primaryIconAction),
                title: Text('Chỉnh sửa bài viết', style: AppTextStyles.bodyMain),
                onTap: () => Navigator.pop(ctx),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.errorRed),
                title: Text('Xóa bài viết', style: AppTextStyles.bodyMain.copyWith(color: AppColors.errorRed)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report, color: AppColors.primaryIconAction),
                title: Text('Báo cáo bài viết', style: AppTextStyles.bodyMain),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Xóa bài viết', style: AppTextStyles.heading1),
          content: Text('Bạn có chắc chắn muốn xóa bài viết này không?', style: AppTextStyles.bodyMain),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Hủy', style: AppTextStyles.buttonText.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa bài viết')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text("Bình luận", style: AppTextStyles.heading1.copyWith(fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.dividerBorder),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: _buildCommentList(),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  top: 8,
                  left: 16,
                  right: 16,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  border: Border(top: BorderSide(color: AppColors.dividerBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Viết bình luận...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: AppColors.primaryBlue),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildCommentList() {
    final comments = postData['comments'] as List<dynamic>?;
    
    if (comments != null && comments.isNotEmpty) {
      return comments.map((c) {
        final comment = c as Map<String, dynamic>;
        final isAi = comment['author'] == 'AI System';
        return _buildCommentItem(
          name: comment['author'] ?? 'Người dùng',
          avatar: comment['avatar'] ?? 'https://i.pravatar.cc/150?img=11',
          content: comment['text'] ?? '',
          time: comment['created_at'] ?? 'Vừa xong',
          isAi: isAi,
        );
      }).toList();
    }

    // Fallback cho bài viết chưa có list comment thực tế
    return [
      _buildCommentItem(
        name: "Giảng viên Nguyễn Văn A",
        avatar: "https://i.pravatar.cc/150?u=gv1",
        content: "Bài làm rất tốt, góc quay rõ ràng.",
        time: "1 giờ trước",
      ),
      _buildCommentItem(
        name: "AI Chấm Điểm",
        avatar: "https://i.pravatar.cc/150?img=11",
        content: "Phân tích chuyển động: Độ chính xác 85%. Tốc độ tay hơi chậm ở giây thứ 10. Điểm: 8.5/10.",
        time: "2 giờ trước",
        isAi: true,
      ),
      _buildCommentItem(
        name: "Trần Thị B",
        avatar: "https://i.pravatar.cc/150?u=hs2",
        content: "Bạn quay bằng máy gì mà nét vậy?",
        time: "3 giờ trước",
      ),
    ];
  }

  Widget _buildCommentItem({
    required String name,
    required String avatar,
    required String content,
    required String time,
    bool isAi = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarWidget(imageUrl: avatar, radius: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isAi ? AppColors.secondaryBlueLight : AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(name, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                          if (isAi) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle, color: AppColors.successGreen, size: 14),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(content, style: AppTextStyles.bodyMain),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(time, style: AppTextStyles.subtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4.0),
            Text(
              label,
              style: AppTextStyles.buttonText.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy data sử dụng API Contract cho PostCard
final Map<String, dynamic> dummyPostData = {
  "id": "post_123",
  "author": {
    "id": "user_987654",
    "username": "Nguyễn Tiến Thành",
    "avatar": "https://i.pravatar.cc/150?u=user_987654"
  },
  "described": "Đây là bài nộp bài tập số 1 của nhóm mình. Có 2 video so sánh giữa bài mẫu và bài làm.",
  "created_at": "2 giờ trước",
  "like": "150",
  "comment": "32"
};

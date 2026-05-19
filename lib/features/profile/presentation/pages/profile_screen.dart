import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../sync_record/presentation/pages/sync_record_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data cho UI
    final Map<String, dynamic> mockUser = {
      "username": "Nguyễn Văn A",
      "role": "Học viên",
      "description":
          "Đam mê học hỏi và khám phá tri thức mới. Luôn sẵn sàng kết bạn và trao đổi học tập.",
      "avatar": "https://i.pravatar.cc/150?img=11",
      "cover":
          "https://images.unsplash.com/photo-1707343843437-caacff5cfa74?q=80&w=1000&auto=format&fit=crop",
    };

    final List<Map<String, dynamic>> mockPosts = List.generate(3, (index) {
      return {
        "id": "profile_post_$index",
        "author": {
          "id": "user_a",
          "username": mockUser["username"],
          "avatar": mockUser["avatar"],
        },
        "described":
            "Đây là nhật ký học tập số ${index + 1} của mình. Cảm ơn mọi người đã theo dõi!",
        "created_at": "${index * 2 + 1} ngày trước",
        "like": "${(index + 1) * 20}",
        "comment": "${(index + 1) * 5}",
        "isLiked": false,
      };
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // AppBar trong suốt hoặc có màu để tạo cảm giác mượt mà khi cuộn
          SliverAppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            pinned: true,
            title: Text(mockUser["username"], style: AppTextStyles.heading1),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SyncRecordScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // Header: Cover + Avatar + Info
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surfaceWhite,
              child: Column(
                children: [
                  // Stack cho Ảnh bìa và Avatar
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Cover Photo (16:9 ratio approximately)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          image: DecorationImage(
                            image: NetworkImage(mockUser["cover"]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Avatar overlap
                      Positioned(
                        bottom: -60,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.all(
                            4,
                          ), // Viền trắng giống FB
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceWhite,
                            shape: BoxShape.circle,
                          ),
                          child: AvatarWidget(
                            imageUrl: mockUser["avatar"],
                            radius: 60,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Khoảng trống bù cho Avatar bị lồi xuống (60px + padding)
                  const SizedBox(height: 65),

                  // Thông tin người dùng
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mockUser["username"],
                          style: AppTextStyles.heading1.copyWith(fontSize: 24),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          mockUser["role"],
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mockUser["description"],
                          style: AppTextStyles.bodyMain,
                        ),
                        const SizedBox(height: 16),

                        // Hàng nút bấm chức năng
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.person_add, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Thêm bạn bè',
                                      style: AppTextStyles.buttonText.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Nút 3 chấm mở BottomSheet
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: AppColors.textPrimary,
                                ),
                                onPressed: () {
                                  _showMoreOptionsBottomSheet(context);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Thanh phân cách xám
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Tiêu đề Bài viết
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Bài viết',
                style: AppTextStyles.heading1.copyWith(fontSize: 18),
              ),
            ),
          ),

          // Danh sách bài viết cá nhân
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return PostCard(
                postData: mockPosts[index],
                isLiked: mockPosts[index]['isLiked'] ?? false,
                onLikeToggle: () {
                  // Cần có Cubit để xử lý Like, hiện tại Mock UI
                },
              );
            }, childCount: mockPosts.length),
          ),
        ],
      ),
    );
  }

  // Hàm mở BottomSheet Báo cáo/Chặn
  void _showMoreOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.report_problem_outlined,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    'Báo cáo trang cá nhân',
                    style: AppTextStyles.nameHeading,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.block,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  title: Text('Chặn', style: AppTextStyles.nameHeading),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  title: Text(
                    'Tìm kiếm trên trang cá nhân',
                    style: AppTextStyles.nameHeading,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

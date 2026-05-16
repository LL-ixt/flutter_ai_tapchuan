import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/search/search_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../post/presentation/pages/create_post_screen.dart';
import '../bloc/feed_cubit.dart';
import '../bloc/feed_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject BLoC ở cấp cao nhất của màn hình này
    return BlocProvider(
      create: (context) => FeedCubit()..fetchPosts(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // Social SliverAppBar
          SliverAppBar(
            backgroundColor: AppColors.surfaceWhite,
            title: const Text(
              'MERCARI',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -1.0,
              ),
            ),
            floating: true,
            actions: [
              // --- BẮT ĐẦU NÚT KÍNH LÚP ---
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: const BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: AppColors.textPrimary, size: 22),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                  },
                  splashRadius: 24,
                ),
              ),
              // --- KẾT THÚC NÚT KÍNH LÚP ---
              const SizedBox(width: 8.0),
              _buildAppBarIcon(Icons.messenger_outline), // Tương đương Messenger
              const SizedBox(width: 16.0),
            ],
          ),

          // Create Post Box
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const AvatarWidget(
                    imageUrl: 'https://i.pravatar.cc/150?img=60',
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        final feedCubit = context.read<FeedCubit>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: feedCubit,
                              child: const CreatePostScreen(),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.dividerBorder),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Bạn đang nghĩ gì?',
                          style: AppTextStyles.bodyMain.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.photo_library, color: Colors.green),
                ],
              ),
            ),
          ),

          // Render List Post bằng BlocBuilder
          BlocBuilder<FeedCubit, FeedState>(
            builder: (context, state) {
              if (state is FeedInitial || state is FeedLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                );
              } else if (state is FeedLoaded) {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        postData: post,
                        isLiked: post['isLiked'] ?? false,
                        onLikeToggle: () {
                          // Dispatch sự kiện đổi trạng thái Thích
                          context.read<FeedCubit>().toggleLike(post['id']);
                        },
                      );
                    },
                    childCount: state.posts.length,
                  ),
                );
              } else if (state is FeedError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  ),
                );
              }
              return const SliverFillRemaining(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }

  // Nút tròn trên AppBar
  Widget _buildAppBarIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground, // Nền xám nhạt như Facebook
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 22),
        onPressed: () {},
        splashRadius: 24,
      ),
    );
  }
}

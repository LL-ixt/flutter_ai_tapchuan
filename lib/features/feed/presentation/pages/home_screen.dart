import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/search/search_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../chat/presentation/pages/chat_screen.dart';
import '../../../post/presentation/pages/create_post_screen.dart';
import '../bloc/feed_cubit.dart';
import '../bloc/feed_state.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    // Inject BLoC ở cấp cao nhất của màn hình này
    return BlocProvider(
      create: (context) => FeedCubit()..fetchPosts(token: authState.token),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int _unreadChatCount = 0;
  Timer? _unreadTimer;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _unreadTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _loadUnreadCount();
    });
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    if (!mounted) return;
    final token = context.read<AuthCubit>().state.token;
    if (token == null || token.isEmpty) return;
    try {
      final result = await ApiService.getListConversation(token, 0, 1);
      if (result['code'] == '1000' && mounted) {
        final data = result['data'];
        final numNewStr = data['numNewMessage']?.toString() ?? '0';
        final count = int.tryParse(numNewStr) ?? 0;
        if (mounted) {
          setState(() {
            _unreadChatCount = count;
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading unread count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentUsername = authState.username ?? "";

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          // Social SliverAppBar
          SliverAppBar(
            backgroundColor: AppColors.surfaceWhite,
            toolbarHeight: 72,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'EduSocial AI',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1.0,
                  ),
                ),
                if (currentUsername.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Hi $currentUsername',
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
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
                  icon: const Icon(
                    Icons.search,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  splashRadius: 24,
                ),
              ),
              // --- KẾT THÚC NÚT KÍNH LÚP ---
              const SizedBox(width: 8.0),
              _buildChatIconWithBadge(
                unreadCount: _unreadChatCount,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  ).then((_) => _loadUnreadCount());
                },
              ),
              const SizedBox(width: 12.0),
            ],
          ),

          // Create Post Box
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surfaceWhite,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, authState) {
                      return AvatarWidget(
                        imageUrl: authState.avatar,
                        radius: 20,
                      );
                    },
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.dividerBorder),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Bạn đang nghĩ gì?',
                          style: AppTextStyles.bodyMain.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final post = state.posts[index];
                    return PostCard(
                      postData: post,
                      isLiked: post['isLiked'] ?? false,
                      onLikeToggle: () {
                        final token = context.read<AuthCubit>().state.token;
                        context.read<FeedCubit>().toggleLike(
                          post['id'],
                          token: token,
                        );
                      },
                    );
                  }, childCount: state.posts.length),
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

  Widget _buildChatIconWithBadge({required int unreadCount, VoidCallback? onPressed}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: const BoxDecoration(
            color: AppColors.scaffoldBackground,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.messenger_outline, color: AppColors.textPrimary, size: 22),
            onPressed: onPressed,
            splashRadius: 24,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: -2,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Center(
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Nút tròn trên AppBar
  Widget _buildAppBarIcon(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.scaffoldBackground, // Nền xám nhạt như Facebook
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.textPrimary, size: 22),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}

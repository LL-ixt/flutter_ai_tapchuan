import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import 'package:flutter_ai_tapchuan/features/feed/presentation/bloc/feed_cubit.dart';
import '../bloc/post_cubit.dart';
import '../bloc/post_state.dart';

class CreatePostScreen extends StatelessWidget {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostCubit(),
      child: const _CreatePostView(),
    );
  }
}

class _CreatePostView extends StatelessWidget {
  const _CreatePostView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostSuccess) {
          // Gọi API lấy lại danh sách bài mới nhất từ server thay vì chèn bài ảo
          context.read<FeedCubit>().fetchPosts();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đăng bài thành công!')));
          Navigator.pop(context);
        } else if (state is PostError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is PostLoading;
        bool canSubmit = false;
        if (state is PostInitial) {
          canSubmit = state.canSubmit;
        }

        return Scaffold(
          backgroundColor: AppColors.surfaceWhite,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: isLoading ? null : () => Navigator.pop(context),
            ),
            title: Text('Tạo bài viết', style: AppTextStyles.heading1),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  onPressed: (canSubmit && !isLoading)
                      ? () => context.read<PostCubit>().submitPost()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    disabledBackgroundColor: Colors.grey[300],
                    foregroundColor: Colors.white,
                    disabledForegroundColor: Colors.grey[600],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Đăng',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hàng 1: Avatar và Tên
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AvatarWidget(
                      imageUrl: 'https://i.pravatar.cc/150?img=60',
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nguyễn Tiến Thành',
                          style: AppTextStyles.nameHeading,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.public,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text('Công khai', style: AppTextStyles.subtitle),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hàng 2: TextField
                Expanded(
                  child: TextField(
                    onChanged: (text) =>
                        context.read<PostCubit>().updateText(text),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Bạn đang nghĩ gì?',
                      hintStyle: AppTextStyles.heading1.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.normal,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Hàng 3: Chọn Video
                if (state is PostInitial)
                  Row(
                    children: [
                      Expanded(
                        child: _buildVideoSelector(
                          context: context,
                          url: state.leftVideoUrl,
                          label: 'Chọn Video Trái',
                          onTap: () =>
                              context.read<PostCubit>().pickLeftVideo(),
                          onRemove: () =>
                              context.read<PostCubit>().removeLeftVideo(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildVideoSelector(
                          context: context,
                          url: state.rightVideoUrl,
                          label: 'Chọn Video Phải',
                          onTap: () =>
                              context.read<PostCubit>().pickRightVideo(),
                          onRemove: () =>
                              context.read<PostCubit>().removeRightVideo(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoSelector({
    required BuildContext context,
    required String? url,
    required String label,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    if (url != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(url, fit: BoxFit.cover),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.scaffoldBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.dividerBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library,
              color: AppColors.primaryIconAction,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.buttonText.copyWith(
                color: AppColors.primaryIconAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

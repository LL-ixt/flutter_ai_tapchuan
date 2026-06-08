import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import 'package:flutter_ai_tapchuan/features/feed/presentation/bloc/feed_cubit.dart';
import '../bloc/post_cubit.dart';
import '../bloc/post_state.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../core/utils/dialog_utils.dart';

class CreatePostScreen extends StatelessWidget {
  final String? initialText;
  final String? courseId;
  final String? exerciseId;

  const CreatePostScreen({
    super.key,
    this.initialText,
    this.courseId,
    this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostCubit()..updateText(initialText ?? ''),
      child: _CreatePostView(
        initialText: initialText,
        courseId: courseId,
        exerciseId: exerciseId,
      ),
    );
  }
}

class _CreatePostView extends StatefulWidget {
  final String? initialText;
  final String? courseId;
  final String? exerciseId;

  const _CreatePostView({
    this.initialText,
    this.courseId,
    this.exerciseId,
  });

  @override
  State<_CreatePostView> createState() => _CreatePostViewState();
}

class _CreatePostViewState extends State<_CreatePostView> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      listener: (context, state) {
        if (state is PostSuccess) {
          try {
            context.read<FeedCubit>().addNewPost(state.newPost);
          } catch (e) {
            debugPrint("FeedCubit is not available in context: $e");
          }
          DialogUtils.showNotificationDialog(
            context: context,
            title: 'Thành công',
            message: 'Đăng bài viết thành công!',
            isSuccess: true,
            onConfirm: () => Navigator.pop(context),
          );
        } else if (state is PostError) {
          DialogUtils.showNotificationDialog(
            context: context,
            title: 'Lỗi đăng bài',
            message: state.message,
            isSuccess: false,
          );
        }
      },
      builder: (context, state) {
        final authState = context.read<AuthCubit>().state;
        final currentUsername = authState.username ?? "Người dùng";
        final currentAvatar = authState.avatar ?? "";
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
                      ? () {
                          final token = context.read<AuthCubit>().state.token;
                          context.read<PostCubit>().submitPost(
                            token: token,
                            courseId: widget.courseId,
                            exerciseId: widget.exerciseId,
                          );
                        }
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
                    AvatarWidget(imageUrl: currentAvatar, radius: 24),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentUsername, style: AppTextStyles.nameHeading),
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
                    controller: _controller,
                    readOnly: widget.exerciseId != null && widget.exerciseId!.isNotEmpty,
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
                          file: state.leftVideoFile,
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
                          file: state.rightVideoFile,
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
    required PlatformFile? file,
    required String label,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    if (file != null) {
      final sizeMb = (file.size / (1024 * 1024)).toStringAsFixed(2);
      return Container(
        height: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
          border: Border.all(color: AppColors.dividerBorder),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: Icon(
                    Icons.video_library,
                    color: AppColors.primaryBlue,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$sizeMb MB',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
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

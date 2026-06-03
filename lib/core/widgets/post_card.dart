import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:flutter_ai_tapchuan/features/post/presentation/bloc/comment_cubit.dart';
import 'package:flutter_ai_tapchuan/features/post/presentation/bloc/comment_state.dart';
import 'package:flutter_ai_tapchuan/features/post/presentation/bloc/post_action_cubit.dart';
import 'package:flutter_ai_tapchuan/features/post/presentation/bloc/post_action_state.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/edit_post_models.dart';
import 'package:flutter_ai_tapchuan/features/profile/presentation/pages/profile_screen.dart';
import '../constants/color_constants.dart';
import '../constants/text_style_constants.dart';
import '../utils/dialog_utils.dart';
import 'avatar_widget.dart';
import 'video_play_screen.dart';

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
          if (postData['described'] != null &&
              postData['described'].toString().isNotEmpty)
            _buildBody(),
          const SizedBox(height: 8.0),
          _buildMedia(context),
          const SizedBox(height: 8.0),
          _buildStats(),
          const Divider(
            color: AppColors.dividerBorder,
            height: 1.0,
            thickness: 0.5,
          ),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final author = postData['author'] ?? {};
    final isOnline = postData['is_online'] == '1'; // Or logic if available
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (author['id'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userId: author['id'].toString()),
                  ),
                );
              }
            },
            child: AvatarWidget(
              imageUrl: author['avatar'] ?? '',
              radius: 20,
              isOnline: isOnline,
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (author['id'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(userId: author['id'].toString()),
                    ),
                  );
                }
              },
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
                        postData['created'] ?? 'Vừa xong',
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(width: 4.0),
                      const Icon(Icons.public, size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_horiz,
              color: AppColors.primaryIconAction,
            ),
            onPressed: () => _showOptionsBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(postData['described'] ?? '', style: AppTextStyles.bodyMain),
    );
  }

  Widget _buildMedia(BuildContext context) {
    final List<dynamic> videos = postData['video'] ?? [];
    if (videos.isEmpty) {
      return const SizedBox.shrink();
    }

    if (videos.length == 1) {
      final video = videos[0];
      final videoUrl = video['url']?.toString() ?? '';
      final thumbUrl = video['thumb']?.toString() ?? '';
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: InkWell(
          onTap: () => _playVideo(context, videoUrl),
          child: _buildVideoPlaceholder(thumbUrl),
        ),
      );
    }

    final video1 = videos[0];
    final video2 = videos.length > 1 ? videos[1] : null;

    final video1Url = video1['url']?.toString() ?? '';
    final video1Thumb = video1['thumb']?.toString() ?? '';

    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _playVideo(context, video1Url),
              child: _buildVideoPlaceholder(video1Thumb),
            ),
          ),
          if (video2 != null) ...[
            Container(width: 2, color: Colors.white), // Đường kẻ chia đôi
            Expanded(
              child: InkWell(
                onTap: () =>
                    _playVideo(context, video2['url']?.toString() ?? ''),
                child: _buildVideoPlaceholder(
                  video2['thumb']?.toString() ?? '',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _playVideo(BuildContext context, String videoUrl) {
    if (videoUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayScreen(videoUrl: videoUrl),
      ),
    );
  }

  Widget _buildVideoPlaceholder(String thumbUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        image: thumbUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(thumbUrl),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                  debugPrint("Failed to load thumbnail: $exception");
                },
              )
            : null,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
        ),
      ),
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
                child: const Icon(
                  Icons.thumb_up,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 6.0),
              Text(likeCount.toString(), style: AppTextStyles.subtitle),
            ],
          ),
          Text('$commentCount Bình luận', style: AppTextStyles.subtitle),
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
            color: isLiked
                ? AppColors.primaryBlue
                : AppColors.primaryIconAction,
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
    final canEdit =
        postData['can_edit']?.toString() !=
        '0'; // default true if null or not '0'
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
                leading: Icon(
                  Icons.edit,
                  color: canEdit ? AppColors.primaryIconAction : Colors.grey,
                ),
                title: Text(
                  'Chỉnh sửa bài viết',
                  style: AppTextStyles.bodyMain.copyWith(
                    color: canEdit ? null : Colors.grey,
                  ),
                ),
                onTap: canEdit
                    ? () {
                        Navigator.pop(ctx);
                        _showEditPostDialog(context);
                      }
                    : null,
              ),
              ListTile(
                leading: Icon(
                  Icons.delete,
                  color: canEdit ? AppColors.errorRed : Colors.grey,
                ),
                title: Text(
                  'Xóa bài viết',
                  style: AppTextStyles.bodyMain.copyWith(
                    color: canEdit ? AppColors.errorRed : Colors.grey,
                  ),
                ),
                onTap: canEdit
                    ? () {
                        Navigator.pop(ctx);
                        _showDeleteConfirmDialog(context);
                      }
                    : null,
              ),
              ListTile(
                leading: const Icon(
                  Icons.report,
                  color: AppColors.primaryIconAction,
                ),
                title: Text('Báo cáo bài viết', style: AppTextStyles.bodyMain),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReportPostDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final token = authState.token ?? '';
    final postId = postData['id'] ?? '';

    showDialog(
      context: context,
      builder: (ctx) {
        return BlocProvider<PostActionCubit>(
          create: (context) => PostActionCubit(),
          child: BlocConsumer<PostActionCubit, PostActionState>(
            listener: (dialogCtx, state) {
              if (state.isSuccess && state.actionType == 'delete') {
                DialogUtils.showNotificationDialog(
                  context: context,
                  title: 'Thành công',
                  message: 'Đã xóa bài viết thành công!',
                  isSuccess: true,
                  onConfirm: () {
                    context.read<FeedCubit>().fetchPosts(token: token);
                    Navigator.pop(dialogCtx);
                  },
                );
              } else if (state.error != null) {
                DialogUtils.showNotificationDialog(
                  context: context,
                  title: 'Thất bại',
                  message: 'Lỗi: ${state.error}',
                  isSuccess: false,
                );
              }
            },
            builder: (dialogCtx, state) {
              return AlertDialog(
                title: Text('Xóa bài viết', style: AppTextStyles.heading1),
                content: state.isLoading
                    ? const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Text(
                        'Bạn có chắc chắn muốn xóa bài viết này không?',
                        style: AppTextStyles.bodyMain,
                      ),
                actions: [
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.pop(dialogCtx),
                    child: Text(
                      'Hủy',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            dialogCtx.read<PostActionCubit>().deletePost(
                              postId: postId,
                              token: token,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                    ),
                    child: const Text(
                      'Xóa',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showReportPostDialog(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final token = authState.token ?? '';
    final postId = postData['id'] ?? '';
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return BlocProvider<PostActionCubit>(
          create: (context) => PostActionCubit(),
          child: BlocConsumer<PostActionCubit, PostActionState>(
            listener: (dialogCtx, state) {
              if (state.isSuccess && state.actionType == 'report') {
                DialogUtils.showNotificationDialog(
                  context: context,
                  title: 'Thành công',
                  message: 'Báo cáo bài viết thành công!',
                  isSuccess: true,
                  onConfirm: () {
                    Navigator.pop(dialogCtx);
                  },
                );
              } else if (state.error != null) {
                DialogUtils.showNotificationDialog(
                  context: context,
                  title: 'Thất bại',
                  message: 'Lỗi: ${state.error}',
                  isSuccess: false,
                );
              }
            },
            builder: (dialogCtx, state) {
              return AlertDialog(
                title: Text('Báo cáo bài viết', style: AppTextStyles.heading1),
                content: state.isLoading
                    ? const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Nhập lý do báo cáo bài viết này:',
                            style: AppTextStyles.bodyMain,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: reasonController,
                            decoration: const InputDecoration(
                              hintText: 'Lý do báo cáo...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                actions: [
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.pop(dialogCtx),
                    child: Text(
                      'Hủy',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            final details = reasonController.text.trim();
                            dialogCtx.read<PostActionCubit>().reportPost(
                              postId: postId,
                              token: token,
                              subject: 'Báo cáo nội dung',
                              details: details.isNotEmpty
                                  ? details
                                  : 'Không có chi tiết',
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text(
                      'Gửi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showEditPostDialog(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final token = authState.token ?? '';
    final postId = postData['id'] ?? '';
    final TextEditingController textController = TextEditingController(
      text: postData['described'] ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return BlocProvider<PostActionCubit>(
          create: (context) => PostActionCubit(),
          child: BlocConsumer<PostActionCubit, PostActionState>(
            listener: (dialogCtx, state) {
              if (state.isSuccess && state.actionType == 'edit') {
                DialogUtils.showNotificationDialog(
                  context: context,
                  title: 'Thành công',
                  message: 'Chỉnh sửa bài viết thành công!',
                  isSuccess: true,
                  onConfirm: () {
                    context.read<FeedCubit>().fetchPosts(token: token);
                    Navigator.pop(dialogCtx);
                  },
                );
              } else if (state.error != null) {
                DialogUtils.showNotificationDialog(
                  context: context,
                  title: 'Thất bại',
                  message: 'Lỗi: ${state.error}',
                  isSuccess: false,
                );
              }
            },
            builder: (dialogCtx, state) {
              return AlertDialog(
                title: Text(
                  'Chỉnh sửa bài viết',
                  style: AppTextStyles.heading1,
                ),
                content: state.isLoading
                    ? const SizedBox(
                        height: 50,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: textController,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Nội dung bài viết mới...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                actions: [
                  TextButton(
                    onPressed: state.isLoading
                        ? null
                        : () => Navigator.pop(dialogCtx),
                    child: Text(
                      'Hủy',
                      style: AppTextStyles.buttonText.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            final described = textController.text.trim();
                            if (described.isNotEmpty) {
                              dialogCtx.read<PostActionCubit>().editPost(
                                request: EditPostRequest(
                                  token: token,
                                  id: postId,
                                  described: described,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                    ),
                    child: const Text(
                      'Lưu',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showCommentBottomSheet(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final token = authState.token ?? '';
    final userId = authState.userId ?? 'u1';
    final postId = postData['id'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return BlocProvider<CommentCubit>(
          create: (context) => CommentCubit(),
          child: _CommentBottomSheet(
            postId: postId,
            token: token,
            userId: userId,
          ),
        );
      },
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
            Text(label, style: AppTextStyles.buttonText.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _CommentBottomSheet extends StatefulWidget {
  final String postId;
  final String token;
  final String userId;

  const _CommentBottomSheet({
    required this.postId,
    required this.token,
    required this.userId,
  });

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final int _count = 10;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    context.read<CommentCubit>().fetchComments(
      postId: widget.postId,
      token: widget.token,
      userId: widget.userId,
      index: '0',
      count: _count.toString(),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _loadMore(int currentSize) {
    context.read<CommentCubit>().fetchComments(
      postId: widget.postId,
      token: widget.token,
      userId: widget.userId,
      index: currentSize.toString(),
      count: _count.toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CommentCubit, CommentState>(
      listener: (context, state) {
        if (state.isSuccess) {
          _textController.clear();
          // Auto-scroll to bottom
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
        if (state.submitError != null) {
          DialogUtils.showNotificationDialog(
            context: context,
            title: 'Lỗi gửi bình luận',
            message: state.submitError!,
            isSuccess: false,
          );
        }
      },
      builder: (context, state) {
        _hasMore = state.comments.length >= _count;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 24),
                    Text(
                      "Bình luận",
                      style: AppTextStyles.heading1.copyWith(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.dividerBorder),
              Expanded(
                child: state.isLoading && state.comments.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          if (_hasMore)
                            Center(
                              child: TextButton(
                                onPressed: () =>
                                    _loadMore(state.comments.length),
                                child: const Text("Tải thêm các bình luận..."),
                              ),
                            ),
                          ...state.comments.map(
                            (comment) => _buildCommentItem(
                              name: comment.poster.name,
                              avatar: comment.poster.avatar,
                              content: comment.comment,
                              time: comment.created,
                            ),
                          ),
                        ],
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
                  border: Border(
                    top: BorderSide(color: AppColors.dividerBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Viết bình luận...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    state.isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.primaryBlue,
                            ),
                            onPressed: () {
                              final text = _textController.text.trim();
                              if (text.isNotEmpty) {
                                context.read<CommentCubit>().submitComment(
                                  postId: widget.postId,
                                  token: widget.token,
                                  comment: text,
                                );
                              }
                            },
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isAi
                        ? AppColors.secondaryBlueLight
                        : AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isAi) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.check_circle,
                              color: AppColors.successGreen,
                              size: 14,
                            ),
                          ],
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
}

// Dummy data sử dụng API Contract cho PostCard
final Map<String, dynamic> dummyPostData = {
  "id": "post_123",
  "author": {
    "id": "user_987654",
    "username": "Nguyễn Tiến Thành",
    "avatar": "https://i.pravatar.cc/150?u=user_987654",
  },
  "described":
      "Đây là bài nộp bài tập số 1 của nhóm mình. Có 2 video so sánh giữa bài mẫu và bài làm.",
  "created_at": "2 giờ trước",
  "like": "150",
  "comment": "32",
};

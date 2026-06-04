import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/search/search_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../../core/widgets/input_box.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthCubit>().state.token ?? "";
    return BlocProvider(
      create: (context) => ProfileCubit()..loadProfileData(token: token, userId: userId),
      child: _ProfileView(userId: userId),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final String? userId;
  const _ProfileView({this.userId});

  void _showEditProfileSheet(BuildContext context, UserProfileEntity user) {
    final nameController = TextEditingController(text: user.name);
    final bioController = TextEditingController(text: user.bio);
    final profileCubit = context.read<ProfileCubit>();
    final authCubit = context.read<AuthCubit>();
    PlatformFile? newAvatarFile;
    PlatformFile? newCoverFile;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: profileCubit),
            BlocProvider.value(value: authCubit),
          ],
          child: StatefulBuilder(
            builder: (statefulContext, setSheetState) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(statefulContext).viewInsets.bottom + 20,
                  left: 20,
                  right: 20,
                  top: 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Chỉnh sửa trang cá nhân",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(sheetContext),
                          )
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      
                      // Edit Cover Image
                      const Text("Ảnh bìa", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () async {
                          final result = await FilePicker.pickFiles(type: FileType.image);
                          if (result != null && result.files.isNotEmpty) {
                            setSheetState(() {
                              newCoverFile = result.files.first;
                            });
                          }
                        },
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            image: newCoverFile != null
                                ? (kIsWeb
                                    ? DecorationImage(
                                        image: MemoryImage(newCoverFile!.bytes!),
                                        fit: BoxFit.cover,
                                      )
                                    : DecorationImage(
                                        image: FileImage(File(newCoverFile!.path!)),
                                        fit: BoxFit.cover,
                                      ))
                                : (user.coverUrl.isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(user.coverUrl),
                                        fit: BoxFit.cover,
                                        onError: (exception, stackTrace) {},
                                      )
                                    : null),
                          ),
                          child: newCoverFile == null && user.coverUrl.isEmpty
                              ? const Center(child: Icon(Icons.add_a_photo, size: 30, color: Colors.grey))
                              : const Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black54,
                                      radius: 16,
                                      child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Edit Avatar Image
                      const Text("Ảnh đại diện", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final result = await FilePicker.pickFiles(type: FileType.image);
                            if (result != null && result.files.isNotEmpty) {
                              setSheetState(() {
                                newAvatarFile = result.files.first;
                              });
                            }
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 45,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: newAvatarFile != null
                                    ? (kIsWeb
                                        ? MemoryImage(newAvatarFile!.bytes!) as ImageProvider
                                        : FileImage(File(newAvatarFile!.path!)) as ImageProvider)
                                    : (user.avatarUrl.isNotEmpty
                                        ? NetworkImage(user.avatarUrl) as ImageProvider
                                        : null),
                                onBackgroundImageError: (newAvatarFile != null || user.avatarUrl.isNotEmpty)
                                    ? (exception, stackTrace) {}
                                    : null,
                                child: (newAvatarFile == null && user.avatarUrl.isEmpty)
                                    ? const Icon(Icons.person, size: 45, color: Colors.grey)
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Edit Username
                      InputBox(
                        label: "Họ và tên",
                        hintText: "Nhập họ và tên mới",
                        controller: nameController,
                      ),
                      
                      // Edit Description
                      InputBox(
                        label: "Tiểu sử (Bio)",
                        hintText: "Nhập mô tả về bản thân",
                        controller: bioController,
                      ),
                      const SizedBox(height: 10),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () async {
                          final token = statefulContext.read<AuthCubit>().state.token ?? "";
                          final success = await statefulContext.read<ProfileCubit>().updateProfile(
                            token: token,
                            username: nameController.text.trim(),
                            description: bioController.text.trim(),
                            avatar: kIsWeb ? null : (newAvatarFile != null ? File(newAvatarFile!.path!) : null),
                            avatarBytes: kIsWeb ? newAvatarFile?.bytes : null,
                            avatarName: newAvatarFile?.name,
                            coverImage: kIsWeb ? null : (newCoverFile != null ? File(newCoverFile!.path!) : null),
                            coverImageBytes: kIsWeb ? newCoverFile?.bytes : null,
                            coverImageName: newCoverFile?.name,
                          );
                          if (success && statefulContext.mounted) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Cập nhật hồ sơ thành công!')),
                            );
                          }
                        },
                        child: const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            final authState = context.read<AuthCubit>().state;
            // Update AuthCubit details if we loaded our own profile
            if (state.userProfile.id == authState.userId || authState.userId == null) {
              context.read<AuthCubit>().updateUserInfo(
                username: state.userProfile.name,
                avatar: state.userProfile.avatarUrl,
              );
            }
          }
        },
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(child: Text(state.message, style: const TextStyle(color: AppColors.errorRed)));
            } else if (state is ProfileLoaded) {
              final user = state.userProfile;
              return CustomScrollView(
                slivers: [
                  _buildAppBar(context, user.name),
                  _buildProfileHeader(context, user),
                  _buildPostsList(context, state.userPosts),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title) {
    final currentUserId = context.read<AuthCubit>().state.userId;
    final isOtherUser = userId != null && userId != currentUserId;

    return SliverAppBar(
      backgroundColor: AppColors.surfaceWhite,
      pinned: true,
      elevation: 0.5,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {
            // Lệnh phóng sang trang Tìm Kiếm
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
          },
        ),
        if (isOtherUser)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) async {
              if (value == 'block') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Chặn người dùng'),
                    content: const Text('Bạn có chắc chắn muốn chặn người này không?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Chặn', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  final token = context.read<AuthCubit>().state.token ?? "";
                  final success = await context.read<ProfileCubit>().blockUser(token: token, userId: userId!);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã chặn người dùng này')));
                    Navigator.pop(context); // Quay lại trang trước
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Chặn thất bại')));
                  }
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'block',
                child: Text('Chặn'),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfileEntity user) {
    final currentUserId = context.read<AuthCubit>().state.userId;
    final isOtherUser = userId != null && userId != currentUserId;

    return SliverToBoxAdapter(
      child: Container(
        color: AppColors.surfaceWhite,
        margin: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover and Avatar
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                // Cover Photo
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.dividerBorder,
                    image: user.coverUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(user.coverUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          )
                        : null,
                  ),
                  child: user.coverUrl.isEmpty
                      ? const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 50))
                      : null,
                ),
                // Avatar (overlapping)
                Positioned(
                  bottom: -40,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surfaceWhite, width: 4),
                    ),
                    child: AvatarWidget(
                      imageUrl: user.avatarUrl,
                      radius: 60, // 120x120 as per specs
                      isOnline: user.isOnline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50), // Spacing for overlapping avatar
            // User Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user.bio,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Details (Location, Link)
                  Row(
                    children: [
                      const Icon(Icons.home, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text('Sống tại ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                      Text(user.location, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        user.link,
                        style: const TextStyle(color: AppColors.primaryBlue, fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Edit Profile Button
                  if (!isOtherUser)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showEditProfileSheet(context, user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dividerBorder.withValues(alpha: 0.3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Chỉnh sửa trang cá nhân',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(BuildContext context, List<Map<String, dynamic>> posts) {
    if (posts.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: Text('Chưa có bài viết nào.')),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final post = posts[index];
          return PostCard(
            postData: post,
            isLiked: post['isLiked'] ?? false,
            onLikeToggle: () {
              context.read<ProfileCubit>().toggleLikePost(post['id']);
            },
          );
        },
        childCount: posts.length,
      ),
    );
  }
}

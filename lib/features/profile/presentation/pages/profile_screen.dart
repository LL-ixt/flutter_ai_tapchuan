import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/search/search_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../core/widgets/post_card.dart';
import '../../../../core/widgets/input_box.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../chat/presentation/pages/chat_room_screen.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/profile_cubit.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    final token = context.read<AuthCubit>().state.token ?? "";
    final currentUserId = context.read<AuthCubit>().state.userId ?? "";
    final currentRole = context.read<AuthCubit>().state.role;
    return BlocProvider(
      create: (context) => ProfileCubit()
        ..loadProfileData(
          token: token,
          userId: userId,
          currentUserId: currentUserId,
          currentRole: currentRole,
        ),
      child: _ProfileView(userId: userId),
    );
  }
}

class _ProfileView extends StatefulWidget {
  final String? userId;
  const _ProfileView({this.userId});

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus([String? targetId]) async {
    final authState = context.read<AuthCubit>().state;
    final myUserId = authState.userId ?? "";
    final targetLecturerId = targetId ?? widget.userId ?? myUserId;
    if (myUserId.isNotEmpty && targetLecturerId.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final registeredList = prefs.getStringList('registered_lecturers_$myUserId') ?? [];
      if (mounted) {
        setState(() {
          _isRegistered = registeredList.contains(targetLecturerId);
        });
      }
    }
  }

  Future<void> _saveRegistration(String targetId) async {
    final authState = context.read<AuthCubit>().state;
    final myUserId = authState.userId ?? "";
    if (myUserId.isNotEmpty && targetId.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final registeredList = prefs.getStringList('registered_lecturers_$myUserId') ?? [];
      if (!registeredList.contains(targetId)) {
        registeredList.add(targetId);
        await prefs.setStringList('registered_lecturers_$myUserId', registeredList);
      }
      if (mounted) {
        setState(() {
          _isRegistered = true;
        });
      }
    }
  }

  bool _isTeacher(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase().trim();
    return r == 'gv' ||
        r == '2' ||
        r == 'giảng viên' ||
        r == 'giang viên' ||
        r == 'giangvien' ||
        r == 'teacher' ||
        r.contains('giáo viên') ||
        r.contains('giao vien');
  }

  bool _isStudent(String? role) {
    if (role == null) return false;
    final r = role.toLowerCase().trim();
    return r == 'hv' ||
        r == 'hs' ||
        r == '1' ||
        r == 'học viên' ||
        r == 'hoc vien' ||
        r == 'học sinh' ||
        r == 'hoc sinh' ||
        r == 'student';
  }

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
                                        // ignore: deprecated_member_use
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
                                        // ignore: deprecated_member_use
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
                            // ignore: deprecated_member_use
                            avatarBytes: kIsWeb ? newAvatarFile?.bytes : null,
                            avatarName: newAvatarFile?.name,
                            coverImage: kIsWeb ? null : (newCoverFile != null ? File(newCoverFile!.path!) : null),
                            // ignore: deprecated_member_use
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
            // Load registration status for the loaded profile ID
            _checkRegistrationStatus(state.userProfile.id);
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
    final isOtherUser = widget.userId != null && widget.userId != currentUserId;

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
                  final success = await context.read<ProfileCubit>().blockUser(token: token, userId: widget.userId!);
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
    final isOtherUser = widget.userId != null && widget.userId != currentUserId;

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
                  // Details (Location, Link) removed

                  // Role Indicator
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isTeacher(user.role) ? AppColors.primaryBlue : Colors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _isTeacher(user.role) ? 'Giáo viên' : 'Học viên',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Edit Profile Button or Send Registration Request Button
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
                    )
                  else
                    Row(
                      children: [
                        if (_isTeacher(user.role) && 
                            _isStudent(context.read<AuthCubit>().state.role)) ...[
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isRegistered
                                  ? null
                                  : () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text('Gửi đăng ký'),
                                          content: const Text('Bạn muốn gửi yêu cầu đăng ký học đến giáo viên này?'),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                            TextButton(
                                              onPressed: () => Navigator.pop(ctx, true), 
                                              child: const Text('Gửi', style: TextStyle(color: AppColors.primaryBlue))
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true && context.mounted) {
                                        final token = context.read<AuthCubit>().state.token ?? "";
                                        final myUserId = context.read<AuthCubit>().state.userId ?? "";
                                        final success = await context.read<ProfileCubit>().requestCourse(
                                          token: token,
                                          courseId: user.id,
                                          userId: myUserId,
                                        );
                                        if (success && context.mounted) {
                                          await _saveRegistration(user.id);
                                          if (context.mounted) {
                                            DialogUtils.showNotificationDialog(
                                              context: context,
                                              title: 'Thành công',
                                              message: 'Đã gửi yêu cầu thành công!',
                                              isSuccess: true,
                                            );
                                          }
                                        } else if (context.mounted) {
                                          DialogUtils.showNotificationDialog(
                                            context: context,
                                            title: 'Thất bại',
                                            message: 'Có thể là một trong các nguyên nhân sau:\nBạn đã gửi yêu cầu đăng ký rồi\nNgười dùng này chưa xác thực\nLỗi hệ thống mà chúng tôi đang khắc phục',
                                            isSuccess: false,
                                          );
                                        }
                                      }
                                  },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isRegistered ? Colors.grey[400] : AppColors.primaryBlue,
                                disabledBackgroundColor: Colors.grey[400],
                                disabledForegroundColor: Colors.white70,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              child: Text(
                                _isRegistered ? 'Đã gửi yêu cầu' : 'Gửi đăng ký',
                                style: TextStyle(
                                  color: _isRegistered ? Colors.white70 : Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              final authState = context.read<AuthCubit>().state;
                              final partnerInfo = {
                                'id': user.id,
                                'username': user.name,
                                'avatar': user.avatarUrl,
                              };
                              final myInfo = {
                                'id': authState.userId,
                                'username': authState.username,
                                'avatar': authState.avatar,
                              };

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatRoomDetailScreen(
                                    partnerInfo: partnerInfo,
                                    token: authState.token ?? "",
                                    myInfo: myInfo,
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Nhắn tin',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

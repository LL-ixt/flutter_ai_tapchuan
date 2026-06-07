import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../../../services/api_service.dart';
import '../../../feed/data/models/get_list_posts_models.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  void loadProfileData({
    required String token,
    String? userId,
    String? currentUserId,
    String? currentRole,
  }) async {
    emit(ProfileLoading());
    try {
      final result = await ApiService.getUserInfo(token: token, userId: userId);

      if (result['code'] == '1000' || result['code'] == '200') {
        final data = result['data'];
        final targetUserId = userId ?? data['id']?.toString() ?? '';
        final username = data['username']?.toString() ?? '';

        String fetchedRole = data['role']?.toString() ?? '';

        // Workaround: getUserInfo doesn't return role for the viewed user
        if (fetchedRole.isEmpty) {
          if (currentUserId != null && targetUserId == currentUserId) {
            fetchedRole = currentRole ?? '';
          } else if (username.isNotEmpty && currentUserId != null) {
            // Fetch correct role by querying the search API
            final searchRes = await ApiService.search(
              token,
              username,
              currentUserId,
              0,
              30,
            );
            if (searchRes['code'] == '1000' && searchRes['data'] != null) {
              final List users = searchRes['data']['users'] ?? [];
              for (var u in users) {
                if (u['id']?.toString() == targetUserId) {
                  fetchedRole = u['role']?.toString() ?? '';
                  break;
                }
              }
            }
          }
        }

        final userProfile = UserProfileEntity(
          id: targetUserId,
          name: username,
          avatarUrl: data['avatar']?.toString() ?? '',
          coverUrl:
              data['cover_image']?.toString() ??
              data['coverImage']?.toString() ??
              '',
          bio: data['description']?.toString() ?? '',
          location: 'Hà Nội, Việt Nam',
          link: 'github.com/profile',
          role: fetchedRole,
          isOnline: data['online'] == '1',
        );

        // Lấy danh sách bài viết
        final postResponse = await ApiService.getListPosts(
          GetListPostsRequest(
            token: token,
            userId: targetUserId,
            index: '0',
            count: '100',
          ), // Mặc định lấy nhiều chút cho profile
        );

        List<Map<String, dynamic>> userPosts = [];
        if (postResponse.code == '1000' || postResponse.code == '200') {
          userPosts = (postResponse.posts ?? [])
              .map((e) => e as Map<String, dynamic>)
              .toList();
        }

        emit(ProfileLoaded(userProfile: userProfile, userPosts: userPosts));
      } else {
        emit(
          ProfileError(
            message:
                result['message'] ?? 'Không thể tải thông tin trang cá nhân',
          ),
        );
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  Future<bool> updateProfile({
    required String token,
    String? username,
    File? avatar,
    Uint8List? avatarBytes,
    String? avatarName,
    File? coverImage,
    Uint8List? coverImageBytes,
    String? coverImageName,
    String? description,
  }) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoading());
      try {
        final result = await ApiService.setUserInfo(
          token,
          username: username,
          avatar: avatar,
          avatarBytes: avatarBytes,
          avatarName: avatarName,
          coverImage: coverImage,
          coverImageBytes: coverImageBytes,
          coverImageName: coverImageName,
          description: description,
        );

        if (result['code'] == '1000' || result['code'] == '200') {
          loadProfileData(token: token, userId: currentState.userProfile.id);
          return true;
        } else {
          emit(
            ProfileError(
              message: result['message'] ?? 'Lỗi cập nhật thông tin',
            ),
          );
          emit(currentState);
          return false;
        }
      } catch (e) {
        emit(ProfileError(message: e.toString()));
        emit(currentState);
        return false;
      }
    }
    return false;
  }

  Future<bool> blockUser({
    required String token,
    required String userId,
  }) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      try {
        final result = await ApiService.setBlock(token, userId, '0');
        if (result['code'] == '1000' || result['code'] == '200') {
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> requestCourse({
    required String token,
    required String courseId,
    required String userId,
  }) async {
    try {
      final result = await ApiService.setRequestCourse(token, courseId, userId);
      if (result['code'] == '1000' || result['code'] == '200') {
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  void toggleLikePost(String postId) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedPosts = currentState.userPosts.map((post) {
        if (post['id'] == postId) {
          final bool isLiked =
              (post['isLiked'] ?? false) || post['is_liked'] == '1';
          int currentLikes = int.tryParse(post['like']?.toString() ?? '0') ?? 0;

          if (!isLiked) {
            currentLikes++;
          } else {
            currentLikes--;
            if (currentLikes < 0) currentLikes = 0;
          }

          return {
            ...post,
            'isLiked': !isLiked,
            'is_liked': !isLiked ? '1' : '0',
            'like': currentLikes.toString(),
          };
        }
        return post;
      }).toList();

      emit(
        ProfileLoaded(
          userProfile: currentState.userProfile,
          userPosts: updatedPosts,
        ),
      );
    }
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../data/models/profile_mock_data.dart';
import '../../../../services/api_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  void loadProfileData({required String token, String? userId}) async {
    emit(ProfileLoading());
    try {
      final result = await ApiService.getUserInfo(token: token, userId: userId);
      
      if (result['code'] == '1000' || result['code'] == '200') {
        final data = result['data'];
        final userProfile = UserProfileEntity(
          id: data['id']?.toString() ?? '',
          name: data['username']?.toString() ?? '',
          avatarUrl: data['avatar']?.toString() ?? '',
          coverUrl: data['cover_image']?.toString() ?? data['coverImage']?.toString() ?? '',
          bio: data['description']?.toString() ?? '',
          location: 'Hà Nội, Việt Nam',
          link: 'github.com/profile',
        );

        final mockPosts = ProfileMockData.getUserPosts().map((post) {
          return {
            ...post,
            'author': {
              'id': userProfile.id,
              'username': userProfile.name,
              'avatar': userProfile.avatarUrl,
            }
          };
        }).toList();

        emit(ProfileLoaded(
          userProfile: userProfile,
          userPosts: mockPosts,
        ));
      } else {
        emit(ProfileError(message: result['message'] ?? 'Không thể tải thông tin trang cá nhân'));
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
          emit(ProfileError(message: result['message'] ?? 'Lỗi cập nhật thông tin'));
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

  void toggleLikePost(String postId) {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedPosts = currentState.userPosts.map((post) {
        if (post['id'] == postId) {
          final bool isLiked = post['isLiked'] ?? false;
          int currentLikes = int.tryParse(post['like'].toString()) ?? 0;
          
          if (!isLiked) {
            currentLikes++;
          } else {
            currentLikes--;
            if (currentLikes < 0) currentLikes = 0;
          }

          return {
            ...post,
            'isLiked': !isLiked,
            'like': currentLikes.toString(),
          };
        }
        return post;
      }).toList();
      
      emit(ProfileLoaded(
        userProfile: currentState.userProfile,
        userPosts: updatedPosts,
      ));
    }
  }
}

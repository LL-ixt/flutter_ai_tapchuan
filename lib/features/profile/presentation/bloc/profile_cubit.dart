import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../data/models/profile_mock_data.dart';
import '../../../../services/api_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  void loadProfileData() {
    emit(ProfileLoading());
    try {
      final userProfile = ProfileMockData.getCurrentUserProfile();
      final userPosts = ProfileMockData.getUserPosts();

      emit(ProfileLoaded(userProfile: userProfile, userPosts: userPosts));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  void toggleLikePost(String postId) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;
      final updatedPosts = currentState.userPosts.map((post) {
        if (post['id']?.toString() == postId) {
          final bool isLiked =
              post['is_liked'] == '1' ||
              post['is_liked'] == true ||
              post['isLiked'] == true;
          int currentLikes = int.tryParse(post['like']?.toString() ?? '0') ?? 0;

          if (!isLiked) {
            currentLikes++;
          } else {
            currentLikes--;
            if (currentLikes < 0) currentLikes = 0;
          }

          return {
            ...post,
            'is_liked': !isLiked,
            'isLiked': !isLiked,
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

      // Gọi API ngầm
      final token = ApiService.currentToken ?? "";
      if (token.isNotEmpty) {
        await ApiService.like(token, postId);
      }
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit() : super(FeedInitial());

  void fetchPosts() async {
    emit(FeedLoading());

    // Giả lập delay mạng 1.5 giây để thấy được CircularProgressIndicator
    await Future.delayed(const Duration(milliseconds: 1500));
    await ApiService.checkNewItem('0');

    // Mock 5 bài viết theo format của API Contract
    final List<Map<String, dynamic>> mockPosts = List.generate(5, (index) {
      return {
        "id": "post_$index",
        "author": {
          "id": "user_$index",
          "username": "Học viên $index",
          "avatar": "https://i.pravatar.cc/150?u=user_$index",
        },
        "described":
            "Đây là bài tập phần ${index + 1} của mình. Mọi người xem thử và góp ý giúp mình nhé!",
        "created_at": "${index + 1} giờ trước",
        "like": "${(index + 1) * 15}",
        "comment": "${(index + 1) * 4}",
        "isLiked": false, // Trường trạng thái Like ở local
      };
    });

    emit(FeedLoaded(mockPosts));
  }

  void toggleLike(String postId) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post['id'] == postId) {
          final bool currentlyLiked = post['isLiked'] ?? false;
          int currentLikeCount = int.tryParse(post['like'].toString()) ?? 0;

          if (!currentlyLiked) {
            currentLikeCount++;
          } else {
            currentLikeCount--;
            if (currentLikeCount < 0) currentLikeCount = 0;
          }

          return {
            ...post,
            'isLiked': !currentlyLiked,
            'like': currentLikeCount.toString(),
          };
        }
        return post;
      }).toList();

      emit(FeedLoaded(updatedPosts));
    }
  }

  void addNewPost(Map<String, dynamic> newPost) {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = List<Map<String, dynamic>>.from(currentState.posts)
        ..insert(0, newPost);
      emit(FeedLoaded(updatedPosts));
    }
  }
}

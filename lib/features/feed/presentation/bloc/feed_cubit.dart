import 'package:flutter_bloc/flutter_bloc.dart';
import 'feed_state.dart';
import '../../../../services/api_service.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit() : super(FeedInitial());

  void fetchPosts() async {
    emit(FeedLoading());
    try {
      final result = await ApiService.getListPosts("0", "10");
      if (result['code'] == '1000' && result['data'] != null) {
        final List<dynamic> rawPosts = result['data']['posts'] ?? [];
        final List<Map<String, dynamic>> posts = rawPosts
            .map((e) => e as Map<String, dynamic>)
            .toList();
        emit(FeedLoaded(posts));
      } else {
        emit(FeedError(result['message'] ?? 'Lỗi tải danh sách bài viết'));
      }
    } catch (e) {
      emit(FeedError('Lỗi kết nối: $e'));
    }
  }

  void toggleLike(String postId) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = currentState.posts.map((post) {
        if (post['id']?.toString() == postId) {
          final bool currentlyLiked =
              post['is_liked'] == '1' ||
              post['is_liked'] == true ||
              post['isLiked'] == true;
          int currentLikeCount =
              int.tryParse(post['like']?.toString() ?? '0') ?? 0;

          if (!currentlyLiked) {
            currentLikeCount++;
          } else {
            currentLikeCount--;
            if (currentLikeCount < 0) currentLikeCount = 0;
          }

          return {
            ...post,
            'is_liked': !currentlyLiked, // Cập nhật local
            'isLiked': !currentlyLiked,
            'like': currentLikeCount.toString(),
          };
        }
        return post;
      }).toList();

      emit(FeedLoaded(updatedPosts));

      // Gọi API ngầm ở background
      final token = ApiService.currentToken ?? "";
      if (token.isNotEmpty) {
        await ApiService.like(token, postId);
      }
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

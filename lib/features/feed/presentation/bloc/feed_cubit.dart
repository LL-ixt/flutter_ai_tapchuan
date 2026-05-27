import 'package:flutter_bloc/flutter_bloc.dart';
import 'feed_state.dart';
import '../../../../services/api_service.dart';
import '../../data/models/get_list_posts_models.dart';
import '../../../post/data/models/like_models.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit() : super(FeedInitial());

  void fetchPosts({
    String? token,
    String? userId,
    String categoryId = '0',
    String lastId = '0',
    String index = '0',
    String count = '20',
  }) async {
    emit(FeedLoading());

    try {
      final request = GetListPostsRequest(
        token: token,
        categoryId: categoryId,
        lastId: lastId,
        index: index,
        count: count,
        userId: userId ?? 'u1',
      );
      final response = await ApiService.getListPosts(request);

      if (response.code == '1000') {
        final list =
            response.posts?.map((e) {
              final postMap = Map<String, dynamic>.from(e as Map);
              if (postMap.containsKey('post_id')) {
                postMap['id'] = postMap['post_id'];
              }
              if (postMap.containsKey('is_liked')) {
                postMap['isLiked'] = postMap['is_liked'].toString() == '1';
              }
              if (postMap.containsKey('created')) {
                postMap['created_at'] = postMap['created'];
              }
              return postMap;
            }).toList() ??
            [];
        emit(FeedLoaded(list));
      } else {
        emit(FeedError(response.message));
      }
    } catch (e) {
      emit(FeedError('Lỗi hệ thống: $e'));
    }
  }

  void toggleLike(String postId, {String? token}) async {
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
            'is_liked': !currentlyLiked ? '1' : '0',
            'like': currentLikeCount.toString(),
          };
        }
        return post;
      }).toList();

      emit(FeedLoaded(updatedPosts));

      try {
        final request = LikeRequest(token: token, id: postId);
        final response = await ApiService.like(request);
        if (response.code == '1000') {
          final actualLikeCount = response.like;
          if (actualLikeCount != null) {
            final finalPosts = updatedPosts.map((post) {
              if (post['id'] == postId) {
                return {...post, 'like': actualLikeCount};
              }
              return post;
            }).toList();
            emit(FeedLoaded(finalPosts));
          }
        }
      } catch (e) {
        print("Lỗi khi gọi API like: $e");
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

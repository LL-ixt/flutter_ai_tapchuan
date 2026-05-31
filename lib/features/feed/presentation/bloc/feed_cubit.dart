import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'feed_state.dart';
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
        userId: userId ?? '',
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

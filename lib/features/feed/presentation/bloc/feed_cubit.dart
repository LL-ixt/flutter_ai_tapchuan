import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/dtw_calculator.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../data/models/post_model.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  final FeedRepository _feedRepository;

  FeedCubit(this._feedRepository) : super(FeedInitial());

  void fetchPosts() async {
    emit(FeedLoading());

    try {
      final posts = await _feedRepository.getListPosts();
      
      // Chuyển đổi Post object sang Map<String, dynamic> để tương thích với UI cũ
      final List<Map<String, dynamic>> postMaps = posts.map((post) {
        if (post is PostModel) {
          return post.toJson();
        }
        return <String, dynamic>{};
      }).toList();

      emit(FeedLoaded(postMaps));
    } catch (e) {
      // Vì repository đã xử lý offline cache, nếu lỗi văng ra nghĩa là không có cả mạng lẫn cache
      emit(FeedError(e.toString()));
    }
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

  void addNewPost(Map<String, dynamic> newPost) async {
    if (state is FeedLoaded) {
      final currentState = state as FeedLoaded;
      final updatedPosts = List<Map<String, dynamic>>.from(currentState.posts)
        ..insert(0, newPost);
      emit(FeedLoaded(updatedPosts));

      // Giả lập quá trình AI phân tích video ngầm (chạy background)
      await Future.delayed(const Duration(seconds: 4));

      // Dùng dummy data chạy qua thuật toán DTW
      final dummySeq1 = [0.0, 0.5, 1.0, 0.8, 0.2];
      final dummySeq2 = [0.1, 0.4, 0.8, 0.6, 0.1];
      final distance = DTWCalculator.calculateDTWDistance(dummySeq1, dummySeq2);
      final score = DTWCalculator.gradeMovement(distance);
      final formattedScore = score.toStringAsFixed(1);

      // Cập nhật lại bài viết với comment từ AI
      if (state is FeedLoaded) {
        final latestState = state as FeedLoaded;
        final currentPosts = List<Map<String, dynamic>>.from(latestState.posts);

        final postIndex = currentPosts.indexWhere((p) => p['id'] == newPost['id']);
        if (postIndex != -1) {
          final targetPost = Map<String, dynamic>.from(currentPosts[postIndex]);
          
          int currentCommentCount = int.tryParse(targetPost['comment'].toString()) ?? 0;
          
          // Thêm comment vào danh sách an toàn
          List<Map<String, dynamic>> comments = [];
          if (targetPost['comments'] != null) {
            comments = List<Map<String, dynamic>>.from(targetPost['comments']);
          }
          
          comments.add({
            "author": "AI System",
            "avatar": "https://cdn-icons-png.flaticon.com/512/4712/4712010.png",
            "text": "Hệ thống tự động chấm điểm: Bạn đạt $formattedScore/10. Lỗi sai: Tay phải chưa đưa đủ cao.",
            "created_at": "Vừa xong",
          });

          targetPost['comment'] = (currentCommentCount + 1).toString();
          targetPost['comments'] = comments;
          
          currentPosts[postIndex] = targetPost;
          
          emit(FeedLoaded(currentPosts));
        }
      }
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/utils/dtw_calculator.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit() : super(FeedInitial());

  void fetchPosts() async {
    final box = Hive.box(HiveService.cachedPostsBox);
    List<Map<String, dynamic>> cachedPosts = [];

    // 1. Đọc từ cache
    final cachedData = box.get('posts');
    if (cachedData != null) {
      cachedPosts = List<Map<String, dynamic>>.from(
        (cachedData as List).map((e) => Map<String, dynamic>.from(e as Map)),
      );
      emit(FeedLoaded(cachedPosts));
    } else {
      emit(FeedLoading());
    }

    try {
      // Giả lập delay mạng 1.5 giây
      await Future.delayed(const Duration(milliseconds: 1500));

      // MOCK LỖI MẠNG ĐỂ TEST CƠ CHẾ OFFLINE
      // throw Exception('Lỗi rớt mạng giả lập!');

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
          "isLiked": false,
        };
      });

      // 3. Lưu đè cache mới
      await box.put('posts', mockPosts);

      emit(FeedLoaded(mockPosts));
    } catch (e) {
      // Bắt lỗi mất mạng, nếu có cache thì giữ nguyên cache và hiện SnackBar
      if (cachedPosts.isNotEmpty) {
        emit(
          FeedLoaded(
            cachedPosts,
            isOffline: true,
            errorMessage: 'Không thể kết nối Internet',
          ),
        );
      } else {
        emit(FeedError('Không thể kết nối Internet'));
      }
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

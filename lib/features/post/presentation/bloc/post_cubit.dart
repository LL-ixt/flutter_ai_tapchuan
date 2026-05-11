import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(const PostInitial());

  void updateText(String text) {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(text: text));
    }
  }

  void pickLeftVideo() {
    if (state is PostInitial) {
      // Giả lập chọn video bằng một URL ảnh cover
      emit((state as PostInitial).copyWith(leftVideoUrl: 'https://picsum.photos/300/400?1'));
    }
  }

  void removeLeftVideo() {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(clearLeft: true));
    }
  }

  void pickRightVideo() {
    if (state is PostInitial) {
      // Giả lập chọn video bằng một URL ảnh cover
      emit((state as PostInitial).copyWith(rightVideoUrl: 'https://picsum.photos/300/400?2'));
    }
  }

  void removeRightVideo() {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(clearRight: true));
    }
  }

  Future<void> submitPost() async {
    if (state is PostInitial) {
      final currentState = state as PostInitial;
      if (!currentState.canSubmit) return;

      emit(PostLoading());
      // Giả lập thời gian đăng bài
      await Future.delayed(const Duration(seconds: 2));
      
      final newPost = {
        "id": "post_new_${DateTime.now().millisecondsSinceEpoch}",
        "author": {
          "id": "user_current",
          "username": "Nguyễn Tiến Thành",
          "avatar": "https://i.pravatar.cc/150?img=60"
        },
        "described": currentState.text,
        "created_at": "Vừa xong",
        "like": "0",
        "comment": "0",
        "isLiked": false,
      };

      emit(PostSuccess(newPost));
    }
  }
}

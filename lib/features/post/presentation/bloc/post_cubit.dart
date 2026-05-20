import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_state.dart';
import '../../../../services/api_service.dart';

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
      emit(
        (state as PostInitial).copyWith(
          leftVideoUrl: 'https://picsum.photos/300/400?1',
        ),
      );
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
      emit(
        (state as PostInitial).copyWith(
          rightVideoUrl: 'https://picsum.photos/300/400?2',
        ),
      );
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

      try {
        final token = ApiService.currentToken ?? "";
        // TODO: Chuyển đổi URL mock thành File thật khi bạn thêm thư viện chọn ảnh/video
        // File? leftVideo = currentState.leftVideoUrl != null ? File(...) : null;

        final result = await ApiService.addPost(
          token: token,
          described: currentState.text,
          deviceMaster: 'mock_device', // Bắt buộc theo API
          courseId: '1', // Bắt buộc với user Học viên (HV)
          exerciseId: '1', // Bắt buộc với user Học viên (HV)
        );

        if (result['code'] == '1000') {
          // Tạo một mock post để hiển thị tạm lên giao diện ngay lập tức
          final newPost = {
            "id":
                result['data']?['id']?.toString() ??
                "post_new_${DateTime.now().millisecondsSinceEpoch}",
            "author": {
              "id": "user_current",
              "username": "Tôi (Vừa đăng)",
              "avatar": "https://i.pravatar.cc/150?img=60",
            },
            "described": currentState.text,
            "created": "Vừa xong",
            "like": "0",
            "comment": "0",
            "is_liked": false,
          };
          emit(PostSuccess(newPost));
        } else {
          final errorMsg = result['message']?.toString() ?? 'Lỗi đăng bài';
          emit(PostError(errorMsg));
        }
      } catch (e) {
        emit(PostError('Lỗi kết nối: ${e.toString()}'));
      }
    }
  }
}

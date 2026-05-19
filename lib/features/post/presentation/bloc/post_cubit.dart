import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/post_remote_data_source.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostRemoteDataSource _postRemoteDataSource;

  PostCubit(this._postRemoteDataSource) : super(const PostInitial());

  void updateText(String text) {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(text: text));
    }
  }

  void pickLeftVideo(String path) {
    if (state is PostInitial) {
      // Nhận đường dẫn vật lý thực tế từ thiết bị
      emit((state as PostInitial).copyWith(leftVideoUrl: path));
    }
  }

  void removeLeftVideo() {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(clearLeft: true));
    }
  }

  void pickRightVideo(String path) {
    if (state is PostInitial) {
      // Nhận đường dẫn vật lý thực tế từ thiết bị
      emit((state as PostInitial).copyWith(rightVideoUrl: path));
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
        await _postRemoteDataSource.addProducts(
          described: currentState.text,
          leftVideoPath: currentState.leftVideoUrl!,
          rightVideoPath: currentState.rightVideoUrl!,
        );

        // API add_products thành công, giả lập trả về data post để UI cập nhật feed (hoặc reload feed)
        final newPost = {
          "id": "post_new_${DateTime.now().millisecondsSinceEpoch}",
          "author": {
            "id": "user_current",
            "username": "Bạn (Vừa đăng)",
            "avatar": "https://i.pravatar.cc/150?img=60"
          },
          "described": currentState.text,
          "created_at": "Vừa xong",
          "like": "0",
          "comment": "0",
          "isLiked": false,
        };

        emit(PostSuccess(newPost));
      } on ServerException catch (_) {
        // Tạm thời quay về Initial nếu lỗi, bạn có thể tạo PostError state sau
        emit(currentState);
        // Có thể emit lỗi qua biến boolean trong state hoặc state mới
      } catch (_) {
        emit(currentState);
      }
    }
  }
}

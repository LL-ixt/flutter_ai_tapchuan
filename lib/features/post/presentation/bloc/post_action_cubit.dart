import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_action_state.dart';
import '../../../../services/api_service.dart';
import '../../data/models/get_post_models.dart';
import '../../data/models/edit_post_models.dart';
import '../../data/models/delete_post_models.dart';
import '../../data/models/report_post_models.dart';

class PostActionCubit extends Cubit<PostActionState> {
  PostActionCubit() : super(const PostActionState.initial());

  Future<void> fetchPostDetail({
    required String postId,
    required String token,
    String? userId,
  }) async {
    emit(const PostActionState.loading());
    try {
      final request = GetPostRequest(token: token, id: postId, userId: userId);
      final response = await ApiService.getPost(request);

      if (response.code == '1000') {
        emit(PostActionState.success(postData: response.data, actionType: 'get'));
      } else {
        emit(PostActionState.failure(response.message));
      }
    } catch (e) {
      emit(PostActionState.failure('Lỗi hệ thống: $e'));
    }
  }

  Future<void> editPost({required EditPostRequest request}) async {
    emit(const PostActionState.loading());
    try {
      final response = await ApiService.editPost(request);
      if (response.code == '1000') {
        emit(const PostActionState.success(actionType: 'edit'));
      } else {
        emit(PostActionState.failure(response.message));
      }
    } catch (e) {
      emit(PostActionState.failure('Lỗi hệ thống: $e'));
    }
  }

  Future<void> deletePost({required String postId, required String token}) async {
    emit(const PostActionState.loading());
    try {
      final request = DeletePostRequest(token: token, id: postId);
      final response = await ApiService.deletePost(request);
      if (response.code == '1000') {
        emit(const PostActionState.success(actionType: 'delete'));
      } else {
        emit(PostActionState.failure(response.message));
      }
    } catch (e) {
      emit(PostActionState.failure('Lỗi hệ thống: $e'));
    }
  }

  Future<void> reportPost({
    required String postId,
    required String token,
    String? subject,
    String? details,
  }) async {
    emit(const PostActionState.loading());
    try {
      final request = ReportPostRequest(
        token: token,
        id: postId,
        subject: subject,
        details: details,
      );
      final response = await ApiService.reportPost(request);
      if (response.code == '1000') {
        emit(const PostActionState.success(actionType: 'report'));
      } else {
        emit(PostActionState.failure(response.message));
      }
    } catch (e) {
      emit(PostActionState.failure('Lỗi hệ thống: $e'));
    }
  }
}

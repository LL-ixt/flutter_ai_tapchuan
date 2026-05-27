import 'package:flutter_bloc/flutter_bloc.dart';
import 'comment_state.dart';
import '../../../../services/api_service.dart';
import '../../data/models/comment_models.dart';

class CommentCubit extends Cubit<CommentState> {
  CommentCubit() : super(const CommentState.initial());

  Future<void> fetchComments({
    required String postId,
    required String token,
    required String userId,
    String index = '0',
    String count = '10',
  }) async {
    emit(CommentState.loading(currentComments: state.comments));

    try {
      final request = GetCommentRequest(
        token: token,
        id: postId,
        index: index,
        count: count,
        userId: userId,
      );
      final response = await ApiService.getComment(request);

      if (response.code == '1000') {
        emit(
          CommentState.loaded(
            comments: response.data ?? [],
            isBlocked: response.isBlocked,
          ),
        );
      } else {
        emit(
          CommentState.error(
            error: response.message,
            currentComments: state.comments,
          ),
        );
      }
    } catch (e) {
      emit(
        CommentState.error(
          error: 'Lỗi hệ thống: $e',
          currentComments: state.comments,
        ),
      );
    }
  }

  Future<void> submitComment({
    required String postId,
    required String token,
    String? comment,
    String? score,
    String? detailMistakes,
    String index = '0',
    String count = '10',
  }) async {
    emit(CommentState.submitting(currentComments: state.comments));

    try {
      final request = SetCommentRequest(
        token: token,
        id: postId,
        comment: comment,
        score: score,
        detailMistakes: detailMistakes,
        index: index,
        count: count,
      );
      final response = await ApiService.setComment(request);

      if (response.code == '1000') {
        emit(
          CommentState.submitSuccess(
            comments: response.data ?? [],
            isBlocked: response.isBlocked,
          ),
        );
      } else {
        emit(
          CommentState.submitError(
            submitError: response.message,
            currentComments: state.comments,
          ),
        );
      }
    } catch (e) {
      emit(
        CommentState.submitError(
          submitError: 'Lỗi hệ thống: $e',
          currentComments: state.comments,
        ),
      );
    }
  }
}

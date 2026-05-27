import 'package:equatable/equatable.dart';
import '../../data/models/comment_models.dart';

class CommentState extends Equatable {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? submitError;
  final List<CommentItemModel> comments;
  final bool isSuccess;
  final String? isBlocked;

  const CommentState._({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.submitError,
    this.comments = const [],
    this.isSuccess = false,
    this.isBlocked,
  });

  const CommentState.initial() : this._();

  const CommentState.loading({List<CommentItemModel> currentComments = const []})
      : this._(isLoading: true, comments: currentComments);

  const CommentState.loaded({
    required List<CommentItemModel> comments,
    String? isBlocked,
  }) : this._(comments: comments, isBlocked: isBlocked);

  const CommentState.error({
    required String error,
    List<CommentItemModel> currentComments = const [],
  }) : this._(error: error, comments: currentComments);

  const CommentState.submitting({
    required List<CommentItemModel> currentComments,
  }) : this._(isSubmitting: true, comments: currentComments);

  const CommentState.submitSuccess({
    required List<CommentItemModel> comments,
    String? isBlocked,
  }) : this._(isSuccess: true, comments: comments, isBlocked: isBlocked);

  const CommentState.submitError({
    required String submitError,
    required List<CommentItemModel> currentComments,
  }) : this._(submitError: submitError, comments: currentComments);

  @override
  List<Object?> get props => [
        isLoading,
        isSubmitting,
        error,
        submitError,
        comments,
        isSuccess,
        isBlocked,
      ];
}

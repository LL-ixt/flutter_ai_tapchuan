import 'package:equatable/equatable.dart';

class PostActionState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final Map<String, dynamic>? postData;
  final String? actionType; // 'get', 'edit', 'delete', 'report'

  const PostActionState._({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.postData,
    this.actionType,
  });

  const PostActionState.initial() : this._();

  const PostActionState.loading() : this._(isLoading: true);

  const PostActionState.success({
    Map<String, dynamic>? postData,
    required String actionType,
  }) : this._(isSuccess: true, postData: postData, actionType: actionType);

  const PostActionState.failure(String error) : this._(error: error);

  @override
  List<Object?> get props => [isLoading, isSuccess, error, postData, actionType];
}

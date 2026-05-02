import 'package:equatable/equatable.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  final String text;
  final String? leftVideoUrl;
  final String? rightVideoUrl;

  const PostInitial({
    this.text = '',
    this.leftVideoUrl,
    this.rightVideoUrl,
  });

  bool get canSubmit => text.trim().isNotEmpty && (leftVideoUrl != null || rightVideoUrl != null);

  PostInitial copyWith({
    String? text,
    String? leftVideoUrl,
    String? rightVideoUrl,
    bool clearLeft = false,
    bool clearRight = false,
  }) {
    return PostInitial(
      text: text ?? this.text,
      leftVideoUrl: clearLeft ? null : (leftVideoUrl ?? this.leftVideoUrl),
      rightVideoUrl: clearRight ? null : (rightVideoUrl ?? this.rightVideoUrl),
    );
  }

  @override
  List<Object?> get props => [text, leftVideoUrl, rightVideoUrl];
}

class PostLoading extends PostState {}

class PostSuccess extends PostState {
  final Map<String, dynamic> newPost;
  const PostSuccess(this.newPost);

  @override
  List<Object?> get props => [newPost];
}

class PostError extends PostState {
  final String message;
  const PostError(this.message);

  @override
  List<Object?> get props => [message];
}

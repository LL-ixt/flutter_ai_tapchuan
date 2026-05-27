import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object?> get props => [];
}

class PostInitial extends PostState {
  final String text;
  final PlatformFile? leftVideoFile;
  final PlatformFile? rightVideoFile;

  const PostInitial({
    this.text = '',
    this.leftVideoFile,
    this.rightVideoFile,
  });

  bool get canSubmit => text.trim().isNotEmpty && (leftVideoFile != null || rightVideoFile != null);

  PostInitial copyWith({
    String? text,
    PlatformFile? leftVideoFile,
    PlatformFile? rightVideoFile,
    bool clearLeft = false,
    bool clearRight = false,
  }) {
    return PostInitial(
      text: text ?? this.text,
      leftVideoFile: clearLeft ? null : (leftVideoFile ?? this.leftVideoFile),
      rightVideoFile: clearRight ? null : (rightVideoFile ?? this.rightVideoFile),
    );
  }

  @override
  List<Object?> get props => [text, leftVideoFile, rightVideoFile];
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

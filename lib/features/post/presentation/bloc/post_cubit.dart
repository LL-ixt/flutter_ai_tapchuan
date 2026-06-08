import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'post_state.dart';
import '../../../../services/api_service.dart';
import '../../data/models/add_post_models.dart';
import '../../../../core/constants/test_video_bytes.dart';
import '../../data/models/comment_models.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(const PostInitial());

  void updateText(String text) {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(text: text));
    }
  }

  Future<void> pickLeftVideo() async {
    if (state is PostInitial) {
      try {
        final result = await FilePicker.pickFiles(type: FileType.video);
        if (result != null && result.files.isNotEmpty) {
          emit(
            (state as PostInitial).copyWith(leftVideoFile: result.files.first),
          );
        }
      } catch (e) {
        emit(PostError('Lỗi chọn file: $e'));
      }
    }
  }

  void removeLeftVideo() {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(clearLeft: true));
    }
  }

  Future<void> pickRightVideo() async {
    if (state is PostInitial) {
      try {
        final result = await FilePicker.pickFiles(type: FileType.video);
        if (result != null && result.files.isNotEmpty) {
          emit(
            (state as PostInitial).copyWith(rightVideoFile: result.files.first),
          );
        }
      } catch (e) {
        emit(PostError('Lỗi chọn file: $e'));
      }
    }
  }

  void removeRightVideo() {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(clearRight: true));
    }
  }

  Future<void> submitPost({
    String? token,
    String? courseId,
    String? exerciseId,
    String? deviceSlave,
    String? deviceMaster,
  }) async {
    if (state is PostInitial) {
      final currentState = state as PostInitial;
      if (!currentState.canSubmit) return;

      emit(PostLoading());

      try {
        final leftBytes =
            currentState.leftVideoFile?.bytes ??
            currentState.rightVideoFile?.bytes;
        final leftName =
            currentState.leftVideoFile?.name ??
            currentState.rightVideoFile?.name;
        final rightBytes =
            currentState.rightVideoFile?.bytes ??
            currentState.leftVideoFile?.bytes;
        final rightName =
            currentState.rightVideoFile?.name ??
            currentState.leftVideoFile?.name;

        AddPostRequest request;
        if (kIsWeb) {
          request = AddPostRequest(
            token: token,
            leftVideoBytes: leftBytes,
            leftVideoName: leftName,
            rightVideoBytes: rightBytes,
            rightVideoName: rightName,
            courseId: courseId ?? '',
            exerciseId: exerciseId ?? '',
            described: currentState.text,
            deviceSlave: deviceSlave ?? 'device_slave_123',
            deviceMaster: deviceMaster ?? 'device_master_123',
          );
        } else {
          final leftPath =
              currentState.leftVideoFile?.path ??
              currentState.rightVideoFile?.path;
          final rightPath =
              currentState.rightVideoFile?.path ??
              currentState.leftVideoFile?.path;

          request = AddPostRequest(
            token: token,
            leftVideo: leftPath != null ? File(leftPath) : null,
            rightVideo: rightPath != null ? File(rightPath) : null,
            courseId: courseId ?? '',
            exerciseId: exerciseId ?? '',
            described: currentState.text,
            deviceSlave: deviceSlave ?? 'device_slave_123',
            deviceMaster: deviceMaster ?? 'device_master_123',
          );
        }

        final response = await ApiService.addPost(request);

        if (response.code == '1000') {
          if (exerciseId != null && exerciseId.isNotEmpty) {
            try {
              await ApiService.setComment(
                SetCommentRequest(
                  token: token,
                  id: exerciseId,
                  comment: 'Đã nộp bài tập bài viết này.',
                  index: '0',
                  count: '10',
                ),
              );
            } catch (e) {
              print("Error triggering submission notification comment: $e");
            }
          }

          final newPost = {
            "id":
                response.postId ??
                "post_new_${DateTime.now().millisecondsSinceEpoch}",
            "author": {
              "id": "user_current",
              "username": "Nguyễn Tiến Thành",
              "avatar": "https://i.pravatar.cc/150?img=60",
            },
            "described": currentState.text,
            "created_at": "Vừa xong",
            "like": "0",
            "comment": "0",
            "isLiked": false,
          };
          emit(PostSuccess(newPost));
        } else {
          emit(PostError(response.message));
        }
      } catch (e) {
        emit(PostError('Lỗi hệ thống: $e'));
      }
    }
  }
}

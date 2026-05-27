import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'post_state.dart';
import '../../../../services/api_service.dart';
import '../../data/models/add_post_models.dart';

class PostCubit extends Cubit<PostState> {
  PostCubit() : super(const PostInitial());

  void updateText(String text) {
    if (state is PostInitial) {
      emit((state as PostInitial).copyWith(text: text));
    }
  }

  void pickLeftVideo() {
    if (state is PostInitial) {
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
      emit((state as PostInitial).copyWith(rightVideoUrl: 'https://picsum.photos/300/400?2'));
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
        AddPostRequest request;
        if (kIsWeb) {
          request = AddPostRequest(
            token: token,
            leftVideoBytes: utf8.encode('dummy left video data'),
            leftVideoName: 'dummy_left.mp4',
            rightVideoBytes: utf8.encode('dummy right video data'),
            rightVideoName: 'dummy_right.mp4',
            courseId: courseId ?? 'course_123',
            exerciseId: exerciseId ?? 'exercise_123',
            described: currentState.text,
            deviceSlave: deviceSlave ?? 'device_slave_123',
            deviceMaster: deviceMaster ?? 'device_master_123',
          );
        } else {
          final tempDir = Directory.systemTemp;
          final leftFile = File('${tempDir.path}/dummy_left.mp4');
          if (!await leftFile.exists()) {
            await leftFile.writeAsString('dummy left video data');
          }
          final rightFile = File('${tempDir.path}/dummy_right.mp4');
          if (!await rightFile.exists()) {
            await rightFile.writeAsString('dummy right video data');
          }

          request = AddPostRequest(
            token: token,
            leftVideo: leftFile,
            rightVideo: rightFile,
            courseId: courseId ?? 'course_123',
            exerciseId: exerciseId ?? 'exercise_123',
            described: currentState.text,
            deviceSlave: deviceSlave ?? 'device_slave_123',
            deviceMaster: deviceMaster ?? 'device_master_123',
          );
        }

        final response = await ApiService.addPost(request);

        if (response.code == '1000') {
          final newPost = {
            "id": response.postId ?? "post_new_${DateTime.now().millisecondsSinceEpoch}",
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
        } else {
          emit(PostError(response.message));
        }
      } catch (e) {
        emit(PostError('Lỗi hệ thống: $e'));
      }
    }
  }
}

import 'dart:io';

class AddPostRequest {
  final String? token;
  final File? leftVideo;
  final File? rightVideo;
  final List<int>? leftVideoBytes;
  final List<int>? rightVideoBytes;
  final String? leftVideoName;
  final String? rightVideoName;
  final String courseId;
  final String exerciseId;
  final String described;
  final String deviceSlave;
  final String? deviceMaster;

  AddPostRequest({
    this.token,
    this.leftVideo,
    this.rightVideo,
    this.leftVideoBytes,
    this.rightVideoBytes,
    this.leftVideoName,
    this.rightVideoName,
    required this.courseId,
    required this.exerciseId,
    required this.described,
    required this.deviceSlave,
    this.deviceMaster,
  });

  Map<String, String> toFields() {
    return {
      'token': token ?? '',
      'course_id': courseId,
      'exercise_id': exerciseId,
      'described': described,
      'device_slave': deviceSlave,
      'device_master': deviceMaster ?? '',
    };
  }
}

class AddPostResponse {
  final String code;
  final String message;
  final String? postId;

  AddPostResponse({
    required this.code,
    required this.message,
    this.postId,
  });

  factory AddPostResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AddPostResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      postId: data != null ? data['id'] : null,
    );
  }
}

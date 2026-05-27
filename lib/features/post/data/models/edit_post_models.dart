import 'dart:io';

class EditPostRequest {
  final String? token;
  final String? id;
  final String described;
  final String? videoIndices;
  final File? leftVideo;
  final File? rightVideo;
  final List<int>? leftVideoBytes;
  final List<int>? rightVideoBytes;
  final String? leftVideoName;
  final String? rightVideoName;

  EditPostRequest({
    this.token,
    this.id,
    required this.described,
    this.videoIndices,
    this.leftVideo,
    this.rightVideo,
    this.leftVideoBytes,
    this.rightVideoBytes,
    this.leftVideoName,
    this.rightVideoName,
  });

  Map<String, String> toFields() {
    return {
      'token': token ?? '',
      if (id != null) 'id': id!,
      'described': described,
      if (videoIndices != null) 'video_indices': videoIndices!,
    };
  }
}

class EditPostResponse {
  final String code;
  final String message;
  final String? postId;

  EditPostResponse({
    required this.code,
    required this.message,
    this.postId,
  });

  factory EditPostResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return EditPostResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      postId: data != null ? data['id'] : null,
    );
  }
}

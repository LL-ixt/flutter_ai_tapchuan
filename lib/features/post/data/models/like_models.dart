class LikeRequest {
  final String? token;
  final String? id;

  LikeRequest({
    this.token,
    this.id,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token ?? '',
      'id': ?id,
    };
  }
}

class LikeResponse {
  final String code;
  final String message;
  final String? like;

  LikeResponse({
    required this.code,
    required this.message,
    this.like,
  });

  factory LikeResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return LikeResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      like: data != null ? data['like']?.toString() : null,
    );
  }
}

class GetPostRequest {
  final String? token;
  final String? id;
  final String? userId;

  GetPostRequest({
    this.token,
    this.id,
    this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token ?? '',
      'id': id ?? '',
      if (userId != null && userId!.isNotEmpty) 'user_id': userId!,
    };
  }
}

class GetPostResponse {
  final String code;
  final String message;
  final Map<String, dynamic>? data;

  GetPostResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory GetPostResponse.fromJson(Map<String, dynamic> json) {
    return GetPostResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }
}

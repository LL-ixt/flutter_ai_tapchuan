class DeletePostRequest {
  final String? token;
  final String? id;

  DeletePostRequest({
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

class DeletePostResponse {
  final String code;
  final String message;

  DeletePostResponse({
    required this.code,
    required this.message,
  });

  factory DeletePostResponse.fromJson(Map<String, dynamic> json) {
    return DeletePostResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

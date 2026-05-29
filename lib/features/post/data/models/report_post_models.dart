class ReportPostRequest {
  final String? token;
  final String? id;
  final String? subject;
  final String? details;

  ReportPostRequest({
    this.token,
    this.id,
    this.subject,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token ?? '',
      'id': ?id,
      'subject': ?subject,
      'details': ?details,
    };
  }
}

class ReportPostResponse {
  final String code;
  final String message;

  ReportPostResponse({
    required this.code,
    required this.message,
  });

  factory ReportPostResponse.fromJson(Map<String, dynamic> json) {
    return ReportPostResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

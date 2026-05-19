class BaseResponse<T> {
  final String code;
  final String message;
  final T? data;

  BaseResponse({required this.code, required this.message, this.data});

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return BaseResponse<T>(
      code: json['code']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: (json['data'] != null && fromJsonT != null)
          ? fromJsonT(json['data'])
          : null,
    );
  }
}

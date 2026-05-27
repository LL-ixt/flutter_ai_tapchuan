class GetListPostsRequest {
  final String? token;
  final String categoryId;
  final String lastId;
  final String? index;
  final String? count;
  final String userId;

  GetListPostsRequest({
    this.token,
    required this.categoryId,
    required this.lastId,
    this.index,
    this.count,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token ?? '',
      'category_id': categoryId,
      'last_id': lastId,
      if (index != null) 'index': index!,
      if (count != null) 'count': count!,
      'user_id': userId,
    };
  }
}

class GetListPostsResponse {
  final String code;
  final String message;
  final List<dynamic>? posts;
  final String? newItems;
  final String? lastId;

  GetListPostsResponse({
    required this.code,
    required this.message,
    this.posts,
    this.newItems,
    this.lastId,
  });

  factory GetListPostsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return GetListPostsResponse(
        code: json['code'] ?? '',
        message: json['message'] ?? '',
        posts: data['posts'] as List?,
        newItems: data['new_items']?.toString(),
        lastId: data['last_id']?.toString(),
      );
    }
    return GetListPostsResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

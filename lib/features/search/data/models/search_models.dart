class SearchRequest {
  final String token;
  final String keyword;
  final String userId;
  final int index;
  final int count;
  final String categoryId;
  final String durationMin;
  final String durationMax;

  SearchRequest({
    required this.token,
    required this.keyword,
    required this.userId,
    this.index = 0,
    this.count = 20,
    this.categoryId = '',
    this.durationMin = '',
    this.durationMax = '',
  });

  Map<String, String> toJson() => {
    'token': token,
    'keyword': keyword,
    'user_id': userId,
    'index': index.toString(),
    'count': count.toString(),
    'category_id': categoryId,
    'duration_min': durationMin,
    'duration_max': durationMax,
  };
}

class SearchResponse {
  final String code;
  final String message;
  final List<dynamic>? data;

  SearchResponse({
    required this.code,
    required this.message,
    this.data,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class SavedSearchRequest {
  final String token;
  final int index;
  final int count;
  final String userId;

  SavedSearchRequest({
    required this.token,
    this.index = 0,
    this.count = 20,
    this.userId = '',
  });

  Map<String, String> toJson() => {
    'token': token,
    'index': index.toString(),
    'count': count.toString(),
    'user_id': userId,
  };
}

class SavedSearchResponse {
  final String code;
  final String message;
  final List<SavedSearch>? searches;

  SavedSearchResponse({
    required this.code,
    required this.message,
    this.searches,
  });

  factory SavedSearchResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List?;
    List<SavedSearch>? searches;
    
    if (dataList != null) {
      searches = dataList
          .map((item) => SavedSearch.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return SavedSearchResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      searches: searches,
    );
  }
}

class SavedSearch {
  final String searchId;
  final String keyword;
  final String createdAt;

  SavedSearch({
    required this.searchId,
    required this.keyword,
    required this.createdAt,
  });

  factory SavedSearch.fromJson(Map<String, dynamic> json) {
    return SavedSearch(
      searchId: json['search_id'] ?? json['id'] ?? '',
      keyword: json['keyword'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class DeleteSavedSearchRequest {
  final String token;
  final String searchId;
  final String all;

  DeleteSavedSearchRequest({
    required this.token,
    this.searchId = '',
    this.all = '0',
  });

  Map<String, String> toJson() => {
    'token': token,
    'search_id': searchId,
    'all': all,
  };
}

class DeleteSavedSearchResponse {
  final String code;
  final String message;

  DeleteSavedSearchResponse({
    required this.code,
    required this.message,
  });

  factory DeleteSavedSearchResponse.fromJson(Map<String, dynamic> json) {
    return DeleteSavedSearchResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
    );
  }
}

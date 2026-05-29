class GetCommentRequest {
  final String? token;
  final String? id;
  final String? index;
  final String? count;
  final String userId;

  GetCommentRequest({
    this.token,
    this.id,
    this.index,
    this.count,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token ?? '',
      'id': ?id,
      'index': ?index,
      'count': ?count,
      'user_id': userId,
    };
  }
}

class CommentPoster {
  final String id;
  final String name;
  final String avatar;

  CommentPoster({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory CommentPoster.fromJson(Map<String, dynamic> json) {
    return CommentPoster(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}

class CommentItemModel {
  final String id;
  final String comment;
  final String created;
  final CommentPoster poster;

  CommentItemModel({
    required this.id,
    required this.comment,
    required this.created,
    required this.poster,
  });

  factory CommentItemModel.fromJson(Map<String, dynamic> json) {
    var posterData = json['poster'];
    CommentPoster poster;
    if (posterData is Map<String, dynamic>) {
      poster = CommentPoster.fromJson(posterData);
    } else {
      poster = CommentPoster(id: '', name: posterData?.toString() ?? '', avatar: '');
    }
    return CommentItemModel(
      id: json['id'] ?? '',
      comment: json['comment'] ?? '',
      created: json['created'] ?? '',
      poster: poster,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comment': comment,
      'created': created,
      'poster': poster.toJson(),
    };
  }
}

class GetCommentResponse {
  final String code;
  final String message;
  final List<CommentItemModel>? data;
  final String? isBlocked;

  GetCommentResponse({
    required this.code,
    required this.message,
    this.data,
    this.isBlocked,
  });

  factory GetCommentResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List? list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      list = rawData['data'] as List?;
    }
    
    List<CommentItemModel>? comments = list?.map((i) => CommentItemModel.fromJson(i)).toList();
    return GetCommentResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: comments,
      isBlocked: json['is_blocked']?.toString(),
    );
  }
}

class SetCommentRequest {
  final String? token;
  final String? id;
  final String? comment;
  final String? index;
  final String? count;
  final String? score;
  final String? detailMistakes;

  SetCommentRequest({
    this.token,
    this.id,
    this.comment,
    this.index,
    this.count,
    this.score,
    this.detailMistakes,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token ?? '',
      'id': ?id,
      'comment': ?comment,
      'index': ?index,
      'count': ?count,
      'score': ?score,
      'detail_mistakes': ?detailMistakes,
    };
  }
}

class SetCommentResponse {
  final String code;
  final String message;
  final List<CommentItemModel>? data;
  final String? isBlocked;

  SetCommentResponse({
    required this.code,
    required this.message,
    this.data,
    this.isBlocked,
  });

  factory SetCommentResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    List? list;
    if (rawData is List) {
      list = rawData;
    } else if (rawData is Map) {
      list = rawData['data'] as List?;
    }
    
    List<CommentItemModel>? comments = list?.map((i) => CommentItemModel.fromJson(i)).toList();
    return SetCommentResponse(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      data: comments,
      isBlocked: json['is_blocked']?.toString(),
    );
  }
}

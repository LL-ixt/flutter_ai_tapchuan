import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.authorAvatar,
    required super.described,
    required super.createdAt,
    required super.likeCount,
    required super.commentCount,
    required super.isLiked,
  });

  // Map từ Product của Backend sang PostModel của App
  factory PostModel.fromJson(Map<String, dynamic> json) {
    final seller = json['seller'] ?? {};
    return PostModel(
      id: json['id']?.toString() ?? '',
      authorId: seller['id']?.toString() ?? '',
      authorName: seller['username']?.toString() ?? 'Người dùng',
      authorAvatar: seller['avatar']?.toString() ?? 'https://i.pravatar.cc/150?img=11',
      described: json['described']?.toString() ?? '',
      createdAt: json['created']?.toString() ?? 'Vừa xong',
      likeCount: json['like']?.toString() ?? '0',
      commentCount: json['comment']?.toString() ?? '0',
      isLiked: json['is_liked'] == '1' || json['is_liked'] == true,
    );
  }

  // Chuyển sang Map để dùng tương thích ngược với FeedCubit cũ
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "author": {
        "id": authorId,
        "username": authorName,
        "avatar": authorAvatar,
      },
      "described": described,
      "created_at": createdAt,
      "like": likeCount,
      "comment": commentCount,
      "isLiked": isLiked,
    };
  }
}

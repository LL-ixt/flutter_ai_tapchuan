class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String described;
  final String createdAt;
  final String likeCount;
  final String commentCount;
  final bool isLiked;

  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.described,
    required this.createdAt,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
  });
}

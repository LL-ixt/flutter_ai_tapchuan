import '../../domain/entities/post.dart';

abstract class FeedRepository {
  Future<List<Post>> getListPosts();
}

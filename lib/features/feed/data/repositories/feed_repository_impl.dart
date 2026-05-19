import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';
import '../models/post_model.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remoteDataSource;
  final Box _feedBox = Hive.box('feedBox'); // Box lưu cache

  FeedRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Post>> getListPosts() async {
    try {
      // 1. Cố gắng lấy data từ Server
      final remotePosts = await _remoteDataSource.getListProducts();

      // 2. Cache lại vào Hive để dùng offline
      final List<Map<String, dynamic>> cacheData = remotePosts.map((e) => e.toJson()).toList();
      await _feedBox.put('cached_posts', cacheData);

      return remotePosts;
    } catch (e) {
      // 3. Nếu mất mạng hoặc server lỗi, lấy từ Cache
      final cachedData = _feedBox.get('cached_posts');
      if (cachedData != null) {
        final List<dynamic> listData = cachedData as List<dynamic>;
        final List<PostModel> cachedPosts = listData
            .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        return cachedPosts;
      }
      
      // Nếu không có cache mà vẫn lỗi thì ném lỗi
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('Lỗi hệ thống: $e');
    }
  }
}

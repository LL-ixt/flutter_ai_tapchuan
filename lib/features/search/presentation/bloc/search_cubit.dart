import 'package:flutter_ai_tapchuan/features/feed/data/models/get_list_posts_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'package:flutter_ai_tapchuan/features/search/data/models/search_models.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
  Future<void> search({
    required String token,
    required String keyword,
    required String userId,
    int index = 0,
    int count = 20,
    String categoryId = '',
    String durationMin = '',
    String durationMax = '',
  }) async {
    emit(SearchLoading());

    try {
      final response = await ApiService.search(
        token,
        keyword,
        userId,
        index,
        count,
        categoryId: categoryId,
        durationMin: durationMin,
        durationMax: durationMax,
      );

      final List<dynamic> serverUsers = [];
      final List<dynamic> serverPosts = [];

      if (response['code'] == '1000') {
        final resData = response['data'] as Map<String, dynamic>? ?? {};
        serverUsers.addAll(resData['users'] as List? ?? []);
        serverPosts.addAll(resData['posts'] as List? ?? []);
      }

      final Set<String> uniquePostIds = {};
      final List<dynamic> mergedPosts = [];

      for (var post in serverPosts) {
        if (post is Map) {
          final id =
              post['id']?.toString() ?? post['post_id']?.toString() ?? '';
          if (id.isNotEmpty && !uniquePostIds.contains(id)) {
            uniquePostIds.add(id);
            mergedPosts.add(post);
          }
        }
      }

      try {
        final postsResponse = await ApiService.getListPosts(
          GetListPostsRequest(token: token, index: '0', count: '100'),
        );
        if (postsResponse.code == '1000' && postsResponse.posts != null) {
          final allPosts = postsResponse.posts!;

          for (var post in allPosts) {
            if (post is Map) {
              final id =
                  post['id']?.toString() ?? post['post_id']?.toString() ?? '';
              if (id.isNotEmpty && !uniquePostIds.contains(id)) {
                uniquePostIds.add(id);
                mergedPosts.add(post);
              }
            }
          }

          final Set<String> uniqueUserIds = serverUsers.map((u) {
            if (u is Map) {
              return u['id']?.toString() ?? u['user_id']?.toString() ?? '';
            }
            return '';
          }).toSet();

          for (var post in allPosts) {
            if (post is Map && post['author'] is Map) {
              final author = post['author'] as Map;
              final authorId =
                  author['id']?.toString() ??
                  author['user_id']?.toString() ??
                  '';
              if (authorId.isNotEmpty && !uniqueUserIds.contains(authorId)) {
                uniqueUserIds.add(authorId);
                serverUsers.add({
                  'id': authorId,
                  'username': author['username'] ?? author['name'] ?? '',
                  'name': author['name'] ?? author['username'] ?? '',
                  'avatar': author['avatar'] ?? '',
                  'role': author['role'] ?? '',
                });
              }
            }
          }
        }
      } catch (e) {
        print("Search merging fallback error: $e");
      }

      final Map<String, dynamic> mergedData = {
        'users': serverUsers,
        'posts': mergedPosts,
      };

      emit(SearchLoaded(mergedData));
    } catch (e) {
      emit(SearchError('Lỗi hệ thống: $e'));
    }
  }

  Future<void> getSavedSearches({
    required String token,
    int index = 0,
    int count = 20,
    String userId = '',
  }) async {
    emit(SavedSearchLoading());

    try {
      final response = await ApiService.getSavedSearch(
        token,
        index,
        count,
        userId: userId,
      );

      if (response['code'] == '1000') {
        final dataList = response['data'] as List? ?? [];
        final searches = dataList
            .map(
              (item) => {
                'search_id': item['search_id'] ?? item['id'] ?? '',
                'keyword': item['keyword'] ?? '',
                'created_at': item['created_at'] ?? '',
              },
            )
            .toList();
        emit(SavedSearchLoaded(searches.cast<Map<String, dynamic>>()));
      } else {
        emit(
          SavedSearchError(response['message'] ?? 'Lỗi lấy danh sách tìm kiếm'),
        );
      }
    } catch (e) {
      emit(SavedSearchError('Lỗi hệ thống: $e'));
    }
  }

  Future<void> deleteSearch({
    required String token,
    String searchId = '',
    String all = '0',
  }) async {
    try {
      final response = await ApiService.delSavedSearch(token, searchId, all);

      if (response['code'] == '1000') {
        emit(DeleteSearchSuccess());
        // Sau khi xóa, tải lại danh sách
        await getSavedSearches(token: token);
      } else {
        emit(DeleteSearchError(response['message'] ?? 'Lỗi xóa tìm kiếm'));
      }
    } catch (e) {
      emit(DeleteSearchError('Lỗi hệ thống: $e'));
    }
  }

  Future<void> deleteAllSearches({required String token}) async {
    await deleteSearch(token: token, all: '1');
  }
}

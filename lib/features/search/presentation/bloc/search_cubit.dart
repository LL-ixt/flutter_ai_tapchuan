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

      if (response['code'] == '1000') {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        emit(SearchLoaded(data));
      } else {
        emit(SearchError(response['message'] ?? 'Lỗi tìm kiếm'));
      }
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
            .map((item) => {
              'search_id': item['search_id'] ?? item['id'] ?? '',
              'keyword': item['keyword'] ?? '',
              'created_at': item['created_at'] ?? '',
            })
            .toList();
        emit(SavedSearchLoaded(searches.cast<Map<String, dynamic>>()));
      } else {
        emit(SavedSearchError(response['message'] ?? 'Lỗi lấy danh sách tìm kiếm'));
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

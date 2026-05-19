import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/local_storage/hive_service.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(const SearchInitial([])) {
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    final box = Hive.box(HiveService.searchHistoryBox);
    final searches = box.get('recent_searches', defaultValue: <String>[]);
    emit(SearchInitial(List<String>.from(searches)));
  }

  void addSearchKeyword(String keyword) async {
    final trimKeyword = keyword.trim();
    if (trimKeyword.isEmpty) return;

    final box = Hive.box(HiveService.searchHistoryBox);
    List<String> currentSearches = List<String>.from(box.get('recent_searches', defaultValue: <String>[]));

    // Remove if exists to push to top
    currentSearches.remove(trimKeyword);
    currentSearches.insert(0, trimKeyword);

    // Limit to 20 keywords
    if (currentSearches.length > 20) {
      currentSearches = currentSearches.sublist(0, 20);
    }

    await box.put('recent_searches', currentSearches);
  }

  void deleteSearchKeyword(String keyword) async {
    final box = Hive.box(HiveService.searchHistoryBox);
    List<String> currentSearches = List<String>.from(box.get('recent_searches', defaultValue: <String>[]));
    
    currentSearches.remove(keyword);
    await box.put('recent_searches', currentSearches);
    
    if (state is SearchInitial) {
      emit(SearchInitial(currentSearches));
    }
  }

  void clearAllSearches() async {
    final box = Hive.box(HiveService.searchHistoryBox);
    await box.put('recent_searches', <String>[]);
    
    if (state is SearchInitial) {
      emit(const SearchInitial([]));
    }
  }

  void performSearch(String keyword) async {
    addSearchKeyword(keyword);
    emit(SearchLoading());

    // Giả lập loading 1s
    await Future.delayed(const Duration(seconds: 1));

    // Giả lập dữ liệu kết quả tìm kiếm (dùng chung cấu trúc API_Contract)
    final List<Map<String, dynamic>> mockResults = List.generate(3, (index) {
      return {
        "id": "search_result_$index",
        "author": {
          "id": "search_user_$index",
          "username": "Người dùng $index (Tìm kiếm)",
          "avatar": "https://i.pravatar.cc/150?u=search_user_$index"
        },
        "described": "Đây là kết quả tìm kiếm cho từ khóa '$keyword'. Kết quả số ${index + 1}.",
        "created_at": "Vừa xong",
        "like": "${(index + 1) * 5}",
        "comment": "${(index + 1) * 2}",
        "isLiked": false,
      };
    });

    emit(SearchSuccess(mockResults));
  }

  void resetToInitial() {
    _loadRecentSearches();
  }
}

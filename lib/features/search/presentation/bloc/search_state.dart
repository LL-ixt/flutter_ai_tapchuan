abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<dynamic> results;

  SearchLoaded(this.results);
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}

// States cho danh sách tìm kiếm gần đây
class SavedSearchLoading extends SearchState {}

class SavedSearchLoaded extends SearchState {
  final List<Map<String, dynamic>> searches;

  SavedSearchLoaded(this.searches);
}

class SavedSearchError extends SearchState {
  final String message;

  SavedSearchError(this.message);
}

// State cho xóa tìm kiếm
class DeleteSearchSuccess extends SearchState {}

class DeleteSearchError extends SearchState {
  final String message;

  DeleteSearchError(this.message);
}

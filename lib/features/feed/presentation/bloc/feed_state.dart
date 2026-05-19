abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Map<String, dynamic>> posts;
  final bool isOffline;
  final String? errorMessage;
  FeedLoaded(this.posts, {this.isOffline = false, this.errorMessage});
}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}

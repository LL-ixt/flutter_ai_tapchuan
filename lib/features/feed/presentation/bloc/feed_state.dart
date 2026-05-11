abstract class FeedState {}

class FeedInitial extends FeedState {}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  final List<Map<String, dynamic>> posts;
  FeedLoaded(this.posts);
}

class FeedError extends FeedState {
  final String message;
  FeedError(this.message);
}

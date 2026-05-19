import 'package:equatable/equatable.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<String> recentSearches;

  const SearchInitial(this.recentSearches);

  @override
  List<Object?> get props => [recentSearches];
}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Map<String, dynamic>> results;

  const SearchSuccess(this.results);

  @override
  List<Object?> get props => [results];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

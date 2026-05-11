import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const AuthState._({this.isLoading = false, this.isSuccess = false, this.error});

  const AuthState.initial() : this._();
  const AuthState.loading() : this._(isLoading: true);
  const AuthState.success() : this._(isSuccess: true);
  const AuthState.failure(String error) : this._(error: error);

  @override
  List<Object?> get props => [isLoading, isSuccess, error];
}

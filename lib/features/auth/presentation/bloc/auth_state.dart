import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String username;
  final String role;
  final String? token;
  final String? userId;
  
  const AuthState._({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.username = '',
    this.role = '',
    this.token,
    this.userId,
  });

  const AuthState.initial() : this._();
  const AuthState.loading() : this._(isLoading: true);
  const AuthState.success({
    required String username,
    required String role,
    String? token,
    String? userId,
  }) : this._(
          isSuccess: true,
          username: username,
          role: role,
          token: token,
          userId: userId,
        );
      
  const AuthState.failure(String error) : this._(error: error);

  @override
  List<Object?> get props => [isLoading, isSuccess, error, username, role, token, userId];
}

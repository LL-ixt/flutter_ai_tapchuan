import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String username;
  final String role;
  final String? token;
  final String? userId;
  final String avatar;
  
  const AuthState._({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.username = '',
    this.role = '',
    this.token,
    this.userId,
    this.avatar = '',
  });

  const AuthState.initial() : this._();
  const AuthState.loading() : this._(isLoading: true);
  const AuthState.success({
    required String username,
    required String role,
    String? token,
    String? userId,
    String avatar = '',
  }) : this._(
          isSuccess: true,
          username: username,
          role: role,
          token: token,
          userId: userId,
          avatar: avatar,
        );
      
  const AuthState.failure(String error) : this._(error: error);

  AuthState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? username,
    String? role,
    String? token,
    String? userId,
    String? avatar,
  }) {
    return AuthState._(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      username: username ?? this.username,
      role: role ?? this.role,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, error, username, role, token, userId, avatar];
}

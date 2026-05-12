part of 'profile_cubit.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity userProfile;
  final List<Map<String, dynamic>> userPosts;

  ProfileLoaded({
    required this.userProfile,
    required this.userPosts,
  });
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}

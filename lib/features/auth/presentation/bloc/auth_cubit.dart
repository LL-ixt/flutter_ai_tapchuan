import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/error/exceptions.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(const AuthState.initial());

  void login({required String phone, required String password}) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.login(phone, password, 'mock_device_uuid');
      emit(const AuthState.success());
    } on ServerException catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(AuthState.failure('Lỗi hệ thống: $e'));
    }
  }

  void signup({required String phone, required String password, required String role}) async {
    emit(const AuthState.loading());
    try {
      await _authRepository.signup(phone, password, 'mock_device_uuid');
      emit(const AuthState.success());
    } on ServerException catch (e) {
      emit(AuthState.failure(e.message));
    } catch (e) {
      emit(AuthState.failure('Lỗi hệ thống: $e'));
    }
  }

  void logout() {
    emit(const AuthState.initial());
  }
}

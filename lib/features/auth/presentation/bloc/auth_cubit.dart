import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  void login({required String phone, required String password}) async {
    emit(const AuthState.loading());
    // Thực hiện gọi API đăng nhập ở đây
    await Future.delayed(const Duration(seconds: 2));
    // Giả lập thành công
    emit(const AuthState.success());
    // Nếu thất bại: emit(AuthState.failure('Lỗi đăng nhập'));
  }

  void logout() {
    emit(const AuthState.initial());
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_state.dart';
import '../../../../services/api_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  void login({required String phone, required String password}) async {
    emit(const AuthState.loading());
    
    try {
      // 1. Gọi API ở trong Cubit đúng như kiến trúc chuẩn
      final result = await ApiService.login(phone, password);
      
      if (result['code'] == '1000') {
        // Lấy thông tin user trả về từ Object 'data' của Server nhóm bạn
        final userData = result['data'];
        String fetchedName = userData['username'] ?? "Không tên";
        String fetchedRole = userData['role'] ?? "HS";
        String fetchedToken = userData['token'];
        String fetchedId = userData['id']?.toString() ?? userData['userId']?.toString() ?? 'user_current';
        // 2. Bắn trạng thái thành công kèm theo data thật
        emit(AuthState.success(
          username: fetchedName,
          role: fetchedRole,
          token: fetchedToken,
          userId: fetchedId,
        ));
      } else {
        // Thất bại do sai mật khẩu, tài khoản chưa verify...
        emit(AuthState.failure(result['message'] ?? 'Đăng nhập thất bại'));
      }
    } catch (e) {
      emit(AuthState.failure('Lỗi kết nối hệ thống: $e'));
    }
  }

  void logout() async {
    // 1. Lấy token đang được lưu trong State hiện tại của Cubit
    final currentToken = state.token;
    print("=== AuthCubit.logout called with token: $currentToken ==="); // Debug log
    emit(const AuthState.loading()); // Hiện vòng xoay loading ở MenuScreen nếu muốn

    try {
      if (currentToken != null && currentToken.isNotEmpty) {
        // 2. Gọi API Logout lên server truyền kèm token để server hủy phiên (đúng chuẩn bảo mật slide tuần 2)
        await ApiService.logout(currentToken); 
      }
    } catch (e) {
      // Cho dù API logout lỗi (mất mạng) thì vẫn nên cho xóa ở client để người dùng thoát ra ngoài
      print("Lỗi khi gọi API logout trên server: $e");
    }

    // 3. Xóa token offline tại đây (Ví dụ: SharedPreferences.clear() nếu có lưu)
    // await SharedPreferences.getInstance().then((prefs) => prefs.clear());

    // 4. Phát ra trạng thái ban đầu (Xóa sạch mọi dữ liệu user, token về null)
    emit(const AuthState.initial());
  }
}
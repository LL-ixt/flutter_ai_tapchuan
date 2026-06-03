import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';
import '../../../../services/api_service.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState.initial());

  // Keys for SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'auth_username';
  static const String _roleKey = 'auth_role';
  static const String _userIdKey = 'auth_userId';

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
        await ApiService.setDevtoken(fetchedToken, 0, 'mock_device');
        String fetchedId = userData['id']?.toString() ?? userData['userId']?.toString() ?? 'user_current';
        
        // Lưu thông tin đăng nhập vào SharedPreferences
        await _saveCredentials(fetchedToken, fetchedName, fetchedRole, fetchedId);
        
        // 2. Bắn trạng thái thành công kèm theo data thật
        emit(
          AuthState.success(
          
            username: fetchedName,
         
            role: fetchedRole,
         
            token: fetchedToken,
            userId: fetchedId
          ),
        );
      } else {
        // Thất bại do sai mật khẩu, tài khoản chưa verify...
        emit(AuthState.failure(result['message'] ?? 'Đăng nhập thất bại'));
      }
    } catch (e) {
      emit(AuthState.failure('Lỗi kết nối hệ thống: $e'));
    }
  }

  // Lưu thông tin người dùng vào SharedPreferences
  Future<void> _saveCredentials(String token, String username, String role, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_usernameKey, username);
      await prefs.setString(_roleKey, role);
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      print('Lỗi khi lưu thông tin đăng nhập: $e');
    }
  }

  // Phục hồi phiên đăng nhập từ SharedPreferences
  Future<bool> restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final username = prefs.getString(_usernameKey);
      final role = prefs.getString(_roleKey);
      final userId = prefs.getString(_userIdKey);

      if (token != null && token.isNotEmpty) {
        // Phiên đăng nhập hợp lệ, phục hồi trạng thái
        emit(
          AuthState.success(
            username: username ?? 'Không tên',
            role: role ?? 'HS',
            token: token,
            userId: userId,
          ),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Lỗi khi phục hồi phiên đăng nhập: $e');
      return false;
    }
  }

  void logout() async {
    // 1. Lấy token đang được lưu trong State hiện tại của Cubit
    final currentToken = state.token;
    emit(
      const AuthState.loading(),
    ); // Hiện vòng xoay loading ở MenuScreen nếu muốn

    try {
      if (currentToken != null && currentToken.isNotEmpty) {
        // 2. Gọi API Logout lên server truyền kèm token để server hủy phiên (đúng chuẩn bảo mật slide tuần 2)
        await ApiService.logout(currentToken);
      }
    } catch (e) {
      // Cho dù API logout lỗi (mất mạng) thì vẫn nên cho xóa ở client để người dùng thoát ra ngoài
    }

    // 3. Xóa thông tin đăng nhập khỏi SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_roleKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      print('Lỗi khi xóa thông tin đăng nhập: $e');
    }

    // 4. Phát ra trạng thái ban đầu (Xóa sạch mọi dữ liệu user, token về null)
    emit(const AuthState.initial());
  }
}

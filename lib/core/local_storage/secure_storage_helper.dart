import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class SecureStorageHelper {
  // Khởi tạo instance của FlutterSecureStorage
  static const _storage = FlutterSecureStorage();
  
  // Khai báo các khóa (keys) lưu trữ
  static const String _keyToken = 'auth_token';
  static const String _keyDeviceId = 'device_id';

  // ==========================================
  // XỬ LÝ TOKEN
  // ==========================================
  
  /// Lưu Token sau khi đăng nhập thành công
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Lấy Token hiện tại (trả về null nếu chưa đăng nhập hoặc token đã xóa)
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Xóa Token (dùng khi đăng xuất)
  static Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  // ==========================================
  // XỬ LÝ DEVICE ID (UUID)
  // ==========================================
  
  /// Lưu Device ID thủ công nếu cần
  static Future<void> saveDeviceId(String deviceId) async {
    await _storage.write(key: _keyDeviceId, value: deviceId);
  }

  /// Lấy Device ID. Nếu chưa có, tự động tạo mới một UUID v4, lưu lại rồi trả về.
  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: _keyDeviceId);
    
    // Nếu chưa tồn tại hoặc chuỗi rỗng thì sinh mã UUID mới
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4(); // Tạo mã UUID chuẩn
      await saveDeviceId(deviceId); // Lưu lại cho các lần gọi sau
    }
    
    return deviceId;
  }
}

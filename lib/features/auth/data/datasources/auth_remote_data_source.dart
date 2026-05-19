import 'package:dio/dio.dart';
import '../../../../core/network/base_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/local_storage/secure_storage_helper.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> signup(
    String phonenumber,
    String password,
    String uuid,
  );
  Future<Map<String, dynamic>> login(
    String phonenumber,
    String password,
    String uuid,
  );
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> signup(
    String phonenumber,
    String password,
    String uuid,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        'signup', // DioClient đã cấu hình sẵn BaseUrl http://[YOUR_SERVER_IP]/api/
        data: {'phonenumber': phonenumber, 'password': password, 'uuid': uuid},
      );

      final baseResponse = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (baseResponse.code == '1000') {
        if (baseResponse.data != null && baseResponse.data!['token'] != null) {
          final token = baseResponse.data!['token'] as String;
          // Lưu token vào Secure Storage ngay khi signup/login thành công
          await SecureStorageHelper.saveToken(token);
        }
        return baseResponse.data ?? {};
      } else {
        // Ném lỗi với message từ Backend để UI hiển thị (ví dụ: Số điện thoại đã tồn tại)
        throw Exception(baseResponse.message);
      }
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> login(
    String phonenumber,
    String password,
    String uuid,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        'login',
        data: {'phonenumber': phonenumber, 'password': password, 'uuid': uuid},
      );

      final baseResponse = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (data) => data as Map<String, dynamic>,
      );

      if (baseResponse.code == '1000') {
        if (baseResponse.data != null && baseResponse.data!['token'] != null) {
          final token = baseResponse.data!['token'] as String;
          // Lưu token vào Secure Storage
          await SecureStorageHelper.saveToken(token);
        }
        return baseResponse.data ?? {};
      } else {
        // Ném lỗi như Sai mật khẩu, Tài khoản không tồn tại...
        throw Exception(baseResponse.message);
      }
    } on DioException catch (e) {
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    }
  }
}

import 'package:dio/dio.dart';
import '../../../../core/network/base_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/local_storage/secure_storage_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signup(String phonenumber, String password, String uuid);
  Future<UserModel> login(String phonenumber, String password, String uuid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserModel> signup(
    String phonenumber,
    String password,
    String uuid,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        'signup', // DioClient đã cấu hình sẵn BaseUrl
        data: {'phonenumber': phonenumber, 'password': password, 'uuid': uuid},
      );

      final baseResponse = BaseResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (baseResponse.code == '1000') {
        if (baseResponse.data != null) {
          final token = baseResponse.data!.token;
          if (token.isNotEmpty) {
            await SecureStorageHelper.saveToken(token);
          }
          return baseResponse.data!;
        }
        throw ServerException('Dữ liệu trả về bị trống');
      } else {
        throw ServerException(baseResponse.message);
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối mạng: ${e.message}');
    }
  }

  @override
  Future<UserModel> login(
    String phonenumber,
    String password,
    String uuid,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        'login',
        data: {'phonenumber': phonenumber, 'password': password, 'uuid': uuid},
      );

      final baseResponse = BaseResponse<UserModel>.fromJson(
        response.data,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (baseResponse.code == '1000') {
        if (baseResponse.data != null) {
          final token = baseResponse.data!.token;
          if (token.isNotEmpty) {
            await SecureStorageHelper.saveToken(token);
          }
          return baseResponse.data!;
        }
        throw ServerException('Dữ liệu trả về bị trống');
      } else {
        throw ServerException(baseResponse.message);
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối mạng: ${e.message}');
    }
  }
}

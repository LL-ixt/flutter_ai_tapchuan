import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<User> login(String phonenumber, String password, String uuid) async {
    // Gọi remote data source, sẽ ném ra ServerException nếu có lỗi
    return await _remoteDataSource.login(phonenumber, password, uuid);
  }

  @override
  Future<User> signup(String phonenumber, String password, String uuid) async {
    return await _remoteDataSource.signup(phonenumber, password, uuid);
  }
}

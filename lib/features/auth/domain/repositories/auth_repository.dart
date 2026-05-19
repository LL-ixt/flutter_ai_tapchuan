import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String phonenumber, String password, String uuid);
  Future<User> signup(String phonenumber, String password, String uuid);
}

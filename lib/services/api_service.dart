import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
class ApiService {
  static const String baseUrl = "https://group1.it4788.sukkaito.id.vn/it4788";
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final url = Uri.parse('$baseUrl/login');
    //print("=== APIService.login called with phone: $phone ==="); // Debug log
    try {
      final response = await http.post(
        url,
        body: {
          'phonenumber': phone,
          'password': password,
          'devtoken': 'mock_device', 
          //'uuid': 'mock_device',//await DeviceUtils.getHashedDeviceID(),
        },
      );
      print("status code login: ${response.statusCode}"); // Debug log
      print("=== API Login Response: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Trả về thông báo lỗi kết nối
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } 
    catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> signup(String phone, String password, String role) async {
    //print("=== APIService.signup called with phone: $phone, role: $role ==="); // Debug log
    final url = Uri.parse('$baseUrl/signup');
    try {
      final response = await http.post(
        url,
        body: {
          'phonenumber': phone,
          'password': password,
          'uuid': 'mock_device', //await DeviceUtils.getHashedDeviceID(),
          'role': role
        },
      );
      print("status code signup: ${response.statusCode}"); // Debug log
      print("=== API Signup Response: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } 
    catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token
        }
      );
      print("status code logout: ${response.statusCode}"); // Debug log
      print("=== API Logout Response: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    }
    catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkVerifyCode(String phone, String code) async {
    final url = Uri.parse('$baseUrl/check_verify_code');
    try {
      final response = await http.post(
        url,
        body: {
          'phonenumber': phone,
          'codeVerify': code
        },
      );
      print("status code checkVerifyCode: ${response.statusCode}"); // Debug log
      print("=== API Check Verify Code Response: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> changeInfoAfterSignup(String token, String name, {File? avatar, required String height}) async {
    final url = Uri.parse('$baseUrl/change_info_after_signup');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'username': name,
          'height': height
        },
      );
      print("status code changeInfoAfterSignup: ${response.statusCode}"); // Debug log
      print("=== API Change Info After Signup Response: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }
}
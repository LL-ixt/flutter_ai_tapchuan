import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_ai_tapchuan/core/utils/device_utils.dart';
class ApiService {
  static const String baseUrl = "http://group1.it4788.sukkaito.id.vn/it4788";
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    final url = Uri.parse('$baseUrl/login');

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
      //print("status code login: ${response.statusCode}"); // Debug log
      //print("=== API Login Response: ${response.body}"); // Debug log
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
    print("=== APIService.signup called with phone: $phone, role: $role ==="); // Debug log
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
      //print("status code signup: ${response.statusCode}"); // Debug log
      //print("=== API Signup Response: ${response.body}"); // Debug log
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
}
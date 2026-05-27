import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_ai_tapchuan/core/utils/device_utils.dart';
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
  // =========================================================
  // PHẦN CỦA QUÂN: 8 API (Search, Students, Courses, Blocks...)
  // =========================================================

  // 1. API: TÌM KIẾM (search) 
  static Future<Map<String, dynamic>> search(
    String token, 
    String keyword, 
    String userId, 
    int index, 
    int count,
    {String categoryId = "", String durationMin = "", String durationMax = ""}
  ) async {
    final url = Uri.parse('$baseUrl/search');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'keyword': keyword.trim(), 
          'user_id': userId,
          'index': index.toString(),
          'count': count.toString(),
          'category_id': categoryId,
          'duration_min': durationMin,
          'duration_max': durationMax,
        },
      );
      print("status code search: ${response.statusCode}");
      print("=== API Search Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 2. API: LẤY LỊCH SỬ TÌM KIẾM (get_saved_search) 
  static Future<Map<String, dynamic>> getSavedSearch(
    String token, 
    int index, 
    int count, 
    {String userId = ""} 
  ) async {
    final url = Uri.parse('$baseUrl/get_saved_search');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'index': index.toString(),
          'count': count.toString(),
          'user_id': userId,
        },
      );
      print("status code getSavedSearch: ${response.statusCode}");
      print("=== API Get Saved Search Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 3. API: XÓA LỊCH SỬ TÌM KIẾM (del_saved_search)
  static Future<Map<String, dynamic>> delSavedSearch(
    String token, 
    String searchId, 
    String all
  ) async {
    final url = Uri.parse('$baseUrl/del_saved_search');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'search_id': searchId, 
          'all': all,
        },
      );
      print("status code delSavedSearch: ${response.statusCode}");
      print("=== API Del Saved Search Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }
// 4. API: LẤY DANH SÁCH TOÀN BỘ HỌC VIÊN (get_list_students)
  static Future<Map<String, dynamic>> getListStudents(
    String token, 
    int index, 
    int count,
    {String userId = ""} 
  ) async {
    final url = Uri.parse('$baseUrl/get_list_students');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'index': index.toString(),
          'count': count.toString(),
          'user_id': userId, 
        },
      );
      print("status code getListStudents: ${response.statusCode}");
      print("=== API Get List Students Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }
  // 5. API: LẤY THÔNG TIN NGƯỜI DÙNG (get_user_info) 
  static Future<Map<String, dynamic>> getUserInfo(
    String token, 
    {String userId = ""}
  ) async {
    final url = Uri.parse('$baseUrl/get_user_info');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'user_id': userId, 
        },
      );
      print("status code getUserInfo: ${response.statusCode}");
      print("=== API Get User Info Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 6. API: CẬP NHẬT THÔNG TIN NGƯỜI DÙNG (set_user_info) 
  static Future<Map<String, dynamic>> setUserInfo(
    String token, 
    {String username = "", File? avatar, File? coverImage} 
  ) async {
    final url = Uri.parse('$baseUrl/set_user_info');
    try {
      var request = http.MultipartRequest('POST', url);
      
      request.fields['token'] = token;
      
      if (username.isNotEmpty) {
        request.fields['username'] = username.trim(); 
      }

      if (avatar != null) {
        request.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
      }

      if (coverImage != null) {
        request.files.add(await http.MultipartFile.fromPath('cover_image', coverImage.path));
      }

      var streamedResponse = await request.send();
      
      var response = await http.Response.fromStream(streamedResponse);
      
      print("status code setUserInfo: ${response.statusCode}");
      print("=== API Set User Info Response: ${response.body}");
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }
  // 7. API: LẤY DANH SÁCH KHÓA HỌC CỦA HỌC VIÊN (get_list_courses_of_student) 
  static Future<Map<String, dynamic>> getListCoursesOfStudent(
    String token, 
    String userId, 
    int index, 
    int count
  ) async {
    final url = Uri.parse('$baseUrl/get_list_courses_of_student');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'user_id': userId, 
          'index': index.toString(),
          'count': count.toString(),
        },
      );
      print("status code getListCourses: ${response.statusCode}");
      print("=== API Get List Courses Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }
  // 8. API: LẤY DANH SÁCH BỊ CHẶN (get_list_blocks)
  static Future<Map<String, dynamic>> getListBlocks(
    String token, 
    int index, 
    int count,
    {String userId = ""} 
  ) async {
    final url = Uri.parse('$baseUrl/get_list_blocks');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'index': index.toString(),
          'count': count.toString(),
          'user_id': userId,
        },
      );
      print("status code getListBlocks: ${response.statusCode}");
      print("=== API Get List Blocks Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }
}
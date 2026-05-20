import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://group1.it4788.sukkaito.id.vn/it4788";

  // Biến lưu trữ token toàn cục tạm thời (sẽ cần thay bằng SharedPreferences sau)
  static String? currentToken;

  static Future<Map<String, dynamic>> login(
    String phone,
    String password,
  ) async {
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
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> signup(
    String phone,
    String password,
    String role,
  ) async {
    //print("=== APIService.signup called with phone: $phone, role: $role ==="); // Debug log
    final url = Uri.parse('$baseUrl/signup');
    try {
      final response = await http.post(
        url,
        body: {
          'phonenumber': phone,
          'password': password,
          'uuid': 'mock_device', //await DeviceUtils.getHashedDeviceID(),
          'role': role,
        },
      );
      print("status code signup: ${response.statusCode}"); // Debug log
      print("=== API Signup Response: ${response.body}"); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout(String token) async {
    final url = Uri.parse('$baseUrl/logout');
    try {
      final response = await http.post(url, body: {'token': token});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkVerifyCode(
    String phone,
    String code,
  ) async {
    final url = Uri.parse('$baseUrl/check_verify_code');
    try {
      final response = await http.post(
        url,
        body: {'phonenumber': phone, 'codeVerify': code},
      );
      print("status code checkVerifyCode: ${response.statusCode}"); // Debug log
      print(
        "=== API Check Verify Code Response: ${response.body}",
      ); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> changeInfoAfterSignup(
    String token,
    String name, {
    File? avatar,
    required String height,
  }) async {
    final url = Uri.parse('$baseUrl/change_info_after_signup');
    try {
      final response = await http.post(
        url,
        body: {'token': token, 'username': name, 'height': height},
      );
      print(
        "status code changeInfoAfterSignup: ${response.statusCode}",
      ); // Debug log
      print(
        "=== API Change Info After Signup Response: ${response.body}",
      ); // Debug log
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPost(
    String token,
    String id, {
    String? userId,
  }) async {
    final url = Uri.parse('$baseUrl/get_post');
    try {
      final body = {'token': token, 'id': id};
      if (userId != null) body['user_id'] = userId;

      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> addPost({
    required String token,
    File? leftVideo,
    File? rightVideo,
    String? courseId,
    String? exerciseId,
    String? described,
    String? deviceSlave,
    String? deviceMaster,
  }) async {
    final url = Uri.parse('$baseUrl/add_post');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['token'] = token;

      if (courseId != null) request.fields['course_id'] = courseId;
      if (exerciseId != null) request.fields['exercise_id'] = exerciseId;
      if (described != null) request.fields['described'] = described;
      if (deviceSlave != null) request.fields['device_slave'] = deviceSlave;
      if (deviceMaster != null) request.fields['device_master'] = deviceMaster;

      if (leftVideo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('left_video', leftVideo.path),
        );
      }
      if (rightVideo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('right_video', rightVideo.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("=== API addPost Status Code: ${response.statusCode} ===");
      print("=== API addPost Response Body: ${response.body} ===");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message':
              'Lỗi server (Mã: ${response.statusCode}) - ${response.body}',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> editPost({
    required String token,
    required String id,
    String? described,
    String? videoIndices,
    File? leftVideo,
    File? rightVideo,
  }) async {
    final url = Uri.parse('$baseUrl/edit_post');
    try {
      var request = http.MultipartRequest('POST', url);
      request.fields['token'] = token;
      request.fields['id'] = id;

      if (described != null) request.fields['described'] = described;
      if (videoIndices != null) request.fields['video_indices'] = videoIndices;

      if (leftVideo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('left_video', leftVideo.path),
        );
      }
      if (rightVideo != null) {
        request.files.add(
          await http.MultipartFile.fromPath('right_video', rightVideo.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> deletePost(
    String token,
    String id,
  ) async {
    final url = Uri.parse('$baseUrl/delete_post');
    try {
      final response = await http.post(url, body: {'token': token, 'id': id});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> reportPost(
    String token,
    String id,
    String subject,
    String details,
  ) async {
    final url = Uri.parse('$baseUrl/report_post');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'id': id,
          'subject': subject,
          'details': details,
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> getComment(
    String token,
    String id,
    String index,
    String count, {
    String? userId,
  }) async {
    final url = Uri.parse('$baseUrl/get_comment');
    try {
      final body = {'token': token, 'id': id, 'index': index, 'count': count};
      if (userId != null) body['user_id'] = userId;

      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> like(String token, String id) async {
    final url = Uri.parse('$baseUrl/like');
    try {
      final response = await http.post(url, body: {'token': token, 'id': id});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> setComment(
    String token,
    String id,
    String index,
    String count, {
    String? comment,
    String? score,
    String? detailMistakes,
  }) async {
    final url = Uri.parse('$baseUrl/set_comment');
    try {
      final body = {'token': token, 'id': id, 'index': index, 'count': count};
      if (comment != null) body['comment'] = comment;
      if (score != null) body['score'] = score;
      if (detailMistakes != null) body['detail_mistakes'] = detailMistakes;

      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkNewItem(
    String lastId, {
    String? categoryId,
  }) async {
    final url = Uri.parse('$baseUrl/check_new_item');
    try {
      final body = {'last_id': lastId};
      if (categoryId != null) body['category_id'] = categoryId;

      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> getListPosts(
    String index,
    String count, {
    String? token,
    String? categoryId,
    String? lastId,
    String? userId,
  }) async {
    final url = Uri.parse('$baseUrl/get_list_posts');
    try {
      final body = {'index': index, 'count': count};
      if (token != null) body['token'] = token;
      if (categoryId != null) body['category_id'] = categoryId;
      if (lastId != null) body['last_id'] = lastId;
      if (userId != null) body['user_id'] = userId;

      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }

  static Future<Map<String, dynamic>> search(
    String token,
    String keyword,
    String index,
    String count,
    String userId, {
    String? categoryId,
    String? durationMin,
    String? durationMax,
  }) async {
    final url = Uri.parse('$baseUrl/search');
    try {
      final body = {
        'token': token,
        'keyword': keyword,
        'index': index,
        'count': count,
        'user_id': userId,
      };
      if (categoryId != null) body['category_id'] = categoryId;
      if (durationMin != null) body['duration_min'] = durationMin;
      if (durationMax != null) body['duration_max'] = durationMax;

      final response = await http.post(url, body: body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Lỗi Exception: $e'};
    }
  }
}

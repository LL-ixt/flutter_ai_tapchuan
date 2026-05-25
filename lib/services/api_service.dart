import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// ignore_for_file: avoid_print, non_constant_identifier_names

class ApiService {
  static const String baseUrl = "https://group1.it4788.sukkaito.id.vn/it4788";

  static Map<String, String> _toRequestBody(Map<String, Object?> body) {
    final requestBody = <String, String>{};
    body.forEach((key, value) {
      if (value != null) {
        requestBody[key] = value.toString();
      }
    });
    return requestBody;
  }

  static Future<Map<String, dynamic>> _postForm(
    String endpoint,
    Map<String, Object?> body,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    try {
      final response = await http.post(url, body: _toRequestBody(body));
      print("status code $endpoint: ${response.statusCode}"); // Debug log
      print("=== API $endpoint Response: ${response.body}"); // Debug log
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
      print("status code logout: ${response.statusCode}"); // Debug log
      print("=== API Logout Response: ${response.body}"); // Debug log
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

  static Future<Map<String, dynamic>> setDevtoken(
    String token,
    Object devtypeOrDevtoken, [
    String? devtoken,
  ]) {
    final resolvedDevtype = devtoken == null ? 0 : devtypeOrDevtoken;
    final resolvedDevtoken = devtoken ?? devtypeOrDevtoken.toString();
    return _postForm('set_devtoken', {
      'token': token,
      'devtype': resolvedDevtype,
      'devtoken': resolvedDevtoken,
    });
  }

  static Future<Map<String, dynamic>> setDevToken(
    String token,
    String devtoken, {
    Object devtype = 0,
  }) {
    return setDevtoken(token, devtype, devtoken);
  }

  static Future<Map<String, dynamic>> getConversation(
    String token,
    Object index,
    Object count, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return _postForm('get_conversation', {
      'token': token,
      'index': index,
      'count': count,
      'partnerId': partnerId ?? partner_id,
      'conversationId': conversationId ?? conversation_id,
    });
  }

  static Future<Map<String, dynamic>> deleteMessage(
    String token,
    String messageId,
  ) {
    return _postForm('delete_message', {
      'token': token,
      'messageId': messageId,
    });
  }

  static Future<Map<String, dynamic>> getListConversation(
    String token,
    Object index,
    Object count,
  ) {
    return _postForm('get_list_conversation', {
      'token': token,
      'index': index,
      'count': count,
    });
  }

  static Future<Map<String, dynamic>> deleteConversation(
    String token, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return _postForm('delete_conversation', {
      'token': token,
      'partnerId': partnerId ?? partner_id,
      'conversationId': conversationId ?? conversation_id,
    });
  }

  static Future<Map<String, dynamic>> checkNewItem(
    Object categoryId, {
    Object? lastId,
    Object? last_id,
  }) {
    return _postForm('check_new_item', {
      'category_id': categoryId,
      'last_id': lastId ?? last_id,
    });
  }

  static Future<Map<String, dynamic>> getNotification(
    String token,
    Object index,
    Object count,
  ) {
    return _postForm('get_notification', {
      'token': token,
      'index': index,
      'count': count,
    });
  }

  static Future<Map<String, dynamic>> setReadMessage(
    String token, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return _postForm('set_read_message', {
      'token': token,
      'partnerId': partnerId ?? partner_id,
      'conversationId': conversationId ?? conversation_id,
    });
  }

  static Future<Map<String, dynamic>> setReadNotification(
    String token,
    String notificationId,
  ) {
    return _postForm('set_read_notification', {
      'token': token,
      'notificationId': notificationId,
    });
  }

  static Future<Map<String, dynamic>> set_devtoken(
    String token,
    Object devtypeOrDevtoken, [
    String? devtoken,
  ]) {
    return setDevtoken(token, devtypeOrDevtoken, devtoken);
  }

  static Future<Map<String, dynamic>> get_conversation(
    String token,
    Object index,
    Object count, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return getConversation(
      token,
      index,
      count,
      partnerId: partnerId,
      conversationId: conversationId,
      partner_id: partner_id,
      conversation_id: conversation_id,
    );
  }

  static Future<Map<String, dynamic>> delete_message(
    String token,
    String messageId,
  ) {
    return deleteMessage(token, messageId);
  }

  static Future<Map<String, dynamic>> get_list_conversation(
    String token,
    Object index,
    Object count,
  ) {
    return getListConversation(token, index, count);
  }

  static Future<Map<String, dynamic>> delete_conversation(
    String token, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return deleteConversation(
      token,
      partnerId: partnerId,
      conversationId: conversationId,
      partner_id: partner_id,
      conversation_id: conversation_id,
    );
  }

  static Future<Map<String, dynamic>> check_new_item(
    Object categoryId, {
    Object? lastId,
    Object? last_id,
  }) {
    return checkNewItem(categoryId, lastId: lastId, last_id: last_id);
  }

  static Future<Map<String, dynamic>> get_notification(
    String token,
    Object index,
    Object count,
  ) {
    return getNotification(token, index, count);
  }

  static Future<Map<String, dynamic>> set_read_message(
    String token, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return setReadMessage(
      token,
      partnerId: partnerId,
      conversationId: conversationId,
      partner_id: partner_id,
      conversation_id: conversation_id,
    );
  }

  static Future<Map<String, dynamic>> set_read_notification(
    String token,
    String notificationId,
  ) {
    return setReadNotification(token, notificationId);
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/add_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/get_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/edit_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/delete_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/report_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/comment_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/like_models.dart';
import 'package:flutter_ai_tapchuan/features/feed/data/models/get_list_posts_models.dart';


// ignore_for_file: avoid_print, non_constant_identifier_names

class ApiService {
  static const String baseUrl = "https://group1.it4788.sukkaito.id.vn/it4788";

  static MediaType _getMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    if (lower.endsWith('.mp4')) return MediaType('video', 'mp4');
    return MediaType('application', 'octet-stream');
  }


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

  static Future<AddPostResponse> addPost(AddPostRequest request) async {
    final url = Uri.parse('$baseUrl/add_post');
    try {
      final req = http.MultipartRequest('POST', url);
      req.fields.addAll(request.toFields());
      
      if (request.leftVideo != null) {
        req.files.add(await http.MultipartFile.fromPath('left_video', request.leftVideo!.path));
      } else if (request.leftVideoBytes != null) {
        final filename = request.leftVideoName ?? 'left_video.mp4';
        req.files.add(http.MultipartFile.fromBytes(
          'left_video',
          request.leftVideoBytes!,
          filename: filename,
          contentType: _getMediaType(filename),
        ));
      }

      if (request.rightVideo != null) {
        req.files.add(await http.MultipartFile.fromPath('right_video', request.rightVideo!.path));
      } else if (request.rightVideoBytes != null) {
        final filename = request.rightVideoName ?? 'right_video.mp4';
        req.files.add(http.MultipartFile.fromBytes(
          'right_video',
          request.rightVideoBytes!,
          filename: filename,
          contentType: _getMediaType(filename),
        ));
      }

      final streamedResponse = await req.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("status code addPost: ${response.statusCode}");
      print("=== API Add Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return AddPostResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return AddPostResponse(code: '404', message: 'API Endpoint chưa được định nghĩa trên Server');
      } else {
        return AddPostResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return AddPostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<GetPostResponse> getPost(GetPostRequest request) async {
    final url = Uri.parse('$baseUrl/get_post');
    try {
      final response = await http.post(
        url,
        body: request.toJson(),
      );
      print("status code getPost: ${response.statusCode}");
      print("=== API Get Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return GetPostResponse.fromJson(jsonDecode(response.body));
      } else {
        return GetPostResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return GetPostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<EditPostResponse> editPost(EditPostRequest request) async {
    final url = Uri.parse('$baseUrl/edit_post');
    try {
      final req = http.MultipartRequest('POST', url);
      req.fields.addAll(request.toFields());
      
      if (request.leftVideo != null) {
        req.files.add(await http.MultipartFile.fromPath('left_video', request.leftVideo!.path));
      } else if (request.leftVideoBytes != null) {
        final filename = request.leftVideoName ?? 'left_video.mp4';
        req.files.add(http.MultipartFile.fromBytes(
          'left_video',
          request.leftVideoBytes!,
          filename: filename,
          contentType: _getMediaType(filename),
        ));
      }

      if (request.rightVideo != null) {
        req.files.add(await http.MultipartFile.fromPath('right_video', request.rightVideo!.path));
      } else if (request.rightVideoBytes != null) {
        final filename = request.rightVideoName ?? 'right_video.mp4';
        req.files.add(http.MultipartFile.fromBytes(
          'right_video',
          request.rightVideoBytes!,
          filename: filename,
          contentType: _getMediaType(filename),
        ));
      }

      final streamedResponse = await req.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("status code editPost: ${response.statusCode}");
      print("=== API Edit Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return EditPostResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return EditPostResponse(code: '404', message: 'API Endpoint chưa được định nghĩa trên Server');
      } else {
        return EditPostResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return EditPostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<DeletePostResponse> deletePost(DeletePostRequest request) async {
    final url = Uri.parse('$baseUrl/delete_post');
    try {
      final response = await http.post(
        url,
        body: request.toJson(),
      );
      print("status code deletePost: ${response.statusCode}");
      print("=== API Delete Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return DeletePostResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return DeletePostResponse(code: '404', message: 'API Endpoint chưa được định nghĩa trên Server');
      } else {
        return DeletePostResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return DeletePostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<ReportPostResponse> reportPost(ReportPostRequest request) async {
    final url = Uri.parse('$baseUrl/report_post');
    try {
      final response = await http.post(
        url,
        body: request.toJson(),
      );
      print("status code reportPost: ${response.statusCode}");
      print("=== API Report Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return ReportPostResponse.fromJson(jsonDecode(response.body));
      } else {
        return ReportPostResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return ReportPostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<GetCommentResponse> getComment(GetCommentRequest request) async {
    final url = Uri.parse('$baseUrl/get_comment');
    try {
      final response = await http.post(
        url,
        body: request.toJson(),
      );
      print("status code getComment: ${response.statusCode}");
      print("=== API Get Comment Response: ${response.body}");

      if (response.statusCode == 200) {
        return GetCommentResponse.fromJson(jsonDecode(response.body));
      } else {
        return GetCommentResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return GetCommentResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<GetListPostsResponse> getListPosts(GetListPostsRequest request) async {
    final url = Uri.parse('$baseUrl/get_list_posts');
    try {
      final response = await http.post(
        url,
        body: request.toJson(),
      );
      print("status code getListPosts: ${response.statusCode}");
      print("=== API Get List Posts Response: ${response.body}");

      if (response.statusCode == 200) {
        return GetListPostsResponse.fromJson(jsonDecode(response.body));
      } else {
        return GetListPostsResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return GetListPostsResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<LikeResponse> like(LikeRequest request) async {
    final url = Uri.parse('$baseUrl/like');
    try {
      final response = await http.post(
        url,
        body: request.toJson(),
      );
      print("status code like: ${response.statusCode}");
      print("=== API Like Response: ${response.body}");

      if (response.statusCode == 200) {
        return LikeResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return LikeResponse(code: '404', message: 'API Endpoint chưa được định nghĩa trên Server');
      } else {
        return LikeResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return LikeResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<SetCommentResponse> setComment(SetCommentRequest request) async {
    final url = Uri.parse('$baseUrl/set_comment');
    try {
      final response = await http.post(
        url,
        body: request.toJson(),
      );
      print("status code setComment: ${response.statusCode}");
      print("=== API Set Comment Response: ${response.body}");

      if (response.statusCode == 200) {
        return SetCommentResponse.fromJson(jsonDecode(response.body));
      } else {
        return SetCommentResponse(code: '1001', message: 'Không thể kết nối Internet hoặc Server lỗi');
      }
    } catch (e) {
      return SetCommentResponse(code: '9999', message: 'Lỗi Exception: $e');
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

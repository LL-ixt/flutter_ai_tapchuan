import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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

  static Future<bool> checkInternet() async {
    try {
      if (kIsWeb) {
        final response = await http
            .head(Uri.parse(baseUrl))
            .timeout(const Duration(seconds: 2));
        return true;
      } else {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 2));
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      }
    } catch (_) {
      return false;
    }
  }

  static String _formatTimestamp(String timestamp) {
    try {
      DateTime date;
      if (timestamp.contains('T') || timestamp.contains('-')) {
        date = DateTime.parse(timestamp).toLocal();
      } else {
        double timestampDouble = double.parse(timestamp);
        date = DateTime.fromMillisecondsSinceEpoch((timestampDouble * 1000).toInt());
      }
      String pad(int n) => n.toString().padLeft(2, '0');
      return '${pad(date.day)}/${pad(date.month)}/${date.year} ${pad(date.hour)}:${pad(date.minute)}';
    } catch (e) {
      return timestamp; // Trả về nguyên gốc nếu lỗi
    }
  }

  static MediaType _getMediaType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg'))
      return MediaType('image', 'jpeg');
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
    final hasConnection = await checkInternet();
    if (!hasConnection) {
      return {
        'code': '1001',
        'message': 'Không có kết nối Internet. Vui lòng kiểm tra lại mạng.',
      };
    }




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
      ).timeout(const Duration(seconds: 10));
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
    final hasConnection = await checkInternet();
    if (!hasConnection) {
      return {
        'code': '1001',
        'message': 'Không có kết nối Internet. Vui lòng kiểm tra lại mạng.',
      };
    }





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
      ).timeout(const Duration(seconds: 10));
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

  static Future<Map<String, dynamic>> getVerifyCode(String phone) async {
    final url = Uri.parse('$baseUrl/get_verify_code');
    try {
      final response = await http.post(
        url,
        body: {'phonenumber': phone},
      );
      print("status code getVerifyCode: ${response.statusCode}");
      print("=== API Get Verify Code Response: ${response.body}");
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
  // =========================================================
  // PHẦN CỦA QUÂN: 8 API (Search, Students, Courses, Blocks...)
  // =========================================================

  // 1. API: TÌM KIẾM (search)
  static Future<Map<String, dynamic>> search(
    String token,
    String keyword,
    String userId,
    int index,
    int count, {
    String categoryId = "",
    String durationMin = "",
    String durationMax = "",
  }) async {
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
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 2. API: LẤY LỊCH SỬ TÌM KIẾM (get_saved_search)
  static Future<Map<String, dynamic>> getSavedSearch(
    String token,
    int index,
    int count, {
    String userId = "",
  }) async {
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
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 3. API: XÓA LỊCH SỬ TÌM KIẾM (del_saved_search)
  static Future<Map<String, dynamic>> delSavedSearch(
    String token,
    String searchId,
    String all,
  ) async {
    final url = Uri.parse('$baseUrl/del_saved_search');
    try {
      final response = await http.post(
        url,
        body: {'token': token, 'search_id': searchId, 'all': all},
      );
      print("status code delSavedSearch: ${response.statusCode}");
      print("=== API Del Saved Search Response: ${response.body}");
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

  // 4. API: LẤY DANH SÁCH TOÀN BỘ HỌC VIÊN (get_list_students)
  static Future<Map<String, dynamic>> getListStudents(
    String token,
    int index,
    int count, {
    String userId = "",
  }) async {
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
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 5. API: LẤY THÔNG TIN NGƯỜI DÙNG (get_user_info)
  static Future<Map<String, dynamic>> getUserInfo({
    required String token,
    String? userId,
  }) async {
    final url = Uri.parse('$baseUrl/get_user_info');
    try {
      final body = <String, String>{'token': token};
      if (userId != null && userId.isNotEmpty) {
        body['userId'] = userId;
      }
      final response = await http.post(url, body: body);
      print("status code getUserInfo: ${response.statusCode}");
      print("=== API Get User Info Response: ${response.body}");
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

  // 6. API: CẬP NHẬT THÔNG TIN NGƯỜI DÙNG (set_user_info)
  static Future<Map<String, dynamic>> setUserInfo(
    String token, {
    String? username,
    File? avatar,
    Uint8List? avatarBytes,
    String? avatarName,
    File? coverImage,
    Uint8List? coverImageBytes,
    String? coverImageName,
    String? description,
  }) async {
    final url = Uri.parse('$baseUrl/set_user_info');
    try {
      var request = http.MultipartRequest('POST', url);

      request.fields['token'] = token;

      if (username != null && username.isNotEmpty) {
        request.fields['username'] = username.trim();
      }

      if (description != null) {
        request.fields['description'] = description.trim();
      }

      if (avatar != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatar.path),
        );
      } else if (avatarBytes != null) {
        final filename = avatarName ?? 'avatar.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'avatar',
            avatarBytes,
            filename: filename,
            contentType: _getMediaType(filename),
          ),
        );
      }

      if (coverImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('coverImage', coverImage.path),
        );
      } else if (coverImageBytes != null) {
        final filename = coverImageName ?? 'cover_image.jpg';
        request.files.add(
          http.MultipartFile.fromBytes(
            'coverImage',
            coverImageBytes,
            filename: filename,
            contentType: _getMediaType(filename),
          ),
        );
      }

      var streamedResponse = await request.send();

      var response = await http.Response.fromStream(streamedResponse);

      print("status code setUserInfo: ${response.statusCode}");
      print("=== API Set User Info Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  // 7. API: LẤY DANH SÁCH KHÓA HỌC CỦA HỌC VIÊN (get_list_courses_of_student)
  static Future<Map<String, dynamic>> getListCoursesOfStudent(
    String token,
    String userId,
    int index,
    int count,
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
      print("=== API Get List Courses Of Student Response: ${response.body}");
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

  // 8. API: LẤY DANH SÁCH BỊ CHẶN (get_list_blocks)
  static Future<Map<String, dynamic>> getListBlocks(
    String token,
    int index,
    int count, {
    String userId = "",
  }) async {
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
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 9. API: BLOCK/UNBLOCK USER (blocks)
  static Future<Map<String, dynamic>> setBlock(
    String token,
    String userId,
    String type, // '0' = block, '1' = unblock (thường là thế)
  ) async {
    final url = Uri.parse('$baseUrl/set_block'); // Fix endpoint URL
    try {
      // Chuẩn API IT4788: type = 0 (block) / 1 (unblock)
      // Nhưng user request ghi: type (block, unblock), để chắc chắn ta sẽ map
      String apiType = type;
      if (type == 'block' || type == '0') apiType = '0';
      if (type == 'unblock' || type == '1') apiType = '1';

      final response = await http.post(
        url,
        body: {'token': token, 'userId': userId, 'type': apiType},
      );
      print("status code setBlock: ${response.statusCode}");
      print("=== API Set Block Response: ${response.body}");
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

  // 10. API: LẤY CÀI ĐẶT THÔNG BÁO (get_push_settings)
  static Future<Map<String, dynamic>> getPushSettings(String token) async {
    final url = Uri.parse('$baseUrl/get_push_settings');
    try {
      final response = await http.post(url, body: {'token': token});
      print("status code getPushSettings: ${response.statusCode}");
      print("=== API Get Push Settings Response: ${response.body}");
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

  // 11. API: CẬP NHẬT CÀI ĐẶT THÔNG BÁO (set_push_settings)
  static Future<Map<String, dynamic>> setPushSettings({
    required String token,
    bool? likeComment,
    bool? fromFriends,
    bool? requestedFriend,
    bool? suggestedFriend,
    bool? birthday,
    bool? video,
    bool? report,
    bool? soundOn,
    bool? notificationOn,
    bool? vibrantOn,
    bool? ledOn,
  }) async {
    // API endpoint được sửa thành set_push_settings
    final url = Uri.parse('$baseUrl/set_push_settings');

    // Yêu cầu của bạn là input on/off, tôi sẽ map bool -> "1"/"0" hoặc "on"/"off" tuỳ BE, nhưng thường BE nhận 1/0
    String toVal(bool? val) => val == true ? '1' : '0';

    final body = <String, String>{'token': token};

    if (likeComment != null) body['likeComment'] = toVal(likeComment);
    if (fromFriends != null) body['fromFriends'] = toVal(fromFriends);
    if (requestedFriend != null)
      body['requestedFriend'] = toVal(requestedFriend);
    if (suggestedFriend != null)
      body['suggestedFriend'] = toVal(suggestedFriend);
    if (birthday != null) body['birthday'] = toVal(birthday);
    if (video != null) body['video'] = toVal(video);
    if (report != null) body['report'] = toVal(report);
    if (soundOn != null) body['soundOn'] = toVal(soundOn);
    if (notificationOn != null) body['notificationOn'] = toVal(notificationOn);
    if (vibrantOn != null) body['vibrantOn'] = toVal(vibrantOn);
    if (ledOn != null) body['ledOn'] = toVal(ledOn);

    try {
      final response = await http.post(url, body: body);
      print("status code setPushSettings: ${response.statusCode}");
      print("=== API Set Push Settings Response: ${response.body}");
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

  static Future<AddPostResponse> addPost(AddPostRequest request) async {
    final url = Uri.parse('$baseUrl/add_post');
    try {
      final req = http.MultipartRequest('POST', url);
      req.fields.addAll(request.toFields());

      if (request.leftVideo != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'left_video',
            request.leftVideo!.path,
          ),
        );
      } else if (request.leftVideoBytes != null) {
        final filename = request.leftVideoName ?? 'left_video.mp4';
        req.files.add(
          http.MultipartFile.fromBytes(
            'left_video',
            request.leftVideoBytes!,
            filename: filename,
            contentType: _getMediaType(filename),
          ),
        );
      }

      if (request.rightVideo != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'right_video',
            request.rightVideo!.path,
          ),
        );
      } else if (request.rightVideoBytes != null) {
        final filename = request.rightVideoName ?? 'right_video.mp4';
        req.files.add(
          http.MultipartFile.fromBytes(
            'right_video',
            request.rightVideoBytes!,
            filename: filename,
            contentType: _getMediaType(filename),
          ),
        );
      }

      final streamedResponse = await req.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("status code addPost: ${response.statusCode}");
      print("=== API Add Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return AddPostResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return AddPostResponse(
          code: '404',
          message: 'API Endpoint chưa được định nghĩa trên Server',
        );
      } else {
        return AddPostResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
      }
    } catch (e) {
      return AddPostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<GetPostResponse> getPost(GetPostRequest request) async {
    final url = Uri.parse('$baseUrl/get_post');
    try {
      final response = await http.post(url, body: request.toJson());
      print("status code getPost: ${response.statusCode}");
      print("=== API Get Post Response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'] is Map) {
          if (jsonResponse['data']['created'] != null) {
            jsonResponse['data']['created'] = _formatTimestamp(jsonResponse['data']['created'].toString());
          }
        }
        return GetPostResponse.fromJson(jsonResponse);
      } else {
        return GetPostResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
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
        req.files.add(
          await http.MultipartFile.fromPath(
            'left_video',
            request.leftVideo!.path,
          ),
        );
      } else if (request.leftVideoBytes != null) {
        final filename = request.leftVideoName ?? 'left_video.mp4';
        req.files.add(
          http.MultipartFile.fromBytes(
            'left_video',
            request.leftVideoBytes!,
            filename: filename,
            contentType: _getMediaType(filename),
          ),
        );
      }

      if (request.rightVideo != null) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'right_video',
            request.rightVideo!.path,
          ),
        );
      } else if (request.rightVideoBytes != null) {
        final filename = request.rightVideoName ?? 'right_video.mp4';
        req.files.add(
          http.MultipartFile.fromBytes(
            'right_video',
            request.rightVideoBytes!,
            filename: filename,
            contentType: _getMediaType(filename),
          ),
        );
      }

      final streamedResponse = await req.send();
      final response = await http.Response.fromStream(streamedResponse);

      print("status code editPost: ${response.statusCode}");
      // print("=== API Edit Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return EditPostResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return EditPostResponse(
          code: '404',
          message: 'API Endpoint chưa được định nghĩa trên Server',
        );
      } else {
        return EditPostResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
      }
    } catch (e) {
      return EditPostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<DeletePostResponse> deletePost(
    DeletePostRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/delete_post');
    try {
      final response = await http.post(url, body: request.toJson());
      print("status code deletePost: ${response.statusCode}");
      print("=== API Delete Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return DeletePostResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return DeletePostResponse(
          code: '404',
          message: 'API Endpoint chưa được định nghĩa trên Server',
        );
      } else {
        return DeletePostResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
      }
    } catch (e) {
      return DeletePostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<ReportPostResponse> reportPost(
    ReportPostRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/report_post');
    try {
      final response = await http.post(url, body: request.toJson());
      print("status code reportPost: ${response.statusCode}");
      print("=== API Report Post Response: ${response.body}");

      if (response.statusCode == 200) {
        return ReportPostResponse.fromJson(jsonDecode(response.body));
      } else {
        return ReportPostResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
      }
    } catch (e) {
      return ReportPostResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<GetCommentResponse> getComment(
    GetCommentRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/get_comment');
    try {
      final response = await http.post(url, body: request.toJson());
      print("status code getComment: ${response.statusCode}");
      print("=== API Get Comment Response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        var rawData = jsonResponse['data'];
        List? list;
        if (rawData is List) {
          list = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          list = rawData['data'];
        }
        
        if (list != null) {
          for (var comment in list) {
            if (comment is Map && comment['created'] != null) {
              comment['created'] = _formatTimestamp(comment['created'].toString());
            }
          }
        }
        return GetCommentResponse.fromJson(jsonResponse);
      } else {
        return GetCommentResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
      }
    } catch (e) {
      return GetCommentResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<GetListPostsResponse> getListPosts(
    GetListPostsRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/get_list_posts');
    try {
      final response = await http.post(url, body: request.toJson());
      print("status code getListPosts: ${response.statusCode}");
      //print("=== API Get List Posts Response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['data'] != null && jsonResponse['data'] is Map && jsonResponse['data']['posts'] is List) {
          for (var post in jsonResponse['data']['posts']) {
            if (post is Map && post['created'] != null) {
              post['created'] = _formatTimestamp(post['created'].toString());
            }
          }
        }
        return GetListPostsResponse.fromJson(jsonResponse);
      } else {
        return GetListPostsResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
      }
    } catch (e) {
      return GetListPostsResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<LikeResponse> like(LikeRequest request) async {
    final url = Uri.parse('$baseUrl/like_post');
    try {
      final response = await http.post(url, body: request.toJson());
      print("status code like: ${response.statusCode}");
      print("=== API Like Response: ${response.body}");

      if (response.statusCode == 200) {
        return LikeResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return LikeResponse(
          code: '404',
          message: 'API Endpoint chưa được định nghĩa trên Server',
        );
      } else {
        return LikeResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
      }
    } catch (e) {
      return LikeResponse(code: '9999', message: 'Lỗi Exception: $e');
    }
  }

  static Future<SetCommentResponse> setComment(
    SetCommentRequest request,
  ) async {
    final url = Uri.parse('$baseUrl/set_comment');
    try {
      final response = await http.post(url, body: request.toJson());
      print("status code setComment: ${response.statusCode}");
      print("=== API Set Comment Response: ${response.body}");

      if (response.statusCode == 200) {
        return SetCommentResponse.fromJson(jsonDecode(response.body));
      } else {
        return SetCommentResponse(
          code: '1001',
          message: 'Không thể kết nối Internet hoặc Server lỗi',
        );
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

  static Future<Map<String, dynamic>> setSendMessage(
    String token,
    String message, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return _postForm('set_send_message', {
      'token': token,
      'message': message,
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

  static Future<Map<String, dynamic>> changePassword(
    String token,
    String password,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/change_password');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'token': token,
          'password': password,
          'newPassword': newPassword,
        },
      );
      print("status code changePassword: ${response.statusCode}");
      print("=== API Change Password Response: ${response.body}");
      if (response.statusCode == 200 || response.statusCode == 201) {
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

  static Future<Map<String, dynamic>> set_send_message(
    String token,
    String message, {
    String? partnerId,
    String? conversationId,
    String? partner_id,
    String? conversation_id,
  }) {
    return setSendMessage(
      token,
      message,
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

  // =========================================================
  // PHẦN CỦA KHÓA HỌC: 3 API (Requested Enrollment, Approve, Request Course)
  // =========================================================

  // 1. API: LẤY DANH SÁCH YÊU CẦU NHẬP HỌC (get_requested_enrollment)
  static Future<Map<String, dynamic>> getRequestedEnrollment(
    String token,
    int index,
    int count, {
    String userId = "",
  }) async {
    final url = Uri.parse('$baseUrl/get_requested_enrollment');
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
      print("status code getRequestedEnrollment: ${response.statusCode}");
      print("=== API Get Requested Enrollment Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 2. API: CHẤP THUẬN/TỪ CHỐI NHẬP HỌC (set_approve_enrollment)
  static Future<Map<String, dynamic>> setApproveEnrollment(
    String token,
    String userId,
    String isAccept, // '0' = reject, '1' = accept
  ) async {
    final url = Uri.parse('$baseUrl/set_approve_enrollment');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'user_id': userId,
          'is_accept': isAccept,
        },
      );
      print("status code setApproveEnrollment: ${response.statusCode}");
      print("=== API Set Approve Enrollment Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  // 3. API: YÊU CẦU THAM GIA KHÓA HỌC (set_request_course)
  static Future<Map<String, dynamic>> setRequestCourse(
    String token,
    String courseId,
    String userId,
  ) async {
    final url = Uri.parse('$baseUrl/set_request_course');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'course_id': courseId,
          'user_id': userId,
        },
      );
      print("status code setRequestCourse: ${response.statusCode}");
      print("=== API Set Request Course Response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'code': '1001', 'message': 'Không thể kết nối Internet hoặc Server lỗi'};
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkNewVersion({
    required String token,
    required String lastUpdate,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/check_new_version');
    try {
      final response = await http.post(
        url,
        body: {
          'token': token,
          'last_update': lastUpdate,
          'user_id': userId,
        },
      );
      print("status code checkNewVersion: ${response.statusCode}");
      print("=== API Check New Version Response: ${response.body}");
      try {
        return jsonDecode(response.body);
      } catch (_) {
        return {
          'code': '1001',
          'message': 'Không thể kết nối Internet hoặc Server lỗi',
        };
      }
    } catch (e) {
      return {'code': '9999', 'message': 'Exception error: $e'};
    }
  }

  static Future<Map<String, dynamic>> change_password(
    String token,
    String password,
    String newPassword,
  ) {
    return changePassword(token, password, newPassword);
  }

  static Future<Map<String, dynamic>> get_user_info({
    required String token,
    String? userId,
  }) {
    return getUserInfo(token: token, userId: userId);
  }

  static Future<Map<String, dynamic>> set_user_info(
    String token, {
    String? username,
    File? avatar,
    Uint8List? avatarBytes,
    String? avatarName,
    File? coverImage,
    Uint8List? coverImageBytes,
    String? coverImageName,
    String? description,
  }) {
    return setUserInfo(
      token,
      username: username,
      avatar: avatar,
      avatarBytes: avatarBytes,
      avatarName: avatarName,
      coverImage: coverImage,
      coverImageBytes: coverImageBytes,
      coverImageName: coverImageName,
      description: description,
    );
  }
}

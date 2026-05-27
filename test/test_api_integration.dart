import 'dart:convert';
import 'dart:io';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'package:flutter_ai_tapchuan/features/feed/data/models/get_list_posts_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/like_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/comment_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/add_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/get_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/edit_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/delete_post_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/report_post_models.dart';

void main() async {
  print("=== BAT DAU CHAY THU NGHIEM TICH HOP API ===");

  // 1. Thử đăng nhập bằng một tài khoản để lấy token
  final phone = "0359882538";
  final password = "123456";
  print("\n1. Đang gọi API login với phone: $phone...");
  final loginResult = await ApiService.login(phone, password);
  print("Login response: $loginResult");

  String token = "";
  String userId = "u1";
  if (loginResult['code'] == '1000' && loginResult['data'] != null) {
    token = loginResult['data']['token'] ?? "";
    userId = loginResult['data']['id'] ?? "u1";
    print("Lấy token thành công: $token");
  } else {
    print(
      "Lấy token thất bại. Chuyển sang chế độ gọi với thông tin giả lập hoặc tiếp tục chạy.",
    );
  }

  // 2. Kiểm thử lấy danh sách bài viết
  print("\n2. Đang gọi API getListPosts...");
  String? firstPostId;
  try {
    final req = GetListPostsRequest(
      token: token,
      categoryId: "0",
      lastId: "0",
      index: "0",
      count: "10",
      userId: userId,
    );
    final response = await ApiService.getListPosts(req);
    print("getListPosts - Response code: ${response.code}");
    print("getListPosts - Response message: ${response.message}");
    if (response.posts != null) {
      print(
        "getListPosts - Lấy được ${response.posts!.length} bài viết từ Server.",
      );
      if (response.posts!.isNotEmpty) {
        final firstPost = response.posts!.first;
        if (firstPost is Map) {
          firstPostId = firstPost['post_id']?.toString() ?? firstPost['id']?.toString();
        }
      }
    }
  } catch (e) {
    print("getListPosts - Lỗi: $e");
  }

  // 3. Kiểm thử Đăng bài viết (addPost) bằng dữ liệu video mp4 chuẩn
  print("\n3. Đang gọi API addPost (Đăng bài mới)...");
  final videoBytes = File('test/classroom.mp4').readAsBytesSync();

  String? createdPostId;
  try {
    final addReq = AddPostRequest(
      token: token,
      leftVideoBytes: videoBytes,
      leftVideoName: 'test_left_video.mp4',
      rightVideoBytes: videoBytes,
      rightVideoName: 'test_right_video.mp4',
      courseId: 'course_123',
      exerciseId: 'exercise_123',
      described: 'Bài đăng thử nghiệm tự động tích hợp API',
      deviceSlave: 'slave_123',
      deviceMaster: 'master_123',
    );
    final addRes = await ApiService.addPost(addReq);
    print("addPost - Response code: ${addRes.code}");
    print("addPost - Response message: ${addRes.message}");
    print("addPost - Created Post ID: ${addRes.postId}");
    createdPostId = addRes.postId;
  } catch (e) {
    print("addPost - Lỗi: $e");
  }

  // Sử dụng ID vừa tạo, hoặc dùng ID bài viết thật từ list, hoặc dùng ID bài viết mock nếu không có gì
  final testPostId = createdPostId ?? firstPostId ?? "post_test_dummy_id";
  print("\nSử dụng Post ID: $testPostId để test các API chi tiết.");

  // 4. Kiểm thử lấy chi tiết bài viết (getPost)
  print("\n4. Đang gọi API getPost...");
  try {
    final getReq = GetPostRequest(token: token, id: testPostId);
    final getRes = await ApiService.getPost(getReq);
    print("getPost - Response code: ${getRes.code}");
    print("getPost - Response message: ${getRes.message}");
  } catch (e) {
    print("getPost - Lỗi: $e");
  }

  // 5. Kiểm thử chỉnh sửa bài viết (editPost)
  print("\n5. Đang gọi API editPost...");
  try {
    final editReq = EditPostRequest(
      token: token,
      id: testPostId,
      described: 'Nội dung bài viết đã được cập nhật qua API',
      leftVideoBytes: videoBytes,
      leftVideoName: 'updated_left.mp4',
    );
    final editRes = await ApiService.editPost(editReq);
    print("editPost - Response code: ${editRes.code}");
    print("editPost - Response message: ${editRes.message}");
  } catch (e) {
    print("editPost - Lỗi: $e");
  }

  // 6. Kiểm thử tương tác (like)
  print("\n6. Đang gọi API like...");
  try {
    final likeReq = LikeRequest(token: token, id: testPostId);
    final likeRes = await ApiService.like(likeReq);
    print("like - Response code: ${likeRes.code}");
    print("like - Response message: ${likeRes.message}");
    print("like - Số lượt like hiện tại: ${likeRes.like}");
  } catch (e) {
    print("like - Lỗi: $e");
  }

  // 7. Kiểm thử bình luận (setComment & getComment)
  print("\n7. Đang gọi API setComment (Đăng bình luận)...");
  try {
    final setCommentReq = SetCommentRequest(
      token: token,
      id: testPostId,
      comment: 'Bình luận thử nghiệm tự động từ script',
      index: '0',
      count: '10',
    );
    final setCommentRes = await ApiService.setComment(setCommentReq);
    print("setComment - Response code: ${setCommentRes.code}");
    print("setComment - Response message: ${setCommentRes.message}");
  } catch (e) {
    print("setComment - Lỗi: $e");
  }

  print("\n8. Đang gọi API getComment (Lấy danh sách bình luận)...");
  try {
    final getCommentReq = GetCommentRequest(
      token: token,
      id: testPostId,
      userId: userId,
      index: '0',
      count: '10',
    );
    final getCommentRes = await ApiService.getComment(getCommentReq);
    print("getComment - Response code: ${getCommentRes.code}");
    print("getComment - Response message: ${getCommentRes.message}");
    print(
      "getComment - Số bình luận lấy về: ${getCommentRes.data?.length ?? 0}",
    );
  } catch (e) {
    print("getComment - Lỗi: $e");
  }

  // 8. Kiểm thử báo cáo bài viết (reportPost)
  print("\n9. Đang gọi API reportPost...");
  try {
    final reportReq = ReportPostRequest(
      token: token,
      id: testPostId,
      subject: 'Vi phạm nội quy',
      details: 'Bài đăng có chứa nội dung không phù hợp cho kiểm thử',
    );
    final reportRes = await ApiService.reportPost(reportReq);
    print("reportPost - Response code: ${reportRes.code}");
    print("reportPost - Response message: ${reportRes.message}");
  } catch (e) {
    print("reportPost - Lỗi: $e");
  }

  // 9. Kiểm thử xóa bài viết (deletePost)
  print("\n10. Đang gọi API deletePost...");
  try {
    final deleteReq = DeletePostRequest(token: token, id: testPostId);
    final deleteRes = await ApiService.deletePost(deleteReq);
    print("deletePost - Response code: ${deleteRes.code}");
    print("deletePost - Response message: ${deleteRes.message}");
  } catch (e) {
    print("deletePost - Lỗi: $e");
  }

  print("\n=== HOAN THANH CHAY THU NGHIEM TICH HOP ===");
}

import 'dart:math';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/comment_models.dart';
import 'package:flutter_ai_tapchuan/features/post/data/models/add_post_models.dart';

void main() async {
  print("=== TESTING NOTIFICATION PAYLOAD ===");
  final rand = Random();
  final suffixTeacher = (1000000 + rand.nextInt(9000000)).toString();
  final suffixStudent = (1000000 + rand.nextInt(9000000)).toString();
  final teacherPhone = "097$suffixTeacher";
  final studentPhone = "098$suffixStudent";
  const password = "123456";

  print("Registering Teacher: phone=$teacherPhone");
  final regTeacher = await ApiService.signup(teacherPhone, password, "GV");
  print("Teacher Registration Response: $regTeacher");

  print("Registering Student: phone=$studentPhone");
  final regStudent = await ApiService.signup(studentPhone, password, "HV");
  print("Student Registration Response: $regStudent");

  // Logins
  print("Logging in Teacher...");
  final loginTeacher = await ApiService.login(teacherPhone, password);
  print("Login Teacher Response: $loginTeacher");
  final teacherToken = loginTeacher['data']['token'];
  final teacherId = loginTeacher['data']['id'];
  print("Teacher ID: $teacherId");

  print("Logging in Student...");
  final loginStudent = await ApiService.login(studentPhone, password);
  final studentToken = loginStudent['data']['token'];
  final studentId = loginStudent['data']['id'];
  print("Student ID: $studentId");

  // Teacher creates a post
  print("Teacher creating a post...");
  final addPostRes = await ApiService.addPost(
    AddPostRequest(
      token: teacherToken,
      courseId: '',
      exerciseId: '',
      described: "Bài tập của thầy Panda $suffixTeacher",
      deviceSlave: "slave",
      deviceMaster: "master",
      leftVideoBytes: [1, 2, 3, 4],
      leftVideoName: 'left_video.mp4',
      rightVideoBytes: [1, 2, 3, 4],
      rightVideoName: 'right_video.mp4',
    ),
  );
  print("Post Creation Response Code: ${addPostRes.code}, Message: ${addPostRes.message}, PostId: ${addPostRes.postId}");
  final postId = addPostRes.postId;

  if (postId == null) {
    print("Post ID is null, aborting!");
    return;
  }

  // Student comments on the post
  print("Student commenting on teacher's post...");
  final commentRes = await ApiService.setComment(
    SetCommentRequest(
      token: studentToken,
      id: postId,
      comment: "Em nộp bài tập ạ!",
      index: "0",
      count: "10",
    ),
  );
  print("Comment Response: $commentRes");

  // Teacher fetches notifications
  print("Waiting 2 seconds for backend to process...");
  await Future.delayed(const Duration(seconds: 2));

  print("Teacher fetching notifications...");
  final notifRes = await ApiService.getNotification(teacherToken, 0, 50);
  print("=== RAW NOTIFICATION RESPONSE FOR TEACHER ===");
  print(notifRes);
}

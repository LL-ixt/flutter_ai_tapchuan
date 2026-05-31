import 'dart:io';
import 'package:flutter_ai_tapchuan/services/api_service.dart';

void main() async {
  print("=== BẮT ĐẦU TEST PUSH SETTINGS ===");

  final phone = "0359882538";
  final password = "123456";
  print("1. Login...");
  final loginResult = await ApiService.login(phone, password);
  
  String token = "mock_token";
  if (loginResult['code'] == '1000' && loginResult['data'] != null) {
    token = loginResult['data']['token'] ?? "";
    print("Login OK, token: $token");
  } else {
    print("Login failed, using fallback token: mock_token");
  }

  print("\n2. Gọi getPushSettings...");
  final getRes = await ApiService.getPushSettings(token);
  print("Result: $getRes");

  print("\n3. Gọi setPushSettings (tắt tất cả)...");
  final setRes1 = await ApiService.setPushSettings(
    token: token,
    likeComment: false,
    fromFriends: false,
    requestedFriend: false,
    suggestedFriend: false,
    birthday: false,
    video: false,
    report: false,
    soundOn: false,
    notificationOn: false,
    vibrantOn: false,
    ledOn: false,
  );
  print("Result: $setRes1");

  print("\n4. Gọi getPushSettings lại để kiểm tra...");
  final getRes2 = await ApiService.getPushSettings(token);
  print("Result: $getRes2");
  
  print("\n=== HOÀN THÀNH ===");
}

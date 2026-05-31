import 'dart:io';
import 'package:flutter_ai_tapchuan/services/api_service.dart';

void main() async {
  print("=== BẮT ĐẦU TEST SET BLOCK ===");

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

  // Chặn một userId bất kỳ, ví dụ "123" hoặc id của một tài khoản khác
  final userIdToBlock = "123";
  print("\n2. Gọi setBlock (block)...");
  final resBlock = await ApiService.setBlock(token, userIdToBlock, 'block');
  print("Result: $resBlock");

  print("\n3. Gọi setBlock (unblock)...");
  final resUnblock = await ApiService.setBlock(token, userIdToBlock, 'unblock');
  print("Result: $resUnblock");
  
  print("\n=== HOÀN THÀNH ===");
}

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceUtils {
  static Future<String> getHashedDeviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String rawId = "";

    // 1. Lấy ID thô tùy theo nền tảng
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      rawId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      rawId = iosInfo.identifierForVendor ?? "unknown_ios";
    }

    // 2. Mã hóa SHA-256 để bảo vệ Privacy 
    var bytes = utf8.encode(rawId); 
    var digest = sha256.convert(bytes);

    return digest.toString(); // Trả về chuỗi mã hóa đã băm
  }
}
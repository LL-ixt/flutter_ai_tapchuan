import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/main.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/pages/login_screen.dart';
import '../local_storage/secure_storage_helper.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://it4788.cqa.vn/api/v1', // Base URL theo spec nếu có, có thể thay đổi sau
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lấy token và device ID từ Secure Storage
          final token = await SecureStorageHelper.getToken();
          final deviceId = await SecureStorageHelper.getDeviceId();

          // Nhét Token vào Header
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Nhét DeviceID vào body request theo yêu cầu
          if (options.data is Map<String, dynamic>) {
            options.data['uuid'] = deviceId;
          } else if (options.data == null) {
            options.data = {'uuid': deviceId};
          } else if (options.data is FormData) {
            (options.data as FormData).fields.add(MapEntry('uuid', deviceId));
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          final data = response.data;
          
          // Đọc đặc tả, bắt code 9993 hoặc 9998
          if (data is Map<String, dynamic>) {
            final code = data['code']?.toString();
            if (code == '9993' || code == '9998') {
              // Token hết hạn hoặc không hợp lệ -> Xoá Token
              await SecureStorageHelper.deleteToken();
              
              // Điều hướng về màn hình Login kèm thông báo
              final context = navigatorKey.currentContext;
              if (context != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phiên đăng nhập hết hạn', style: TextStyle(color: Colors.white))),
                );
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            }
          }
          
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Bắt các lỗi mất kết nối mạng và ném ra Custom Exception
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.connectionError ||
              e.error is SocketException) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: NetworkException('Không thể kết nối Internet'),
              ),
            );
          }
          return handler.next(e); // Các lỗi HTTP khác trả về bình thường
        },
      ),
    );
  }

  Dio get dio => _dio;
}

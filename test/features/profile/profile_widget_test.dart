import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ai_tapchuan/features/profile/presentation/pages/profile_screen.dart';
import 'dart:io';
import 'dart:convert';
import '../../mock_http_overrides.dart';

class MockAuthCubit extends Cubit<AuthState> implements AuthCubit {
  MockAuthCubit() : super(const AuthState.success(username: 'Student', role: 'HV', token: 'mock_token', userId: 'mock_uid'));
  
  @override
  void login({required String phone, required String password}) {}
  
  @override
  void logout() {}
  
  @override
  void checkAuth() {}

  @override
  Future<bool> restoreSession() async => true;

  @override
  void updateUserInfo({String? username, String? avatar}) {}
}

void main() {
  final mockResponses = {
    'get_user_info': jsonEncode({
      "code": "1000",
      "message": "OK",
      "data": {
        "id": "mock_uid",
        "username": "Trần Văn A",
        "avatar": "https://i.pravatar.cc/150?u=mock_uid",
        "description": "Người yêu thích võ thuật và lập trình.",
        "address": "Hà Nội, Việt Nam"
      }
    }),
    'get_list_posts': jsonEncode({
      "code": "1000",
      "message": "OK",
      "data": {
        "posts": [
          {
            "post_id": "post_0",
            "id": "post_0",
            "author": {
              "id": "mock_uid",
              "name": "Trần Văn A",
              "username": "Trần Văn A",
              "avatar": "https://i.pravatar.cc/150?u=mock_uid",
              "role": "HV"
            },
            "described": "Bài tập về nhà môn Di chuyển cơ bản",
            "created": "2 giờ trước",
            "like": "10",
            "comment": "5"
          }
        ]
      }
    })
  };

  Widget createWidgetUnderTest() {
    return BlocProvider<AuthCubit>(
      create: (context) => MockAuthCubit(),
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    );
  }

  testWidgets('Render Test: Hiển thị các phần tử chính của Trang Cá nhân', (WidgetTester tester) async {
    HttpOverrides.global = MockHttpOverrides(mockResponses);

    // Lưu lại bộ xử lý lỗi cũ
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    
    try {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      for (var widget in tester.allWidgets) {
        if (widget is Text) {
          print("PROFILE TEST TEXT: '${widget.data}'");
        }
      }

      // Tên AppBar và User Name
      expect(find.text('Trần Văn A'), findsWidgets);
      
      // Bio
      expect(find.text('Người yêu thích võ thuật và lập trình.'), findsOneWidget);
      
      // Nút chỉnh sửa
      expect(find.text('Chỉnh sửa trang cá nhân'), findsOneWidget);

      // Kéo thanh cuộn để thấy bài viết
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      
      // Text trong bài viết PostCard
      expect(find.textContaining('Bài tập về nhà môn Di chuyển cơ bản'), findsOneWidget);
    } finally {
      // Khôi phục bộ xử lý lỗi cũ
      FlutterError.onError = originalOnError;
    }
  });
}

void ignoreOverflowErrors(
  FlutterErrorDetails details, {
  bool forceReport = false,
}) {
  bool isOverflowError = false;
  
  // Kiểm tra xem lỗi có phải là do RenderFlex bị overflow không
  var exception = details.exception;
  if (exception is FlutterError) {
    isOverflowError = !exception.diagnostics.any(
        (e) => e.value.toString().startsWith("A RenderFlex overflowed by"));
  }

  // Bỏ qua lỗi overflow trong môi trường test
  if (isOverflowError) {
    debugPrint('Ignored overflow error.');
  } else {
    FlutterError.presentError(details);
  }
}

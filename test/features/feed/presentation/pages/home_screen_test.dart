import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ai_tapchuan/features/feed/presentation/pages/home_screen.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../mock_http_overrides.dart';

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
    'get_list_posts': jsonEncode({
      "code": "1000",
      "message": "OK",
      "data": {
        "posts": [
          {
            "post_id": "post_0",
            "id": "post_0",
            "author": {
              "id": "user_0",
              "name": "Học viên 0",
              "username": "Học viên 0",
              "avatar": "https://i.pravatar.cc/150?u=user_0",
              "role": "HV"
            },
            "described": "Bài tập của Học viên 0",
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
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Widget Tests', () {
    testWidgets('1. Render Test: Displays CircularProgressIndicator initially', (WidgetTester tester) async {
      HttpOverrides.global = MockHttpOverrides(mockResponses);

      await tester.pumpWidget(createWidgetUnderTest());

      // Kiểm tra xem AppBar text có hiển thị không
      expect(find.text('EduSocial AI'), findsOneWidget);
      // Lúc đầu sẽ là loading state -> hiển thị ProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Advance time so that the Cubit's timer finishes, avoiding the pending timer exception
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('2. Interaction Test: Loads data and displays PostCards after delay', (WidgetTester tester) async {
      HttpOverrides.global = MockHttpOverrides(mockResponses);

      await tester.pumpWidget(createWidgetUnderTest());

      // Chờ 1.5 giây cho Cubit load xong dữ liệu bằng cách sử dụng pump
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(); // Kích hoạt frame mới sau khi dữ liệu đã load

      // ProgressIndicator phải biến mất
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Phải có ít nhất 1 bài viết được hiển thị
      // Do có 5 mock posts, ta kiểm tra có widget chứa text 'Học viên 0' không
      expect(find.textContaining('Học viên 0'), findsWidgets);
    });
  });
}

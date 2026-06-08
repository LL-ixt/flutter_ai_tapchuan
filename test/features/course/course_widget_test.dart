import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/course_tab.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'dart:io';
import 'dart:convert';
import '../../mock_http_overrides.dart';

class MockAuthCubit extends Cubit<AuthState> implements AuthCubit {
  final String mockRole;
  MockAuthCubit({this.mockRole = 'GV'})
      : super(AuthState.success(
          username: 'User',
          role: mockRole,
          token: 'mock_token',
          userId: 'mock_uid',
        ));
  
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
    'get_requested_enrollment': jsonEncode({
      "code": "1000",
      "message": "OK",
      "data": {
        "data": [
          {
            "id": "req_1",
            "request": {
              "id": "student_1",
              "user_name": "Trần Văn A",
              "avatar": "https://i.pravatar.cc/150?u=student_1"
            }
          }
        ]
      }
    }),
    'set_approve_enrollment': jsonEncode({
      "code": "1000",
      "message": "OK"
    })
  };

  Widget createWidgetUnderTest({String role = 'GV'}) {
    return BlocProvider<AuthCubit>(
      create: (context) => MockAuthCubit(mockRole: role),
      child: const MaterialApp(
        home: CourseTab(),
      ),
    );
  }

  testWidgets('Render Test (GV): Hiển thị 2 Tab Yêu cầu học và Thống kê các bài tập', (WidgetTester tester) async {
    HttpOverrides.global = MockHttpOverrides(mockResponses);

    await tester.pumpWidget(createWidgetUnderTest(role: 'GV'));
    await tester.pumpAndSettle();

    expect(find.text('Khóa học'), findsOneWidget);
    expect(find.text('Yêu cầu học'), findsNWidgets(2)); // Tab title and view header
    expect(find.text('Thống kê các bài tập'), findsOneWidget);
  });

  testWidgets('Interaction Test: GV accepts a student request', (WidgetTester tester) async {
    HttpOverrides.global = MockHttpOverrides(mockResponses);

    await tester.pumpWidget(createWidgetUnderTest(role: 'GV'));
    await tester.pump(); // Start fetching
    await tester.pump(const Duration(milliseconds: 500)); // Let future complete
    await tester.pumpAndSettle();

    for (var widget in tester.allWidgets) {
      if (widget is Text) {
        print("DEBUG Text widget: '${widget.data}'");
      }
    }

    // Check student request A exists
    expect(find.text('Trần Văn A'), findsOneWidget);

    // Find "Chấp nhận" button
    final approveButton = find.text('Chấp nhận').first;
    expect(approveButton, findsOneWidget);

    // Tap "Chấp nhận" button
    await tester.tap(approveButton);
    await tester.pump(); // Shows confirm dialog
    await tester.pumpAndSettle();

    // Verify confirm dialog title/text
    expect(find.text('Chấp nhận yêu cầu'), findsOneWidget);
    expect(find.text('Đồng ý'), findsOneWidget);

    // Tap "Đồng ý"
    await tester.tap(find.text('Đồng ý'));
    await tester.pump(); // calls API and updates state
    await tester.pumpAndSettle();

    // Once accepted, the list item is removed from the pending list
    expect(find.text('Trần Văn A'), findsNothing);
  });
}

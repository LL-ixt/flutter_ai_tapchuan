import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/teacher_assignments_tab.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/assignment_stats_screen.dart';

class MockAuthCubit extends Cubit<AuthState> implements AuthCubit {
  MockAuthCubit() : super(const AuthState.success(username: 'Teacher', role: 'GV', token: 'mock_token', userId: 'mock_uid'));
  
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
  Widget createWidgetUnderTest(Widget child) {
    return BlocProvider<AuthCubit>(
      create: (context) => MockAuthCubit(),
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  testWidgets('TeacherAssignmentsTab initial loading state render test', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const TeacherAssignmentsTab()));
    
    // Renders the CircularProgressIndicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('AssignmentStatsScreen initial loading state render test', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(const AssignmentStatsScreen(
      postId: 'test_post_id',
      postDescribed: 'Test Post Description',
    )));
    
    // Renders title and loading indicator
    expect(find.text('Thống kê nộp bài'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

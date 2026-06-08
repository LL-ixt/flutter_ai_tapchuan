import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/student_assignment_stats_screen.dart';

class MockStudentAuthCubit extends Cubit<AuthState> implements AuthCubit {
  MockStudentAuthCubit()
      : super(const AuthState.success(
          username: 'Student',
          role: 'HV',
          token: 'mock_token',
          userId: 'mock_student_id',
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
  Widget createWidgetUnderTest(Widget child) {
    return BlocProvider<AuthCubit>(
      create: (context) => MockStudentAuthCubit(),
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  testWidgets('StudentAssignmentStatsScreen initial loading state render test',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      const StudentAssignmentStatsScreen(
        instructorId: 'test_instructor_id',
        instructorName: 'Test Instructor',
        courseId: 'test_course_id',
        courseName: 'Test Course Name',
      ),
    ));

    // Renders title and loading indicator
    expect(find.text('Thống kê bài tập'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

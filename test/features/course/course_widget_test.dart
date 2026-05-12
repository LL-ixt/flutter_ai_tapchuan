import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/course_tab.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/widgets/student_list_tile.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: CourseTab(),
    );
  }

  testWidgets('Render Test: Hiển thị 2 Tab Khóa học và Danh sách học viên', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Khóa học'), findsOneWidget);
    expect(find.text('Đã đăng ký'), findsOneWidget);
    expect(find.text('Danh sách học viên'), findsOneWidget);
  });

  testWidgets('Interaction Test: Chuyển sang Tab Danh sách học viên và bấm Chấp nhận', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Bấm sang Tab Danh sách học viên
    await tester.tap(find.text('Danh sách học viên'));
    await tester.pumpAndSettle();

    expect(find.byType(StudentListTile), findsWidgets);

    // Tìm nút Chấp nhận
    final approveButton = find.text('Chấp nhận').first;
    expect(approveButton, findsOneWidget);

    // Tap nút Chấp nhận
    await tester.tap(approveButton);
    await tester.pumpAndSettle();

    // Nút "Chấp nhận" sẽ biến mất và thay bằng "Đã tham gia"
    expect(find.text('Đã tham gia'), findsWidgets);
  });
}

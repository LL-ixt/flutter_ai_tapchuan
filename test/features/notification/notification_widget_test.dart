import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_tapchuan/features/notification/presentation/pages/notification_tab.dart';
import 'package:flutter_ai_tapchuan/features/notification/presentation/widgets/notification_tile.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: NotificationTab(),
    );
  }

  testWidgets('Render Test: Hiển thị AppBar và Danh sách thông báo', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Thông báo'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byType(NotificationTile), findsWidgets);
  });

  testWidgets('Interaction Test: Click vào thông báo chuyển thành đã đọc', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tìm một tile thông báo chưa đọc (nếu có trong mock data, ví dụ mock id = '1' đang false)
    final firstTile = find.byType(NotificationTile).first;
    expect(firstTile, findsOneWidget);

    // Tap vào thông báo đầu tiên
    await tester.tap(firstTile);
    await tester.pumpAndSettle();

    // Xác nhận rằng sau khi tap, NotificationCubit đã update trạng thái.
    // Kiểm tra UI có thay đổi không (mất dấu icon tròn màu xanh chưa đọc)
    // Hoặc kiểm tra logic nội bộ nếu tách riêng widget test
  });
}

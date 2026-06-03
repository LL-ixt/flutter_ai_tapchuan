import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:flutter_ai_tapchuan/features/feed/presentation/pages/home_screen.dart';

void main() {
  group('HomeScreen Widget Tests', () {
    testWidgets('1. Render Test: Displays CircularProgressIndicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      // Kiểm tra xem AppBar text có hiển thị không
      expect(find.text('EduSocial AI'), findsOneWidget);
      // Lúc đầu sẽ là loading state -> hiển thị ProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Advance time so that the Cubit's timer finishes, avoiding the pending timer exception
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('2. Interaction Test: Loads data and displays PostCards after delay', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

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
  });
}

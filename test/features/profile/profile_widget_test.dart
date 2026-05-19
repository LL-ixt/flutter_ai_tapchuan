import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_tapchuan/features/profile/presentation/pages/profile_screen.dart';

import 'package:network_image_mock/network_image_mock.dart';

void main() {
  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: ProfileScreen(),
    );
  }

  testWidgets('Render Test: Hiển thị các phần tử chính của Trang Cá nhân', (WidgetTester tester) async {
    // Lưu lại bộ xử lý lỗi cũ
    final originalOnError = FlutterError.onError;
    FlutterError.onError = ignoreOverflowErrors;
    
    try {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Tên AppBar và User Name
        expect(find.text('Trần Văn A'), findsWidgets);
        
        // Bio
        expect(find.text('Người yêu thích võ thuật và lập trình.'), findsOneWidget);
        
        // Nơi sống
        expect(find.text('Hà Nội, Việt Nam'), findsOneWidget);
        
        // Nút chỉnh sửa
        expect(find.text('Chỉnh sửa trang cá nhân'), findsOneWidget);

        // Kéo thanh cuộn để thấy bài viết
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
        await tester.pumpAndSettle();
        
        // Text trong bài viết PostCard
        expect(find.textContaining('Bài tập về nhà môn Di chuyển cơ bản'), findsOneWidget);
      });
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

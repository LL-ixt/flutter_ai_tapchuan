import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';

import 'package:flutter_ai_tapchuan/core/widgets/post_card.dart';
import 'package:flutter_ai_tapchuan/core/widgets/avatar_widget.dart';

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
  setUpAll(() {
    // Tránh lỗi khi gọi http requests từ NetworkImage trong test
    HttpOverrides.global = null;
  });

  group('PostCard Widget Tests', () {
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

    testWidgets('1. Render Test: PostCard loads without overflow', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            PostCard(
              postData: dummyPostData,
              isLiked: false,
              onLikeToggle: () {},
            ),
          ),
        );

        // Verify if elements are rendered
        expect(find.byType(PostCard), findsOneWidget);
        expect(find.byType(AvatarWidget), findsOneWidget);
        expect(find.text('Nguyễn Tiến Thành'), findsOneWidget);
        expect(find.text('2 giờ trước'), findsOneWidget);
        expect(find.text('150'), findsOneWidget);
        expect(find.text('32 Bình luận'), findsOneWidget);
        
        // Cần có 3 nút Action: Thích, Bình luận, Nộp bài
        expect(find.text('Thích'), findsOneWidget);
        expect(find.text('Bình luận'), findsOneWidget);
        expect(find.text('Nộp bài'), findsOneWidget);
      });
    });

    testWidgets('2. Empty/Null State Test: Handle empty data without crashing', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          createWidgetUnderTest(
            PostCard(
              postData: const {}, // Empty data
              isLiked: false,
              onLikeToggle: () {},
            ),
          ),
        );

        expect(find.byType(PostCard), findsOneWidget);
        // Với dummy default
        expect(find.text('Người dùng'), findsOneWidget);
        expect(find.text('Vừa xong'), findsOneWidget);
      });
    });

    testWidgets('3. Interaction Test: Like button toggles its state', (WidgetTester tester) async {
      bool likeState = false;

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          BlocProvider<AuthCubit>(
            create: (context) => MockAuthCubit(),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return MaterialApp(
                  home: Scaffold(
                    body: PostCard(
                      postData: dummyPostData,
                      isLiked: likeState,
                      onLikeToggle: () {
                        setState(() {
                          likeState = !likeState;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );

        // Ban đầu icon Thích là chưa active
        Icon likeIcon = tester.widget<Icon>(find.byIcon(Icons.thumb_up_outlined).first);
        expect(likeIcon, isNotNull);

        // Tap vào nút Thích (tìm theo text 'Thích' rồi lấy InkWell cha)
        await tester.tap(find.text('Thích'));
        await tester.pumpAndSettle();

        // State đã thay đổi, widget được build lại
        expect(likeState, true);
        
        // Expect icon Thích đổi thành icon đã active (nó là nút cuối cùng, nút đầu tiên là icon nhỏ màu trắng)
        Icon activeLikeIcon = tester.widget<Icon>(find.byIcon(Icons.thumb_up).last);
        expect(activeLikeIcon.color, const Color(0xFF1877F2)); // AppColors.primaryBlue
      });
    });
  });
}

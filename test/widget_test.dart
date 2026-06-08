import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/main.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:flutter_ai_tapchuan/features/notification/presentation/bloc/notification_cubit.dart';

void main() {
  testWidgets('EduSocial AI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
          BlocProvider<ChatCubit>(create: (_) => ChatCubit()),
          BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit(
              authCubit: context.read<AuthCubit>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    // Verify application starts
    expect(find.byType(MyApp), findsOneWidget);

    // Advance time to clear pending timers (e.g. from NotificationCubit status polling)
    await tester.pump(const Duration(seconds: 5));
  });
}

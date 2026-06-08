import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/pages/login_screen.dart';
//import 'package:flutter_ai_tapchuan/features/search/search_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ai_tapchuan/features/notification/presentation/bloc/notification_cubit.dart';
import 'features/main/presentation/pages/main_screen.dart';
import 'features/chat/presentation/bloc/chat_cubit.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<ChatCubit>(create: (_) => ChatCubit()),
        BlocProvider<NotificationCubit>(
          create: (context) =>
              NotificationCubit(authCubit: context.read<AuthCubit>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduSocial AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceWhite,
          foregroundColor: AppColors.primaryBlue,
          elevation: 0.5,
        ),
      ),
      home: const _AuthenticationHandler(),
    );
  }
}

class _AuthenticationHandler extends StatefulWidget {
  const _AuthenticationHandler();

  @override
  State<_AuthenticationHandler> createState() => _AuthenticationHandlerState();
}

class _AuthenticationHandlerState extends State<_AuthenticationHandler> {
  @override
  void initState() {
    super.initState();
    // Đăng ký callback khi Token bị vô hiệu hóa (ví dụ do đăng nhập thiết bị khác)
    ApiService.onTokenInvalid = () {
      if (mounted) {
        final authCubit = context.read<AuthCubit>();
        if (authCubit.state.token != null &&
            authCubit.state.token!.isNotEmpty) {
          authCubit.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Phiên đăng nhập đã hết hạn hoặc được đăng nhập ở thiết bị khác. Vui lòng đăng nhập lại.',
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    };
    // Kiểm tra phiên đăng nhập đã lưu khi app khởi động
    _checkSavedSession();
  }

  void _checkSavedSession() async {
    final authCubit = context.read<AuthCubit>();
    // Chờ một chút để UI render xong rồi mới kiểm tra
    await Future.delayed(const Duration(milliseconds: 100));
    await authCubit.restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        // Nếu là success thì hiển thị MainScreen
        if (state.isSuccess) {
          return const MainScreen();
        }
        // Ngược lại hiển thị LoginScreen
        return const LoginScreen();
      },
    );
  }
}

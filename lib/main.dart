import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
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
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    
    // Đăng ký callback lắng nghe sự kiện token bị vô hiệu hóa
    ApiService.onTokenExpired = () {
      if (mounted) {
        final authCubit = context.read<AuthCubit>();
        if (authCubit.state.isSuccess) {
          authCubit.logout();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập đã hết hạn hoặc tài khoản được đăng nhập ở thiết bị khác. Vui lòng đăng nhập lại.'),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.red,
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
    
    // Đợi tối thiểu 2 giây cho Splash Screen và đồng thời kiểm tra session
    await Future.wait([
      Future.delayed(const Duration(seconds: 2)),
      authCubit.restoreSession(),
    ]);

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const SplashScreen();
    }

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

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/icon.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 24),
            Text(
              'EduSocial AI',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

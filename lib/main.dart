import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'features/auth/presentation/pages/login_screen.dart';
//import 'package:flutter_ai_tapchuan/features/search/search_page.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'features/main/presentation/pages/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EduSocial AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Tạm thời tắt Google Fonts để không bị lỗi Failed to fetch font khi debug trên Web
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceWhite,
          foregroundColor: AppColors.primaryBlue,
          elevation: 0.5,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

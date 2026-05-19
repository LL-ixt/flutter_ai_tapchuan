import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/main/presentation/pages/main_screen.dart';

import 'core/local_storage/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceWhite,
          foregroundColor: AppColors.primaryBlue,
          elevation: 0.5,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/presentation/pages/login_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/local_storage/hive_service.dart';
import 'core/network/dio_client.dart';

import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';

import 'features/feed/data/datasources/feed_remote_data_source.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';
import 'features/feed/domain/repositories/feed_repository.dart';
import 'features/feed/presentation/bloc/feed_cubit.dart';

import 'features/post/data/datasources/post_remote_data_source.dart';
import 'features/post/presentation/bloc/post_cubit.dart';

import 'features/chat/data/datasources/chat_remote_data_source.dart';
import 'features/chat/presentation/bloc/chat_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initHive();
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DioClient>(create: (context) => DioClient()),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            AuthRemoteDataSourceImpl(context.read<DioClient>()),
          ),
        ),
        RepositoryProvider<FeedRepository>(
          create: (context) => FeedRepositoryImpl(
            FeedRemoteDataSourceImpl(context.read<DioClient>()),
          ),
        ),
        RepositoryProvider<PostRemoteDataSource>(
          create: (context) =>
              PostRemoteDataSourceImpl(context.read<DioClient>()),
        ),
        RepositoryProvider<ChatRemoteDataSource>(
          create: (context) =>
              ChatRemoteDataSourceImpl(context.read<DioClient>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(context.read<AuthRepository>()),
          ),
          BlocProvider<FeedCubit>(
            create: (context) => FeedCubit(context.read<FeedRepository>()),
          ),
          BlocProvider<PostCubit>(
            create: (context) =>
                PostCubit(context.read<PostRemoteDataSource>()),
          ),
          BlocProvider<ChatCubit>(
            create: (context) =>
                ChatCubit(context.read<ChatRemoteDataSource>()),
          ),
        ],
        child: MaterialApp(
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
          home: const LoginScreen(),
        ),
      ),
    );
  }
}

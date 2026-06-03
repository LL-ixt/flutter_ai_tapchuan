import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../features/auth/presentation/pages/login_screen.dart';
import 'settings_screen.dart';
import 'blocked_users_screen.dart';
import 'change_password_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      // Chỉ kích hoạt hàm bên dưới khi token chuyển từ "có" sang "null" (đã logout thành công)
      listenWhen: (previous, current) => previous.token != null && current.token == null,
      listener: (context, state) {
        debugPrint("Đã xóa sạch Token trong Cubit. Tiến hành chuyển hướng về LoginScreen...");
        
        // 2. THỰC HIỆN ĐIỀU HƯỚNG VÀ XÓA TOÀN BỘ STACK MÀN HÌNH CŨ
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false, // (route) => false có nghĩa là xóa sạch mọi màn hình trước đó, không cho Back lại
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground, // Nền xám nhạt như Facebook
        body: CustomScrollView(
          slivers: [
            // 1. AppBar đồng bộ với HomeScreen
            SliverAppBar(
              backgroundColor: AppColors.surfaceWhite,
              floating: true,
              pinned: true,
              elevation: 0,
              title: const Text(
                'Menu',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // LẮNG NGHE DỮ LIỆU TỪ AUTH_CUBIT
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                // Khởi tạo các giá trị mặc định phòng trường hợp lỗi state
                String currentUsername = "Người dùng";
                String currentRole = "HS";

                // Nếu trạng thái hiện tại là đã đăng nhập thành công, lấy data thật
                if (state.isSuccess) {
                  currentUsername = state.username;
                  currentRole = state.role;
                }

                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        const AvatarWidget(radius: 30, imageUrl: "https://i.pravatar.cc/150?img=3"),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // HIỂN THỊ USERNAME THẬT TỪ SERVER Ở ĐÂY
                              Text(
                                currentUsername, 
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4.0),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: currentRole == 'GV' 
                                      ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                      : Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  currentRole == 'GV' ? "Giáo viên" : "Học viên",
                                  style: TextStyle(
                                    color: currentRole == 'GV' ? AppColors.primaryBlue : Colors.orange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.settings, color: Colors.black87),
                      title: const Text('Cài đặt thông báo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.block, color: Colors.black87),
                      title: const Text('Danh sách chặn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const BlockedUsersScreen()));
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: Colors.black87),
                      title: const Text('Đổi mật khẩu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                      },
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),

            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end, // Đẩy nút xuống cuối màn hình
                  children: [
                    InkWell(
                      onTap: () {
                        // KÍCH HOẠT HÀM LOGOUT TRONG CUBIT
                        context.read<AuthCubit>().logout();
                      },
                      borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        // Copy định dạng nút "Xem thêm" (Màu xám nhạt đục)
                        decoration: BoxDecoration(
                          color: const Color(0xffe4e6eb).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Center(
                          child: Text(
                            'Đăng xuất',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
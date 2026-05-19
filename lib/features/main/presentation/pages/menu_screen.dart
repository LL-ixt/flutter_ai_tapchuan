import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../../features/auth/presentation/pages/login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Giả lập dữ liệu user nhận được sau khi Login thành công
  // Khi kết nối BLoC/Cubit, bạn sẽ thay thế các giá trị này bằng state.user
  final String _username = "Nguyễn Tiến Thành";
  final String _role = "GV"; // 'HS' hoặc 'GV'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // 2. Phần hiển thị thông tin User (Avatar - Tên - Vai trò)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Dùng lại widget Avatar có sẵn trong project của bạn
                  const AvatarWidget(
                    imageUrl: 'https://i.pravatar.cc/150?img=3', // Ảnh đại diện mẫu
                    radius: 30, // Kích thước avatar vừa phải
                  ),
                  const SizedBox(width: 16.0),
                  
                  // Thông tin Tên và Vai trò
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, 
                            vertical: 4
                          ),
                          decoration: BoxDecoration(
                            color: _role == 'GV' 
                                ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _role == 'GV' ? "Giáo viên" : "Học viên",
                            style: TextStyle(
                              color: _role == 'GV' 
                                  ? AppColors.primaryBlue 
                                  : Colors.orange,
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
          ),

          // 3. Nút Đăng xuất copy định dạng nút "Xem thêm" từ ảnh thiết kế
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Đẩy nút xuống cuối màn hình
                children: [
                  InkWell(
                    onTap: () => _handleLogout(context),
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      // Copy định dạng nút "Xem thêm" (Màu xám nhạt đục)
                      decoration: BoxDecoration(
                        color: const Color(0xffe4e6eb), 
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
    );
  }

  // Hàm xử lý logic Đăng xuất an toàn xóa Stack
  void _handleLogout(BuildContext context) {
    // 1. TODO: Thực hiện xóa token offline tại đây (SharedPreferences)
    
    // 2. Điều hướng và clear toàn bộ các màn hình trước đó
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}
import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/input_box.dart';
import '../../../../core/widgets/submit_button.dart';
import '../../../../services/api_service.dart';
import 'login_screen.dart';
import '../../../../core/utils/dialog_utils.dart';

class ChangeInfoAfterSignupScreen extends StatefulWidget {
  final String token; // Nhận token từ màn hình Verify truyền sang

  const ChangeInfoAfterSignupScreen({super.key, required this.token});

  @override
  State<ChangeInfoAfterSignupScreen> createState() => _ChangeInfoAfterSignupScreenState();
}

class _ChangeInfoAfterSignupScreenState extends State<ChangeInfoAfterSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  bool _isSubmitting = false;

  void _handleSaveInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Gọi API cập nhật thông tin sau signup
      final result = await ApiService.changeInfoAfterSignup(
        widget.token,
        _nameController.text.trim(),
        avatar: null,
        height: _heightController.text.trim(),
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (result['code'] == '1000') {
        DialogUtils.showNotificationDialog(
          context: context,
          title: 'Thành công',
          message: 'Cập nhật hồ sơ thành công! Vui lòng đăng nhập.',
          isSuccess: true,
          onConfirm: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          },
        );
      } else {
        DialogUtils.showNotificationDialog(
          context: context,
          title: 'Cập nhật thất bại',
          message: 'Lỗi: ${result['message']}',
          isSuccess: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        automaticallyImplyLeading: false, // Không cho quay lại màn hình nhập OTP nữa
        title: const Text(
          "Thiết lập hồ sơ",
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Thêm chi tiết về bạn",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Nhập tên của bạn để bạn bè có thể nhận ra trên App.",
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Vùng hiển thị Avatar giả lập/Chọn ảnh
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 80, color: Colors.grey),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Ô nhập tên (Sử dụng lại widget InputBox của bạn)
                InputBox(
                  label: "Tên hiển thị",
                  hintText: "Nhập họ và tên của bạn",
                  controller: _nameController,
                ),
                const SizedBox(height: 30),

                InputBox(
                  label: "Chiều cao",
                  hintText: "Nhập chiều cao của bạn (cm)",
                  controller: _heightController,
                ),
                const SizedBox(height: 30),
                
                // Nút hoàn tất
                SubmitButton(
                  text: "Hoàn tất",
                  isLoading: _isSubmitting,
                  onPressed: _handleSaveInfo,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
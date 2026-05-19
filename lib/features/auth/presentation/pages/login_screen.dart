// This file is being moved to: c:\Users\User\Desktop\UD đa nền tảng\flutter_ai_tapchuan\lib\features\auth\presentation\pages\login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/pages/signup_screen.dart';
import 'package:flutter_ai_tapchuan/features/main/presentation/pages/main_screen.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
//import '../core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  //bool _isSubmitting = false;

  Future<void> _handleLogin() async {
    debugPrint("Bắt đầu xử lý đăng nhập..."); // Debug log
    if (_formKey.currentState!.validate()) {
      debugPrint("Đang gửi yêu cầu đăng nhập với số điện thoại: ${_phoneController.text}"); // Debug log
      //setState(() => _isSubmitting = true);

      final result = await ApiService.login(_phoneController.text, _passwordController.text);

      //setState(() => _isSubmitting = false); 
      if (!mounted) return;
      if (result['code'] == '1000') {
        String token = result['data']['token'];
        debugPrint("Token nhận được: $token"); // Debug token
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${result['message']}')),
        );
      }
    }
  }

  Future<void> _handleSignup() async {
    // Chuyển sang trang signup
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: LayoutBuilder( // Bắt đầu nhét từ đây
              builder: (context, constraints) {
                // Tính toán chiều rộng tối đa dựa trên công thức của bạn
                double screenWidth = constraints.maxWidth;
                double charWidth = 12.0; // Ước lượng chiều rộng trung bình 1 ký tự
                double targetWidth = 8 * charWidth * 10; // Giả sử 8 lần chiều rộng font (nhân thêm 10 để ra đơn vị px hợp lý)
                
                // Chiều rộng thực tế áp dụng (vẫn giữ khoảng cách lề)
                double finalWidth = targetWidth < screenWidth ? targetWidth : screenWidth;

                return Center(
                  child: SizedBox(
                    width: finalWidth, // Áp dụng chiều rộng min(12*w, screen_width)
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        // Logo hoặc Tên ứng dụng
                        const Icon(Icons.facebook, size: 80, color: AppColors.primaryBlue),
                        const SizedBox(height: 10),
                        Text("Chào mừng bạn quay lại", style: AppTextStyles.heading1),
                        const SizedBox(height: 40),

                        // Input Số điện thoại
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Số điện thoại',
                            filled: true,
                            fillColor: AppColors.scaffoldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập số điện thoại';
                            }
                            if (value.length < 10) {
                              return 'Số điện thoại không hợp lệ';
                            }
                            return null;
                          }, // Hãy mở lại để đúng yêu cầu [cite: 393, 458]
                        ),
                        const SizedBox(height: 15),

                        // Input Mật khẩu
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Mật khẩu',
                            filled: true,
                            fillColor: AppColors.scaffoldBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.primaryIconAction,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        // Nút Đăng nhập
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Đăng nhập",
                              style: AppTextStyles.buttonText.copyWith(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleSignup,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              // 1. Màu chữ mặc định là màu xanh của Facebook
                              foregroundColor: AppColors.primaryBlue, 
                              
                              // 2. Định dạng viền (Border) màu xanh dương, bo góc
                              side: const BorderSide(
                                color: AppColors.primaryBlue, 
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25), // Bo góc nhẹ theo hình
                              ),
                            ).copyWith(
                              // 3. Xử lý hiệu ứng đổi màu nền dựa trên trạng thái (State)
                              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                                if (states.contains(WidgetState.pressed)) {
                                  // Khi ấn vào: Nền chuyển thành màu xám nhạt như yêu cầu
                                  return const Color(0xffe4e6eb); 
                                }
                                // Trạng thái bình thường: Nền màu trắng tinh
                                return Colors.white; 
                              }),
                              
                              textStyle: WidgetStateProperty.all(
                                AppTextStyles.buttonText.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold, // Chữ đậm theo UI hình ảnh
                                ),
                              ),
                            ),
                            child: const Text("Tạo tài khoản mới"),
                          ),
                        ),

                        // ... Các phần còn lại (Quên mật khẩu, Tạo tài khoản, Thoát) giữ nguyên
                        // Hãy đảm bảo các phần này cũng nằm trong khối Column này
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

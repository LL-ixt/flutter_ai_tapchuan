import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/pages/signup_screen.dart';
import 'package:flutter_ai_tapchuan/features/main/presentation/pages/main_screen.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/utils/dialog_utils.dart';
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
      context.read<AuthCubit>().login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            // 3. BỌC LAYER LẮNG NGHE STATE BẰNG BLOCCONSUMER
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                // Lắng nghe khi đăng nhập thành công
                if (state.isSuccess) {
                  DialogUtils.showNotificationDialog(
                    context: context,
                    title: 'Đăng nhập thành công',
                    message: 'Chào mừng ${state.username} quay trở lại!',
                    isSuccess: true,
                    onConfirm: () {
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainScreen()),
                      );
                    },
                  );
                }
                
                // Lắng nghe khi có lỗi từ Server trả về (mã 9995, sai pass, mất mạng...)
                if (state.error != null) {
                  DialogUtils.showNotificationDialog(
                    context: context,
                    title: 'Đăng nhập thất bại',
                    message: state.error!,
                    isSuccess: false,
                  );
                }
              },
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo hoặc Tên ứng dụng
                      const Text(
                        'EduSocial AI',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.5,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Ô nhập số điện thoại
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Ô nhập mật khẩu
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // NÚT ĐĂNG NHẬP XỬ LÝ TRẠNG THÁI LOADING
                      state.isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Đăng nhập',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(height: 16),

                      // Nút Tạo tài khoản mới (Đã sửa định dạng viền xanh nền trắng)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignupScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            foregroundColor: AppColors.primaryBlue,
                            side: const BorderSide(
                              color: AppColors.primaryBlue,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ).copyWith(
                            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                              if (states.contains(WidgetState.pressed)) {
                                return const Color(0xffe4e6eb);
                              }
                              return Colors.white;
                            }),
                            textStyle: WidgetStateProperty.all(
                              AppTextStyles.buttonText.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          child: const Text("Tạo tài khoản mới"),
                        ),
                      ),
                    ],
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

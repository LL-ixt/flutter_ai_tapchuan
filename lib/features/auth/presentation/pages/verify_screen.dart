import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/pages/change_info_after_signup_screen.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/utils/dialog_utils.dart';
//import '../../../../core/constants/text_style_constants.dart';
//import '../../../../core/widgets/submit_button.dart';
import '../../../../services/api_service.dart';
//import 'login_screen.dart';

class VerifyScreen extends StatefulWidget {
  final String phoneNumber;

  const VerifyScreen({super.key, required this.phoneNumber});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  void _handleVerify() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Gọi API check_verify_code
      final result = await ApiService.checkVerifyCode(
        widget.phoneNumber,
        _codeController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (result['code'] == '1000') {
        String tokenAfterVerify = result['data']['token'];
        DialogUtils.showNotificationDialog(
          context: context,
          title: 'Thành công',
          message: 'Xác thực thành công! Vui lòng cập nhật hồ sơ.',
          isSuccess: true,
          onConfirm: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => ChangeInfoAfterSignupScreen(token: tokenAfterVerify)),
              (route) => false,
            );
          },
        );
      } else {
        DialogUtils.showNotificationDialog(
          context: context,
          title: 'Xác thực thất bại',
          message: 'Lỗi (${result['code']}): ${result['message']}',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Nhập mã xác thực",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mã xác thực đã được gửi đến số điện thoại ${widget.phoneNumber}. Vui lòng nhập mã để kích hoạt tài khoản.",
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Ô nhập mã Xác thực
                TextFormField(
                  controller: _codeController,
                  textAlign: TextAlign.center, // Căn giữa chữ cho giống dạng OTP
                  style: const TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 4
                  ),
                  decoration: InputDecoration(
                    hintText: "7VJ212",
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 18, letterSpacing: 0),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mã xác thực';
                    }
                    if (value.trim().length < 4) {
                      return 'Mã xác thực không hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Nút bấm xác nhận
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _handleVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            "Tiếp tục",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
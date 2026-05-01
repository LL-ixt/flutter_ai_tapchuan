import 'package:flutter/material.dart';
import '../core/constants/color_constants.dart';
import '../core/constants/text_style_constants.dart';
//import '../core/utils/validators.dart';
import '../core/widgets/input_box.dart';
import '../core/widgets/submit_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Các controller để lấy dữ liệu nhập vào
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  String _selectedRole = 'HS'; // Mặc định là Học sinh (HS) theo API Contract
  bool _isSubmitting = false;

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Giả lập thời gian chờ gọi API (theo yêu cầu phi chức năng)
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Gọi API /signup với payload: 
      // { "phonenumber": _phoneController.text, "password": _passwordController.text, "role": _selectedRole ... }
      
      setState(() => _isSubmitting = false);
      
      // Thông báo thành công và quay lại màn hình đăng nhập
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng kiểm tra mã xác thực.')),
        );
        Navigator.pop(context);
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
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text("Tạo tài khoản", style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text("Nhanh chóng và dễ dàng.", style: AppTextStyles.subtitle),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(color: AppColors.dividerBorder),
                ),

                // Sử dụng module InputBox mới
                InputBox(
                  label: "Họ và Tên",
                  hintText: "Họ và tên của bạn",
                  controller: _nameController,
                  //validator: AppValidators.validateName,
                ),

                InputBox(
                  label: "Số di động",
                  hintText: "Nhập số điện thoại (10 số)",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  //validator: AppValidators.validatePhone,
                ),

                InputBox(
                  label: "Mật khẩu mới",
                  hintText: "Mật khẩu (6-10 ký tự)",
                  controller: _passwordController,
                  obscureText: true,
                  //validator: AppValidators.validatePassword,
                ),

                // Phần chọn Vai trò (Role)
                Text(
                  "Bạn là:",
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                ),
                RoleRadioGroup(
                  selectedRole: _selectedRole,
                  onRoleChanged: (val) => setState(() => _selectedRole = val),
                ),

                const SizedBox(height: 30),

                // Sử dụng module SubmitButton mới
                SubmitButton(
                  text: "Gửi",
                  isLoading: _isSubmitting,
                  onPressed: _handleSignup,
                ),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Bạn đã có tài khoản?",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                      ),
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

class RoleRadioGroup extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleRadioGroup({
    required this.selectedRole,
    required this.onRoleChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Học viên"),
                value: 'HS',
                groupValue: selectedRole,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => onRoleChanged(val!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Giáo viên"),
                value: 'GV',
                groupValue: selectedRole,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => onRoleChanged(val!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
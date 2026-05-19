import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/pages/verify_screen.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
//import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/input_box.dart';
import '../../../../core/widgets/submit_button.dart';
import '../../../../services/api_service.dart';
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'HS';
  bool _isSubmitting = false;

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn loại người dùng (Học viên/Giáo viên)')),
        );
        return;
      }

      setState(() => _isSubmitting = true);
      
      // Gọi API Signup
      final result = await ApiService.signup(
        _phoneController.text, 
        _passwordController.text,
        _selectedRole,
      );

      setState(() => _isSubmitting = false);
      if (!mounted) return;

      if (result['code'] == '1000') {
        // TEST CASE 1: Đăng ký thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('1000 | OK: Đăng ký thành công!')),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => VerifyScreen(phoneNumber: _phoneController.text)),
          (route) => false,
        );
      } else if (result['code'] == '9996') {
        // TEST CASE 2: Số điện thoại đã tồn tại 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('9996 | User existed: Số điện thoại đã được đăng ký')),
        );
      } else {
        // Các lỗi khác từ server
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${result['message']}')),
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
                InputBox(
                  label: "Số di động",
                  hintText: "Nhập số điện thoại (10 số)",
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                InputBox(
                  label: "Mật khẩu mới",
                  hintText: "Mật khẩu (6-10 ký tự)",
                  controller: _passwordController,
                  obscureText: true,
                ),
                Text(
                  "Bạn là:",
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
                ),
                RoleRadioGroup(
                  selectedRole: _selectedRole,
                  onRoleChanged: (val) => setState(() => _selectedRole = val),
                ),
                const SizedBox(height: 30),
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
                value: 'HV',
                // ignore: deprecated_member_use
                groupValue: selectedRole,
                contentPadding: EdgeInsets.zero,
                // ignore: deprecated_member_use
                onChanged: (val) => onRoleChanged(val!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text("Giáo viên"),
                value: 'GV',
                // ignore: deprecated_member_use
                groupValue: selectedRole,
                contentPadding: EdgeInsets.zero,
                // ignore: deprecated_member_use
                onChanged: (val) => onRoleChanged(val!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

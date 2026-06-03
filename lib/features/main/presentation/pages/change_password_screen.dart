import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/input_box.dart';
import '../../../../core/widgets/submit_button.dart';
import '../../../../services/api_service.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final token = context.read<AuthCubit>().state.token ?? "";
      final currentPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      final result = await ApiService.changePassword(
        token,
        currentPassword,
        newPassword,
      );

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (result['code'] == '1000' || result['code'] == '200') {
        DialogUtils.showNotificationDialog(
          context: context,
          title: 'Thành công',
          message: 'Đổi mật khẩu thành công!',
          isSuccess: true,
          onConfirm: () {
            Navigator.pop(context);
          },
        );
      } else {
        DialogUtils.showNotificationDialog(
          context: context,
          title: 'Thất bại',
          message: result['message'] ?? 'Lỗi thay đổi mật khẩu',
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
        elevation: 0.5,
        title: const Text(
          "Đổi mật khẩu",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Tạo mật khẩu mới",
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Vui lòng nhập mật khẩu hiện tại và thiết lập mật khẩu mới của bạn.",
                  style: AppTextStyles.subtitle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Mật khẩu hiện tại
                InputBox(
                  label: "Mật khẩu hiện tại",
                  hintText: "Nhập mật khẩu hiện tại",
                  controller: _currentPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu hiện tại';
                    }
                    return null;
                  },
                ),
                
                // Mật khẩu mới
                InputBox(
                  label: "Mật khẩu mới",
                  hintText: "Nhập mật khẩu mới (tối thiểu 6 ký tự)",
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu mới phải có tối thiểu 6 ký tự';
                    }
                    if (value == _currentPasswordController.text) {
                      return 'Mật khẩu mới không được trùng mật khẩu cũ';
                    }
                    return null;
                  },
                ),
                
                // Xác nhận mật khẩu mới
                InputBox(
                  label: "Xác nhận mật khẩu mới",
                  hintText: "Nhập lại mật khẩu mới",
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu mới';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Xác nhận mật khẩu mới không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                
                // Nút Đổi mật khẩu
                SubmitButton(
                  text: "Lưu thay đổi",
                  isLoading: _isSubmitting,
                  onPressed: _handleChangePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

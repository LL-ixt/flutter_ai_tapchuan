import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/input_box.dart';
import '../../../../core/widgets/submit_button.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../services/api_service.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class TestUserInfoScreen extends StatefulWidget {
  const TestUserInfoScreen({super.key});

  @override
  State<TestUserInfoScreen> createState() => _TestUserInfoScreenState();
}

class _TestUserInfoScreenState extends State<TestUserInfoScreen> {
  final _userIdController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _userData;

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  void _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _userData = null;
    });

    final token = context.read<AuthCubit>().state.token ?? "";
    final targetId = _userIdController.text.trim();

    final result = await ApiService.getUserInfo(
      token: token,
      userId: targetId.isEmpty ? null : targetId,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['code'] == '1000' || result['code'] == '200') {
      setState(() {
        _userData = result['data'];
      });
    } else {
      DialogUtils.showNotificationDialog(
        context: context,
        title: 'Lỗi',
        message: result['message'] ?? 'Không lấy được thông tin người dùng',
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0.5,
        title: const Text(
          "Test Get User Info",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Nhập ID để tra cứu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Nhập user_id của đối phương để lấy thông tin. Bỏ trống nếu muốn lấy thông tin của chính mình.",
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputBox(
                      label: "User ID",
                      hintText: "Ví dụ: 64f1234567890abc",
                      controller: _userIdController,
                    ),
                    const SizedBox(height: 10),
                    SubmitButton(
                      text: "Tra cứu thông tin",
                      isLoading: _isLoading,
                      onPressed: _fetchUserInfo,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              if (_userData != null) ...[
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _userData!['avatar'] != null && _userData!['avatar'].toString().isNotEmpty
                                  ? NetworkImage(_userData!['avatar'].toString())
                                  : null,
                              child: _userData!['avatar'] == null || _userData!['avatar'].toString().isEmpty
                                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _userData!['username'] ?? "Không có tên",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _userData!['role'] == 'GV' 
                                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _userData!['role'] == 'GV' ? "Giáo viên" : "Học viên",
                                style: TextStyle(
                                  color: _userData!['role'] == 'GV' ? AppColors.primaryBlue : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.fingerprint, "User ID", _userData!['id']?.toString() ?? "N/A"),
                      _buildInfoRow(Icons.phone, "Số điện thoại", _userData!['phonenumber']?.toString() ?? "(Chỉ hiển thị khi tự xem mình)"),
                      _buildInfoRow(Icons.calendar_today, "Ngày tham gia", _userData!['created']?.toString() ?? "N/A"),
                      _buildInfoRow(Icons.people, "Mối quan hệ", _userData!['is_related']?.toString() ?? "N/A"),
                      _buildInfoRow(Icons.video_library, "Số video đã đăng", _userData!['listing']?.toString() ?? "0"),
                      _buildInfoRow(Icons.school, "Khóa học / Học viên", _userData!['followed']?.toString() ?? "0"),
                      _buildInfoRow(Icons.block, "Đã chặn", _userData!['is_blocked']?.toString() == '1' || _userData!['is_blocked'] == true ? "Có" : "Không"),
                      _buildInfoRow(
                        Icons.circle,
                        "Trạng thái hoạt động",
                        _userData!['online']?.toString() == '1' ? "Online" : "Offline",
                        valueColor: _userData!['online']?.toString() == '1' ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

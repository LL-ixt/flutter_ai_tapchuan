import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../services/api_service.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class SearchTeacherTab extends StatefulWidget {
  const SearchTeacherTab({super.key});

  @override
  State<SearchTeacherTab> createState() => _SearchTeacherTabState();
}

class _SearchTeacherTabState extends State<SearchTeacherTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _teacherInfo;
  String? _errorMessage;

  Future<void> _searchTeacher() async {
    final userId = _searchController.text.trim();
    if (userId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _teacherInfo = null;
    });

    final token = context.read<AuthCubit>().state.token ?? "";
    final response = await ApiService.getUserInfo(token: token, userId: userId);

    if (response['code'] == '1000' && response['data'] != null) {
      setState(() {
        _teacherInfo = response['data'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response['message'] ?? 'Không tìm thấy giáo viên.';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendRequest() async {
    final token = context.read<AuthCubit>().state.token ?? "";
    final teacherId = _teacherInfo?['id']?.toString() ?? _searchController.text.trim();
    
    // Sử dụng một ID khóa học mặc định vì API yêu cầu courseId
    final courseId = "1"; 

    final response = await ApiService.setRequestCourse(token, courseId, teacherId);

    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (response['code'] == '1000') {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Gửi yêu cầu học thành công!')),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Lỗi: ${response['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tìm giáo viên',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Nhập User ID giáo viên...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _searchTeacher,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
                child: const Text('Tìm', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null)
            Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          else if (_teacherInfo != null)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(_teacherInfo!['avatar'] ?? "https://i.pravatar.cc/150"),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _teacherInfo!['username'] ?? 'Không tên',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'User ID: ${_teacherInfo!['id']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _sendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Gửi yêu cầu', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

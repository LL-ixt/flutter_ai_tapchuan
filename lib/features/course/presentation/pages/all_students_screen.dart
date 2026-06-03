import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../services/api_service.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';

class AllStudentsScreen extends StatefulWidget {
  const AllStudentsScreen({super.key});

  @override
  State<AllStudentsScreen> createState() => _AllStudentsScreenState();
}

class _AllStudentsScreenState extends State<AllStudentsScreen> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final token = context.read<AuthCubit>().state.token ?? "mock_token";
    final response = await ApiService.getListStudents(token, 0, 50);

    if (response['code'] == '1000') {
      final List<dynamic> data = response['data'] ?? [];
      setState(() {
        students = data.map((e) => {
          "id": e['id']?.toString() ?? "",
          "name": e['username'] ?? "Không tên",
          "mutual": "0", // Backend có thể chưa hỗ trợ mutual
          "avatar": e['avatar'] ?? "https://i.pravatar.cc/150",
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        errorMsg = response['message'] ?? "Lỗi không xác định";
        isLoading = false;
      });
    }
  }

  // 2. Hàm xử lý Sắp xếp
  void _sortStudents(String criteria) {
    setState(() {
      if (criteria == 'name') {
        students.sort((a, b) => a['name'].compareTo(b['name'])); // Sắp xếp A-Z
      } else if (criteria == 'mutual') {
        students.sort((a, b) => b['mutual'].compareTo(a['mutual'])); // Nhiều bạn chung nhất
      } else {
        students.shuffle(); // Mặc định (Trộn ngẫu nhiên)
      }
    });
  }

  // 3. Hàm bật Menu Sắp xếp 3 kiểu
  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Sắp xếp theo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('Tên (A-Z)'),
              onTap: () { _sortStudents('name'); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Số bạn chung'),
              onTap: () { _sortStudents('mutual'); Navigator.pop(context); },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Mặc định'),
              onTap: () { _sortStudents('default'); Navigator.pop(context); },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
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
        title: const Text('Tất cả học viên', style: TextStyle(color: Colors.black, fontSize: 18)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Header: Tổng số và nút Sắp xếp
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${students.length} học viên', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: _showSortMenu,
                  child: const Text('Sắp xếp', style: TextStyle(color: AppColors.primaryBlue, fontSize: 16)),
                ),
              ],
            ),
          ),
          // Danh sách học viên
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMsg != null
                    ? Center(child: Text(errorMsg!, style: const TextStyle(color: Colors.red)))
                    : ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final item = students[index];
                          return ListTile(
                            leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(item['avatar'])),
                            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: item['mutual'] != "0" ? Text('${item['mutual']} bạn chung') : null,
                            trailing: const Icon(Icons.more_horiz),
                            onTap: () {},
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
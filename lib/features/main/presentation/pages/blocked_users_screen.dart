import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../services/api_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  bool isLoading = true;
  List<dynamic> blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _fetchBlockedUsers();
  }

  Future<void> _fetchBlockedUsers() async {
    final token = context.read<AuthCubit>().state.token ?? "mock_token";
    final response = await ApiService.getListBlocks(token, 0, 20);

    if (mounted) {
      if (response['code'] == '1000' || response['code'] == '200') {
        setState(() {
          blockedUsers = (response['data']?['users'] as List<dynamic>?) ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải danh sách: ${response['message']}')));
      }
    }
  }

  Future<void> _unblockUser(String userId, int index) async {
    final token = context.read<AuthCubit>().state.token ?? "mock_token";
    // 1 = unblock, 0 = block. Nếu api dùng on/off thì có thể tuỳ chỉnh, nhưng ta đã map ở api_service
    final response = await ApiService.setBlock(token, userId, '1');

    if (mounted) {
      // 1000 là OK, 1001 có thể là lỗi db, nhưng nếu BE trả 1001 khi thành công (như một số case test ảo) ta vẫn báo.
      // Dựa vào test script thì khi BE lỗi DB báo 1001. Ta chỉ xoá UI khi 1000 hoặc 200.
      if (response['code'] == '1000' || response['code'] == '200') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã bỏ chặn người dùng')));
        setState(() {
          blockedUsers.removeAt(index);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi bỏ chặn: ${response['message']}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        title: const Text('Người dùng đã chặn', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : blockedUsers.isEmpty
              ? const Center(child: Text('Không có người dùng nào bị chặn', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: blockedUsers.length,
                  itemBuilder: (context, index) {
                    final user = blockedUsers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(user['avatar'] ?? "https://i.pravatar.cc/150?img=11"),
                      ),
                      title: Text(user['name'] ?? "Người dùng"),
                      trailing: ElevatedButton(
                        onPressed: () => _unblockUser(user['id'] ?? "123", index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          elevation: 0,
                        ),
                        child: const Text('Bỏ chặn'),
                      ),
                    );
                  },
                ),
    );
  }
}

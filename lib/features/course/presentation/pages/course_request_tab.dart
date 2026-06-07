import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/all_students_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../services/api_service.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../search/search_page.dart';

class CourseRequestTab extends StatefulWidget {
  const CourseRequestTab({super.key});

  @override
  State<CourseRequestTab> createState() => _CourseRequestTabState();
}

class _CourseRequestTabState extends State<CourseRequestTab> {
  List<Map<String, dynamic>> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() {
      isLoading = true;
    });

    final token = context.read<AuthCubit>().state.token ?? "";
    final response = await ApiService.getRequestedEnrollment(token, 0, 20);

    if (response['code'] == '1000') {
      final Map<String, dynamic> responseData = response['data'] ?? {};
      final List<dynamic> data = responseData['data'] ?? [];
      
      setState(() {
        requests = data.map((e) {
          final requestObj = e['request'] ?? {};
          final id = requestObj['id']?.toString() ?? "";
          final name = requestObj['user_name'] ?? "Không tên";
          final avatar = requestObj['avatar']?.toString();
          
          return {
            "id": id,
            "name": name,
            "time": "Gần đây",
            "avatar": (avatar != null && avatar.trim().isNotEmpty) ? avatar : "https://i.pravatar.cc/150",
            "status": "pending",
            "isBlocked": false,
          };
        }).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Lỗi tải danh sách yêu cầu.')),
        );
      }
    }
  }

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Text(content, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Nút Hủy đóng popup
              child: const Text('Hủy', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                print("=== Confirm Dialog 'Đồng ý' button clicked ===");
                Navigator.pop(dialogContext); // Đóng popup trước
                onConfirm(); 
              },
              child: const Text('Đồng ý', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showBlockOptions(Map<String, dynamic> req, int index) {
    bool isBlocked = req['isBlocked'] ?? false;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(isBlocked ? Icons.lock_open : Icons.block, color: isBlocked ? Colors.green : Colors.red),
                title: Text(isBlocked ? 'Bỏ chặn ${req['name']}' : 'Chặn ${req['name']}'),
                onTap: () {
                  Navigator.pop(context);
                  _handleBlockAction(req['id'], isBlocked ? 'unblock' : 'block', index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleBlockAction(String userId, String type, int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final token = context.read<AuthCubit>().state.token ?? "";
    final result = await ApiService.setBlock(token, userId, type);
    
    // Giả sử mã 1000 là success
    if (result['code'] == '1000' || result['code'] == '200') {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Đã ${type == 'block' ? 'chặn' : 'bỏ chặn'} người dùng')));
      if (mounted) {
        setState(() {
          requests[index]['isBlocked'] = (type == 'block');
        });
      }
    } else {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Lỗi: ${result['message']}')));
    }
  }

  Future<void> _handleApprove(String userId, String isAccept, int index) async {
    print("=== _handleApprove started: userId=$userId, isAccept=$isAccept, index=$index ===");
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final token = context.read<AuthCubit>().state.token ?? "";
      print("=== _handleApprove token fetched: $token ===");
      
      final result = await ApiService.setApproveEnrollment(token, userId, isAccept);
      print("=== ApiService.setApproveEnrollment result: $result ===");

      if (result['code'] == '1000' || result['code'] == '200') {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text(isAccept == '1' ? 'Đã chấp nhận yêu cầu' : 'Đã từ chối yêu cầu')));
        if (mounted) {
          setState(() {
            if (isAccept == '1') {
              requests.removeAt(index);
            } else {
              requests[index]['status'] = 'removed';
            }
          });
        }
      } else {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Lỗi: ${result['message']}')));
      }
    } catch (e, stackTrace) {
      print("=== Error in _handleApprove: $e ===");
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    int pendingCount = requests.where((r) => r['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: _fetchRequests,
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Yêu cầu học', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                    Container(
                      decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
                        },
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllStudentsScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Tất cả học viên', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(thickness: 1, color: Colors.black12),
                ),
                Row(
                  children: [
                    const Text('Yêu cầu mới ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text('$pendingCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 16),
                ...requests.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> req = entry.value;
                  return _buildRequestItem(req, index);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestItem(Map<String, dynamic> req, int index) {
    if (req['status'] == 'removed') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: req['avatar'] != null && req['avatar'].toString().isNotEmpty
                  ? NetworkImage(req['avatar'].toString())
                  : null,
              onBackgroundImageError: req['avatar'] != null && req['avatar'].toString().isNotEmpty
                  ? (exception, stackTrace) {}
                  : null,
              child: const Icon(Icons.person, size: 40, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(req['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Đã gỡ lời mời', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
              IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              onPressed: () {
                _showBlockOptions(req, index);
              },
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: req['avatar'] != null && req['avatar'].toString().isNotEmpty
                ? NetworkImage(req['avatar'].toString())
                : null,
            onBackgroundImageError: req['avatar'] != null && req['avatar'].toString().isNotEmpty
                ? (exception, stackTrace) {}
                : null,
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(req['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(req['time'], style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showConfirmDialog(
                            'Chấp nhận yêu cầu',
                            'Bạn có đồng ý cho ${req['name']} tham gia khóa học không?',
                            () {
                              _handleApprove(req['id'], '1', index);
                            }
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, elevation: 0),
                        child: const Text('Chấp nhận', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _showConfirmDialog(
                            'Từ chối yêu cầu',
                            'Gỡ lời mời từ ${req['name']}?',
                            () {
                              _handleApprove(req['id'], '0', index);
                            }
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], elevation: 0),
                        child: const Text('Từ chối', style: TextStyle(color: Colors.black)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.grey),
                      onPressed: () {
                        _showBlockOptions(req, index);
                      },
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
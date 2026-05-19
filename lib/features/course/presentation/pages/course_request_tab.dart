import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/all_students_screen.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../search/search_page.dart';

class CourseRequestTab extends StatefulWidget {
  const CourseRequestTab({super.key});

  @override
  State<CourseRequestTab> createState() => _CourseRequestTabState();
}

class _CourseRequestTabState extends State<CourseRequestTab> {
  List<Map<String, dynamic>> requests = [
    {"id": "1", "name": "Nguyễn Chung Thủy", "time": "2 năm", "avatar": "https://i.pravatar.cc/150?img=11", "status": "pending"},
    {"id": "2", "name": "Thắng Xuân Vũ", "time": "2 năm", "avatar": "https://i.pravatar.cc/150?img=12", "status": "pending"},
  ];

  void _showConfirmDialog(String title, String content, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Text(content, style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Nút Hủy đóng popup
              child: const Text('Hủy', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng popup trước
                onConfirm(); 
              },
              child: const Text('Đồng ý', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đếm số lượng yêu cầu đang ở trạng thái pending
    int pendingCount = requests.where((r) => r['status'] == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () async {
          // Giả lập thời gian load API mất 1 giây
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            requests.removeWhere((req) => req['status'] == 'removed');
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Tiêu đề và Search
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

                // 2. Nút Tất cả học viên
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

                // 3. Header danh sách
                Row(
                  children: [
                    const Text('Lời mời kết bạn ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    Text('$pendingCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. In danh sách
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

  // Hàm vẽ từng dòng học viên
  Widget _buildRequestItem(Map<String, dynamic> req, int index) {
    // NẾU ĐÃ GỠ: Hiển thị giao diện rút gọn "Đã gỡ lời mời"
    if (req['status'] == 'removed') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          children: [
            CircleAvatar(radius: 40, backgroundImage: NetworkImage(req['avatar'])),
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
                // TODO: Bật popup tùy chọn "Chặn" ở đây
              },
            ),
          ],
        ),
      );
    }

    // NẾU CHƯA GỠ (pending): Hiển thị giao diện đầy đủ 2 nút
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 40, backgroundImage: NetworkImage(req['avatar'])),
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
                              setState(() {
                                requests.removeAt(index);
                              });
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
                            'Xóa yêu cầu',
                            'Gỡ lời mời từ ${req['name']}?',
                            () {
                              setState(() {
                                requests[index]['status'] = 'removed';
                              });
                            }
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], elevation: 0),
                        child: const Text('Xóa', style: TextStyle(color: Colors.black)),
                      ),
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
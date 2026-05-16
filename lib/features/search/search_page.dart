import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Biến điều khiển thanh nhập văn bản
  final TextEditingController _searchController = TextEditingController();
  
 
  String _searchQuery = ''; 
  
  // Dữ liệu giả cho danh sách "Tìm kiếm gần đây"
  List<String> recentSearches = ['diễu binh 2/9', 'động tác nghiêm', 'hồ thiên nga'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Tạo đường viền mờ dưới thanh AppBar
        // 1. Thêm nút mũi tên quay lại ở góc trái
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true, 
          onChanged: (value) {
            setState(() {
              _searchQuery = value; 
            });
          },
          onSubmitted: (value) {
            if (value.trim().isNotEmpty && !recentSearches.contains(value.trim())) {
              setState(() {
                recentSearches.insert(0, value.trim()); 
              });
            }
          },
          // 3. Đổi giao diện ô nhập liệu (thêm icon kính lúp)
          decoration: InputDecoration(
            hintText: 'Tìm kiếm trên EduSocial...',
            border: InputBorder.none, 
            prefixIcon: const Icon(Icons.search, color: Colors.grey), 
            suffixIcon: _searchQuery.isNotEmpty 
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                : null, 
          ),
        ),
      ),
      body: _searchQuery.isEmpty ? _buildRecentSearches() : _buildSearchResults(),
    );
  }

  // GIAO DIỆN 1: MÀN HÌNH LỊCH SỬ TÌM KIẾM
  Widget _buildRecentSearches() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tìm kiếm gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                TextButton(
                  onPressed: () {
                  }, 
                  child: const Text('CHỈNH SỬA', style: TextStyle(color: Colors.blue))
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.search, color: Colors.grey),
                title: Text(recentSearches[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                  onPressed: () {
                    // Tính năng xóa 1 mục tìm kiếm
                    setState(() {
                      recentSearches.removeAt(index); 
                    });
                  },
                ),
                onTap: () {
                  setState(() {
                    _searchController.text = recentSearches[index];
                    _searchQuery = recentSearches[index];
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // GIAO DIỆN 2: MÀN HÌNH KẾT QUẢ (CHỈ CÓ BÀI VIẾT)
  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: 5, // Tạm thời để hiện 5 kết quả giả
      itemBuilder: (context, index) {
        return Card(
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.grey[300], 
                      child: const Icon(Icons.person, color: Colors.white)
                    ),
                    const SizedBox(width: 10),
                    Text('Tác giả bài viết ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Nội dung bài viết mẫu. Trong bài này có chứa từ khóa "$_searchQuery" mà bạn vừa tìm kiếm...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
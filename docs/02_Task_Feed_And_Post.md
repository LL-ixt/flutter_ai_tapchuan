# TASK 02: TRANG CHỦ, ĐĂNG BÀI 2 VIDEO & TƯƠNG TÁC BÀI VIẾT

## 1. Objective
Xây dựng Newsfeed (Trang chủ) hiển thị danh sách bài viết. Đặc biệt chú trọng UI ghép 2 video và BottomSheet bình luận.

## 2. Screens & Widgets to Implement
### 2.1. Home Screen (`home_screen.dart`)
- **UI Elements:** 
  - SliverAppBar chứa Text Logo và Icon (Search, Messenger).
  - Khung "Bạn đang nghĩ gì?" để trigger mở màn hình Tạo bài.
  - ListView.builder hoặc SliverList hiển thị danh sách `PostCard`.
  - Hỗ trợ `RefreshIndicator` (Pull down to refresh).

### 2.2. Khối Bài Viết (`post_card.dart` - Reusable Widget)
- **Header:** Avatar, Tên, Thời gian, Icon `...` (Mở BottomSheet Sửa/Xóa/Báo cáo).
- **Body:** Text mô tả (Giới hạn 3 dòng, có nút "Xem thêm").
- **Media (Quan trọng):** UI hiển thị **2 Video cạnh nhau** (Chia đôi màn hình trái-phải). Giả lập bằng 2 `Container` chứa ảnh Thumbnail và Icon Play ở giữa.
- **Footer:** Số lượng Like, Comment. Nút bấm Thích, Bình luận, Nộp bài. 
- **Action:** Nút Thích bấm vào chuyển màu xanh `#1877F2`.

### 2.3. Tạo Bài Viết (`create_post_screen.dart`)
- **UI Elements:** Text input đa dòng, 2 Button "Chọn Video Trái" và "Chọn Video Phải". Nút "Đăng" ở AppBar.

### 2.4. Tương tác Bài viết (Comments & Options)
- **Comment BottomSheet:** Bấm "Bình luận" từ PostCard trượt lên BottomSheet chứa danh sách bình luận (có giao diện cmt của Hệ thống AI chấm điểm). Có TextField nhập cmt gắn dưới đáy (kèm bàn phím).
- **Options BottomSheet:** Hiện menu "Chỉnh sửa bài viết", "Xóa bài viết", "Báo cáo bài viết".

## 3. Testing Requirements (`feed_widget_test.dart`)
- Render danh sách 5 bài viết bằng Mock Data.
- Test thao tác cuộn (Scroll).
- Test nhấn nút Like -> Icon ngón tay cái chuyển sang màu `#1877F2`.
- Test nhấn nút `...` -> BottomSheet xuất hiện.
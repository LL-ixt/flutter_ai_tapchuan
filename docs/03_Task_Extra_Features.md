# TASK 03: TÌM KIẾM, TAB KHÓA HỌC, THÔNG BÁO VÀ TRANG CÁ NHÂN

## 1. Objective
Hoàn thiện giao diện các Tab còn lại trên BottomNavigationBar (Tìm kiếm, Khóa học, Thông báo, Người dùng).

## 2. Screens to Implement
### 2.1. Search Screen (`search_screen.dart`)
- **UI Elements:** 
  - SearchBar trên cùng (Tự động focus bật bàn phím).
  - Danh sách "Tìm kiếm gần đây" (Recent Searches) với icon Kính lúp và nút 'X' để xóa từng mục.
- **Behavior:** Gõ text -> Nhấn Enter -> Hiển thị ListView kết quả (Sử dụng lại `PostCard` hoặc User ListTile).

### 2.2. Course Tab (`course_tab.dart`)
- **UI Elements:** 
  - `DefaultTabController` với 2 Tab: "Khóa đã đăng ký" (Học viên) và "Toàn bộ khóa học" / "Danh sách học viên" (Giáo viên).
  - Giao diện dạng ListTile: Avatar Khóa học/Học viên, Tên, Trạng thái (Đang chờ duyệt, Đã tham gia), Nút Action (Chấp nhận/Hủy).

### 2.3. Notification Tab (`notification_tab.dart`)
- **UI Elements:** 
  - Danh sách thông báo. Background `#E7F3FF` cho thông báo chưa đọc, `#FFFFFF` cho thông báo đã đọc.
  - Avatar người tương tác có gắn badge icon nhỏ ở góc phải dưới (Ví dụ: icon Like màu xanh, icon Comment màu xanh lá).

### 2.4. User Profile Screen (`profile_screen.dart`)
- **UI Elements:** 
  - Cover Photo (Ảnh bìa).
  - Avatar tròn nằm đè lên ranh giới ảnh bìa.
  - Tên người dùng (H1, Đậm).
  - Phần "Giới thiệu" (Mô tả, Nơi sống, Link).
  - Nút "Chỉnh sửa trang cá nhân".
  - Bên dưới hiển thị lại danh sách `PostCard` (chỉ bài viết của người này).

## 3. Testing Requirements (`features_widget_test.dart`)
- Test Search: Nhập chữ vào ô tìm kiếm -> Nhấn nút 'X' xoá text.
- Test Course Tab: Swipe trái phải để chuyển giữa 2 tab.
- Test Notification: Ensure the background color logic works correctly for read/unread mock models.
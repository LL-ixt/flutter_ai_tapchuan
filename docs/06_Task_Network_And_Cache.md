# TASK 06: THIẾT LẬP NETWORK, TOKEN & LOCAL CACHE

## 1. Objective
Xây dựng lớp giao tiếp API (Dio Interceptor), quản lý Token an toàn và cơ chế Caching ngoại tuyến.

## 2. Yêu cầu triển khai
- **Quản lý Token:** Sử dụng `flutter_secure_storage` để lưu Token. Viết logic: Khi Token hết hạn (Mã lỗi 9993/9998), tự động xóa Cache, xóa Token và đá user về màn hình Login.
- **Dio Interceptor:** 
  + Tự động đính kèm `Authorization: Bearer {token}` vào mọi request (trừ Login/Signup).
  + Tự động thêm trường `uuid` (Device ID) vào body của mọi request.
- **Local Cache (Offline Mode):**
  + Cài đặt `Hive` hoặc `Isar` database.
  + Viết hàm lưu trữ (save) và truy xuất (get) danh sách Bài viết (Feed) và Lịch sử tìm kiếm.
  + Khi gọi API `get_list_posts` thất bại do mạng, tự động fetch data từ Local Cache lên UI.
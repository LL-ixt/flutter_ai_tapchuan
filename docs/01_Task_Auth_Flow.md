# TASK 01: XÂY DỰNG LUỒNG ĐĂNG KÝ VÀ ĐĂNG NHẬP

## 1. Objective
Tạo giao diện Đăng ký và Đăng nhập mang phong cách Facebook, chạy mượt mà trên Android.

## 2. Screens to Implement
### 2.1. Login Screen (`login_screen.dart`)
- **UI Elements:** 
  - Logo ứng dụng (Text "MERCARI" hoặc Icon vuông vức).
  - TextField nhập "Số điện thoại" (Chỉ cho phép nhập số).
  - TextField nhập "Mật khẩu" (Có icon con mắt để ẩn/hiện mật khẩu).
  - Button "Đăng nhập" (Primary Color `#1877F2`, width 100%).
  - TextButton "Quên mật khẩu?".
  - Button outline "Tạo tài khoản mới" (Màu xanh lá `#42B72A` ở dưới cùng).
- **Behavior:** Bấm Đăng nhập -> Hiện CircularProgressIndicator 2s -> Chuyển sang Home.

### 2.2. Signup Screen (`signup_screen.dart`)
- **UI Elements:**
  - TextField Số điện thoại, Mật khẩu.
  - Dropdown hoặc Radio Button chọn Role: "Giáo viên" hoặc "Học viên".
  - Button "Đăng ký".
- **Validation (Client-side):** 
  - SĐT phải bắt đầu bằng '0' và đủ 10 số. Hiển thị Text Error màu đỏ `#FA383E` nếu sai.

## 3. Testing Requirements (`auth_widget_test.dart`)
- Viết Widget Test kiểm tra việc nhập sai SĐT sẽ hiển thị dòng chữ "Số điện thoại không hợp lệ".
- Viết test bấm vào nút "Tạo tài khoản mới" trên màn Login để đảm bảo trigger sự kiện chuyển trang.
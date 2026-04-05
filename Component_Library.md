# 🎨 Thư viện Component & UI/UX Guidelines (Design System)

Tài liệu này quy định hệ thống thiết kế (Design System) cho dự án mạng xã hội học tập. Mục tiêu là tạo ra trải nghiệm người dùng (UX) và giao diện (UI) gần gũi, quen thuộc nhất với thói quen sử dụng **Facebook**, giúp người dùng không mất thời gian làm quen.

---

## 1. Bảng màu (Color Palette)

Hệ thống sử dụng các mã màu chuẩn xác được trích xuất từ bộ UI của Facebook, đảm bảo sự tương phản và phân cấp thị giác rõ ràng. Cần khai báo các mã màu này vào `color_constants.dart` trong Flutter.

### 🔵 Brand Colors (Màu chủ đạo)
* **Primary Blue:** `#1877F2` (Màu xanh đặc trưng FB - Dùng cho AppBar, Nút bấm chính, Icon đang active, Text Link).
* **Secondary Blue (Light):** `#E7F3FF` (Màu xanh nhạt - Dùng cho background của nút bấm phụ, background của thông báo chưa đọc).
* **Primary Icon/Action:** `#65676B` (Xám đậm - Dùng cho các nút Like, Comment, Share khi chưa active, Icon trên thanh menu).

### ⚪ Background Colors (Màu nền)
* **Scaffold Background:** `#F0F2F5` (Xám nhạt - Màu nền phía sau cùng của ứng dụng, giúp nổi bật các Post Card).
* **Surface/Card White:** `#FFFFFF` (Trắng tinh - Dùng làm nền cho Post Card, Comment, Panel).
* **Divider/Border:** `#CED0D4` (Xám viền - Dùng cho các đường kẻ ngang phân cách bài viết hoặc comment).

### 🟢/🔴 Semantic Colors (Màu trạng thái)
* **Success Green:** `#42B72A` (Xanh lá - Dùng cho nút Tạo tài khoản mới, Dấu chấm Online hoạt động).
* **Error Red:** `#FA383E` (Đỏ - Dùng cho thông báo lỗi, text cảnh báo nhập sai mật khẩu/SĐT, Icon Xóa).
* **Warning Yellow:** `#F5C33B` (Vàng - Dùng cho các trạng thái chờ duyệt hoặc icon cảnh báo).

### ⚫ Text Colors (Màu chữ)
* **Text Primary:** `#050505` (Đen gần tuyệt đối - Dùng cho Text nội dung bài viết, Tên người dùng).
* **Text Secondary:** `#65676B` (Xám - Dùng cho thời gian đăng bài, text phụ, placeholder text).
* **Text Disabled:** `#BCC0C4` (Xám nhạt - Dùng cho text của nút bấm khi bị vô hiệu hóa).

---

## 2. Typography (Kiểu chữ)

Theo đặc tả hệ thống, toàn bộ ứng dụng sử dụng Font chữ **Roboto**. Khai báo bộ `TextTheme` trong Flutter theo tỷ lệ sau:

* **Heading 1 (H1):** `24px | Bold (w700) | Tên App, Tiêu đề màn hình lớn`
* **Heading 2 (H2):** `20px | Bold (w700) | Tiêu đề Section (Vd: "Bình luận", "Thông báo")`
* **Subtitle 1:** `16px | Semi-Bold (w600) | Tên người dùng trên bài viết (User Name)`
* **Subtitle 2:** `14px | Medium (w500) | Tên người dùng ở danh sách bình luận, Nút bấm`
* **Body 1 (Main Text):** `15px | Regular (w400) | Nội dung mô tả bài viết (Described)`
* **Body 2 (Secondary):** `13px | Regular (w400) | Thời gian đăng bài (Vừa xong, 2 giờ trước), Text phụ`
* **Caption:** `12px | Regular (w400) | Số lượng like/comment nhỏ, huy hiệu (badge)`

---

## 3. Common Widgets (Các Component dùng chung)

Để tối ưu hóa hiệu suất và thời gian code, các Developer cần xây dựng thư mục `lib/core/widgets/` chứa các UI Component tái sử dụng sau:

### 3.1. `AvatarWidget`
* **Mô tả:** Hình đại diện bo tròn (CircleAvatar).
* **Biến thể:** 
  * Kích thước: Small (32x32), Medium (40x40 - *Dùng ở Post*), Large (120x120 - *Trang cá nhân*).
  * Trạng thái Online: Tích hợp chấm tròn màu xanh lá (`#42B72A`) ở góc dưới bên phải (có viền trắng).
* **Fallback:** Nếu lỗi tải ảnh, hiển thị icon user xám mặc định.

### 3.2. `PostCard` (Khối Bài Viết)
Đây là Widget phức tạp nhất, được cấu thành từ các thành phần con:
* **`PostHeader`:** Chứa `AvatarWidget`, Tên người dùng, Thời gian đăng (`13px`, màu `#65676B`), Icon Privacy (Công khai), và Nút `...` (Tùy chọn).
* **`PostBody`:** Hiển thị Text (Giới hạn dòng, có nút "Xem thêm..."), xử lý Hashtag (chữ màu `#1877F2`, có thể bấm được).
* **`PostMedia`:** Trình phát Video (hiển thị 2 video nộp bài ghép lại hoặc ảnh thumbnail).
* **`PostStats`:** Thanh đếm số lượng (Ví dụ: 👍 150 • 32 Bình luận).
* **`PostActions`:** 3 nút trải ngang: `LikeButton` (Thích), `CommentButton` (Bình luận), và Nút `SubmitAction` (Nộp bài/Chia sẻ).

### 3.3. `LikeButton`
* **Trạng thái Mặc định:** Text "Thích" màu `#65676B`, Icon ngón tay cái viền xám.
* **Trạng thái Active:** Text "Thích" màu `#1877F2`, Icon ngón tay cái fill xanh.
* **Animation:** Có hiệu ứng nảy (Bouncing scale) nhẹ khi user bấm vào (bắt chước Facebook).

### 3.4. `CommentInput`
* **Mô tả:** Khung nhập text đa dòng dưới đáy màn hình bình luận.
* **UI:** Textfield bo góc tròn mạnh (bán kính `20px`), background xám nhạt (`#F0F2F5`). Không có viền.
* **Icon kèm theo:** Cạnh khung chat có icon Camera, Emoticon, và icon Mũi tên Gửi (màu `#1877F2`).

### 3.5. `CustomVideoPlayer`
* **Mô tả:** Trình phát video tuỳ chỉnh dùng `video_player` kết hợp `chewie` (hoặc `better_player`).
* **Tính năng:** Nút Play/Pause ở chính giữa, thanh tiến trình mỏng ở dưới cùng, hỗ trợ phát 2 video đồng thời (chia đôi màn hình) đối với bài tập của HV và bài mẫu của GV.

### 3.6. `NotificationItem`
* **Mô tả:** Thẻ hiển thị 1 dòng thông báo.
* **Trạng thái Chưa đọc:** Background màu `#E7F3FF`.
* **Trạng thái Đã đọc:** Background màu `#FFFFFF`.
* **UI:** Bao gồm `AvatarWidget`, RichText (Tên in đậm + Hành động in thường), Thời gian (`Body 2`), Icon menu `...` ở góc phải.

### 3.7. `SkeletonLoader` (Shimmer Effect)
* **Mô tả:** Khối xám nhạt chạy hiệu ứng lấp lánh từ trái sang phải.
* **Sử dụng:** Thay thế cho màn hình loading (vòng tròn xoay). Dùng khi đang fetch API `get_list_posts` hoặc `get_comment` để tạo cảm giác ứng dụng load siêu nhanh dù không có mạng.

### 3.8. `SocialAppBar`
* **Mô tả:** Thanh điều hướng trên cùng (SliverAppBar).
* **UI:** Chữ "MERCARI" hoặc Tên App màu Primary Blue (`#1877F2`) nằm bên trái. Bên phải là các nút tròn xám chứa Icon `Search` và `Messenger`.
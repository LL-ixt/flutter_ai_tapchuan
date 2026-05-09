# TASK 04: LUỒNG NHẮN TIN (MESSENGER CLONE)

## 1. Objective
Xây dựng giao diện Chat mô phỏng Facebook Messenger. Sử dụng Mock Data tĩnh để giả lập luồng gửi/nhận tin nhắn.

## 2. Screens to Implement
### 2.1. Danh sách Hội thoại (`inbox_screen.dart`)
- **UI Elements:**
  - AppBar có chữ "Chat", ô tìm kiếm, icon tạo tin nhắn mới.
  - ListView hiển thị các đoạn chat: Avatar, Tên, Tin nhắn cuối, Thời gian (Vd: "• 10:20").
  - Tin nhắn chưa đọc có text in đậm (Bold) và chấm xanh.

### 2.2. Khung Chat (`chat_room_screen.dart`)
- **UI Elements:**
  - AppBar hiển thị Avatar và Tên người đang chat, kèm icon (i) để mở tùy chọn.
  - Khung ListView hiển thị tin nhắn (Chat Bubbles). 
    - Tin của mình: Bubble màu `#1877F2`, chữ trắng, nằm bên phải.
    - Tin người khác: Bubble màu `#F0F2F5`, chữ đen, nằm bên trái kèm Avatar.
  - Ô nhập text dưới đáy màn hình (Icon Camera, Ảnh, TextField, Nút Gửi màu xanh).
- **Behavior:** Gõ text và bấm gửi -> Add 1 chat bubble mới vào ListView (giả lập realtime). Nhấn giữ tin nhắn của mình hiện popup "Thu hồi".

## 3. Testing Requirements (`chat_widget_test.dart`)
- Render Inbox với 3 đoạn chat (1 chưa đọc, 2 đã đọc).
- Test UI: Nhập text vào TextField và bấm Gửi, kiểm tra xem tin nhắn mới có xuất hiện trên màn hình không.
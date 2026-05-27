# API Specification: report_post

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện việc báo cáo (report) một bài viết của một tài khoản người dùng khi phát hiện nội dung không phù hợp hoặc vi phạm tiêu chuẩn.
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/report_post`

---

## 2. Logic nghiệp vụ (Business Logic)
- Khi một người dùng gửi báo cáo thành công, hệ thống sẽ tiếp nhận thông tin và đưa bài viết vào danh sách chờ ban quản trị xem xét.
- Các tham số phân loại chủ đề (`subject`) và chi tiết báo cáo (`details`) giúp phân loại nội dung vi phạm một cách chính xác hơn trên hệ thống quản trị.

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `application/json` hoặc `application/x-www-form-urlencoded`.

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng thực hiện báo cáo (truyền trong Body Request) |
| 2 | `id` | string | O (Optional) | ID của bài viết bị báo cáo |
| 3 | `subject` | string | O (Optional) | Phân loại chủ đề/nguyên nhân báo cáo (ví dụ: Spam, Quấy rối, Phản cảm, bạo lực...) |
| 4 | `details` | string | O (Optional) | Nội dung chi tiết giải thích thêm về lý do báo cáo |

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `code` | string | O | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | O | Thông điệp phản hồi từ hệ thống |

### Ví dụ Response thành công (Success JSON):
```json
{
  "code": "1000",
  "message": "OK"
}
```

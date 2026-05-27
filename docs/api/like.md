# API Specification: like

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện hành động thích (like) hoặc bỏ thích (unlike) một bài viết của một người dùng.
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/like`

## 2. Logic nghiệp vụ đặc thù (Business Logic Details)
- **Cơ chế Toggle (Bật/Tắt)**: API này xử lý đồng thời cả hai hành động:
  - Nếu người dùng **chưa thích** -> Bấm nút sẽ là **Thích** (tăng lượt thích thêm 1).
  - Nếu người dùng **đã thích** -> Bấm nút sẽ là **Bỏ thích** (giảm lượt thích đi 1).
- **Trải nghiệm người dùng (Optimistic UI)**: Khi người dùng bấm nút thích, ứng dụng nên cập nhật giao diện ngay lập tức (đổi màu nút và tăng/giảm số lượng ảo tạm thời) để tạo cảm giác mượt mà, sau đó đồng bộ số lượng thích chính xác từ trường `data.like` do API trả về.

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `application/json` hoặc `application/x-www-form-urlencoded`.

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng (truyền trong Body Request) |
| 2 | `id` | string | O (Optional) | ID của bài viết thực hiện thích/bỏ thích |

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `code` | string | O | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | O | Thông điệp phản hồi từ hệ thống |
| 3 | `data` | object | O | Đối tượng chứa dữ liệu kết quả |
| | `└── like` | string | O | Tổng số lượt thích hiện tại của bài viết sau khi xử lý |

### Ví dụ Response thành công (Success JSON):
```json
{
  "code": "1000",
  "message": "OK",
  "data": {
    "like": "15"
  }
}
```
## 5. Kịch bản kiểm thử chi tiết (Test Cases Specifications)

### TC-01: Thích hoặc Bỏ thích thành công (Luồng chuẩn)
- **Mô tả**: Người dùng truyền đúng phiên đăng nhập và ID bài viết đang hoạt động bình thường.
- **Dữ liệu đầu vào (Input)**:
  - `token`, `id`: Hợp lệ và còn hiệu lực.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã `1000` (OK) và số lượt thích mới trong `data.like`.
  - **Phía Client**: Cập nhật trạng thái tương tác trên UI (thay đổi màu sắc nút like sang Active/Inactive và hiển thị số lượng thích mới một cách chính xác).

### TC-02: Sai phiên đăng nhập / Token hết hạn
- **Mô tả**: Người dùng gửi yêu cầu với mã phiên đăng nhập trống, quá ngắn hoặc đã hết hiệu lực.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Trống, quá ngắn hoặc là mã cũ.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng tự động điều hướng người dùng sang **Màn hình đăng nhập**.

### TC-03: Bài viết bị khóa ngay trước khi thực hiện tương tác
- **Mô tả**: Bài viết bị hệ thống khóa đột ngột do vi phạm tiêu chuẩn hoặc bị hạn chế ngay trong lúc người dùng đang chuẩn bị nhấn Like (ở giao diện trước đó bài viết vẫn hiển thị bình thường).
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `id`: ID bài viết vừa bị khóa.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã lỗi `1010`.
  - **Phía Client**: 
    - Bài viết phải biến mất ngay lập tức khỏi giao diện hiện tại.
    - Nếu ở **Trang chủ**: Xóa bài viết khỏi danh sách hiển thị trên UI.
    - Nếu ở **Trang cá nhân**: Xóa bài viết khỏi danh sách hiển thị hoặc tiến hành tải lại (reload) trang cá nhân.

### TC-04: Tài khoản người nhấn thích bị khóa bởi hệ thống
- **Mô tả**: Tài khoản của người thực hiện hành động thích đã bị hệ thống khóa đột ngột.
- **Dữ liệu đầu vào (Input)**:
  - `token` của tài khoản đã bị khóa.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng tự động điều hướng người dùng sang **Màn hình đăng nhập**.

### TC-05: Lỗi kết nối Cơ sở dữ liệu phía Server (Database Error)
- **Mô tả**: Server gặp lỗi Database đột ngột dẫn đến việc không thể ghi nhận trạng thái thích bài viết.
- **Dữ liệu đầu vào (Input)**:
  - Request gửi đi đúng quy định nhưng server trả về lỗi Database.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng nhận mã lỗi từ server.
  - **Yêu cầu xử lý UI**: Không hiển thị trực tiếp mã lỗi kỹ thuật thô. Thay vào đó, hiển thị thông báo lỗi thân thiện như: `"Không thể kết nối Internet"` hoặc *"Đã có lỗi xảy ra, vui lòng thử lại sau"*.

### TC-06: Bài viết không tồn tại hoặc sai ID bài viết
- **Mô tả**: Người dùng gửi yêu cầu với một ID bài viết không có trên hệ thống.
- **Dữ liệu đầu vào (Input)**:
  - `id`: Không tồn tại trên hệ thống.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã lỗi `9992`.
  - Ứng dụng nhận dạng lỗi bài viết không tồn tại và hiển thị thông báo: `"Bài viết không tồn tại"`.

### TC-07: Mất kết nối mạng trong quá trình thực hiện tương tác (Network Error)
- **Mô tả**: Thiết bị bị mất mạng đột ngột ngay khi gửi request Thích/Bỏ thích.
- **Dữ liệu đầu vào (Input)**:
  - Thiết bị mất Wi-Fi/4G khi đang gửi request.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng kiểm tra trạng thái mạng tại Client.
  - Hiển thị thông báo lỗi rõ ràng và nhanh nhất có thể: `"Không thể kết nối Internet"`.

### TC-08: Server phản hồi số lượng thích bị lỗi (Giá trị âm hoặc quá lớn đột biến)
- **Mô tả**: Server gặp lỗi logic và trả về trường `data.like` là giá trị âm hoặc con số quá lớn hàng tỉ không chính xác.
- **Dữ liệu đầu vào (Input)**:
  - Thao tác gửi thành công nhưng nhận về giá trị `data.like` không hợp lệ.
- **Kết quả mong đợi (Expected Output)**:
  - **Phía Client**: Ứng dụng bắt lỗi giá trị bất thường này và tự động chuyển đổi giao diện hiển thị sang chuỗi ký tự thân thiện:
    - Nếu hành động vừa thực hiện là **Thích (Like)**: Hiển thị văn bản thay thế là `"Bạn thích bài viết"` hoặc `"Bạn và những người khác thích bài viết"` (thay vì hiển thị con số lỗi).
    - Nếu hành động vừa thực hiện là **Bỏ thích (Unlike)**: Hiển thị trạng thái chưa có ai thích bài viết hoặc ẩn phần đếm số lượng lượt thích đi.
```

# API Specification: delete_post

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện việc xóa một bài viết của một tài khoản người dùng (bao gồm cả Học viên và Giáo viên).
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/delete_post`

## 2. Ràng buộc Nghiệp vụ Quan trọng (Crucial Business Constraints)
- **Đối với bài viết của Học viên (HV)**: Người dùng có quyền xóa bài viết thoải mái bất kỳ lúc nào mà không bị ràng buộc.
- **Đối với bài viết của Giáo viên (GV)**: Chỉ cho phép xóa bài viết **nếu bài đăng đó chưa có bất kỳ Học viên nào nộp bài**.
  - *Lưu ý cho UI/UX*: Tương tự như tính năng sửa bài, nút "Xóa" trên giao diện của Giáo viên nên bị ẩn hoặc vô hiệu hóa nếu hệ thống phát hiện bài viết đã có lượt nộp bài từ học viên.

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `application/json` hoặc `application/x-www-form-urlencoded`.

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng (truyền trong Body Request) |
| 2 | `id` | string | O (Optional) | ID của bài viết cần thực hiện xóa |

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
## 5. Kịch bản kiểm thử chi tiết (Test Cases Specifications)

### TC-01: Xóa bài viết thành công (Luồng chuẩn)
- **Mô tả**: Người dùng truyền đúng phiên đăng nhập và ID bài viết thuộc quyền sở hữu (đáp ứng đủ điều kiện ràng buộc ở mục 2).
- **Dữ liệu đầu vào (Input)**:
  - `token`, `id`: Hợp lệ và còn hiệu lực.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã `1000` (OK) kèm thông báo thành công.
  - **Phía Client**: Thực hiện xóa bài viết khỏi giao diện danh sách hiện tại (ví dụ: cập nhật lại State của danh sách bài viết ở trang chủ hoặc trang cá nhân mà không cần reload toàn bộ app).

### TC-02: Sai phiên đăng nhập / Token hết hạn
- **Mô tả**: Người dùng gửi yêu cầu với mã phiên đăng nhập trống, quá ngắn hoặc đã hết hiệu lực.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Trống, không hợp lệ hoặc đã quá hạn.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng tự động điều hướng người dùng quay trở lại **Màn hình đăng nhập**.

### TC-03: Bài viết cần xóa đã bị khóa trước đó bởi hệ thống
- **Mô tả**: Người dùng yêu cầu xóa một bài viết nhưng bài viết đó đã bị hệ thống khóa trước đó (do vi phạm tiêu chuẩn cộng đồng hoặc hạn chế quốc gia).
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `id`: ID bài viết đã bị khóa.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã lỗi `9992`.
  - **Phía Client**: 
    - Bài viết phải biến mất ngay lập tức khỏi giao diện trang hiện tại.
    - Nếu người dùng đang ở **Trang chủ**: Thực hiện xóa bài viết khỏi danh sách hiển thị trên UI.
    - Nếu người dùng đang ở **Trang cá nhân**: Thực hiện xóa bài viết khỏi danh sách hoặc tiến hành gọi API làm mới (refresh) lại trang cá nhân (tùy thuộc vào thiết kế luồng màn hình).

### TC-04: Tài khoản người dùng yêu cầu bị khóa bởi hệ thống
- **Mô tả**: Tài khoản của người thực hiện hành động xóa đã bị hệ thống vô hiệu hóa/khóa.
- **Dữ liệu đầu vào (Input)**:
  - `token` của tài khoản đã bị khóa.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng hiển thị thông báo lỗi và tự động đẩy người dùng sang **Màn hình đăng nhập**.

### TC-05: Lỗi kết nối Cơ sở dữ liệu phía Server (Database Error)
- **Mô tả**: Server gặp sự cố kỹ thuật về Database khiến hành động xóa bị từ chối/không thể thực hiện.
- **Dữ liệu đầu vào (Input)**:
  - Request gửi đi đúng quy định nhưng server trả về lỗi Database (mã lỗi kỹ thuật DB).
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng nhận mã lỗi DB từ server.
  - **Yêu cầu xử lý UI**: Không được hiển thị trực tiếp mã lỗi kỹ thuật thô của server. Thay vào đó, hiển thị thông báo lỗi thân thiện với người dùng cuối, chẳng hạn như: `"Không thể kết nối Internet"` hoặc *"Đã có lỗi xảy ra, vui lòng thử lại sau"*.

### TC-06: ID bài viết gửi lên không tồn tại hoặc bị sai
- **Mô tả**: Người dùng gửi yêu cầu xóa với một ID bài viết bị sai lệch.
- **Dữ liệu đầu vào (Input)**:
  - `id`: Sai định dạng hoặc không tồn tại trên hệ thống.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về lỗi giá trị tham số không hợp lệ.
  - **Yêu cầu xử lý UI**: Ứng dụng không hiển thị trực tiếp mã lỗi kỹ thuật mà chuyển hóa thành thông điệp cảnh báo thân thiện hơn trên màn hình cho người dùng.

### TC-07: Mất kết nối mạng trong quá trình thực thi (Network Interrupted)
- **Mô tả**: Thiết bị bị ngắt kết nối mạng ngay khi người dùng nhấn nút xóa và gửi request đi.
- **Dữ liệu đầu vào (Input)**:
  - Thiết bị mất Wi-Fi/4G khi đang gửi request.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng thực hiện bắt ngoại lệ mất mạng ngay lập tức tại thiết bị (Client-side).
  - Hiển thị thông báo lỗi rõ ràng và nhanh nhất có thể: `"Không thể kết nối Internet"`.
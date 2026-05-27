# API Specification: edit_post

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện việc chỉnh sửa bài viết dành cho tài khoản Giáo viên (GV).
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/edit_post`

## 2. Ràng buộc Nghiệp vụ Quan trọng (Crucial Business Constraints)
- **Đối tượng áp dụng**: Chỉ dành cho tài khoản **Giáo viên (GV)**.
- **Điều kiện chỉnh sửa**: API này **chỉ được gọi** khi bài viết đó **chưa có bất kỳ Học viên (HV) nào nộp bài**. 
  - *Lưu ý cho UI/UX*: Trên giao diện Flutter, nút "Chỉnh sửa" nên bị ẩn hoặc vô hiệu hóa (disabled) nếu bài đăng đã có lượt nộp bài từ học viên.
- **Sửa đổi Video**: Các tham số liên quan đến video là **không bắt buộc** nếu người dùng chỉ có nhu cầu chỉnh sửa nội dung văn bản (`described`).

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `multipart/form-data` (khi có chỉnh sửa và upload tệp video mới).

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng (truyền trong Body Request) |
| 2 | `id` | string | O (Optional) | ID của bài viết cần chỉnh sửa |
| 3 | `described` | string | X (Required) | Nội dung văn bản mới của bài viết |
| 4 | `video_indices` | string | X (Required)* | Danh sách định danh các video mới sẽ được thay thế:<br>- `"L"`: Chỉ thay video bên trái.<br>- `"R"`: Chỉ thay video bên phải.<br>- `"all"` hoặc `"LR"`: Thay cả hai video. |
| 5 | `left_video` | file | X (Required)* | Tệp video mới dùng cho bên trái (Bắt buộc nếu `video_indices` yêu cầu thay đổi video trái) |
| 6 | `right_video` | file | X (Required)* | Tệp video mới dùng cho bên phải (Bắt buộc nếu `video_indices` yêu cầu thay đổi video phải) |

*\*Chú ý: Các tham số số 4, 5, 6 chỉ bắt buộc (`X`) khi có thực hiện hành động thay thế/chỉnh sửa video. Nếu chỉ sửa nội dung văn bản (`described`), các trường này có thể bỏ qua.*

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `code` | string | O | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | O | Thông điệp phản hồi từ hệ thống |
| 3 | `id` | string | O | ID của bài viết vừa sửa thành công (đồng thời là ID bài tập) |

### Ví dụ Response thành công (Success JSON):
```json
{
  "code": "1000",
  "message": "OK",
  "data": {
    "id": "post_123456"
  }
}
```
## 5. Kịch bản kiểm thử chi tiết (Test Cases Specifications)

### TC-01: Chỉnh sửa bài viết thành công (Luồng chuẩn)
- **Mô tả**: Giáo viên truyền đúng token, ID bài viết và các tham số chỉnh sửa hợp lệ.
- **Dữ liệu đầu vào (Input)**:
  - `token`, `id`: Hợp lệ và còn hiệu lực.
  - Các tham số thay đổi (`described`, video thay thế...) phù hợp với khai báo.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống trả về mã `1000` (OK).
  - Ứng dụng hiển thị thông báo chỉnh sửa thành công và cập nhật lại thông tin bài viết trên giao diện.

### TC-02: Sai phiên đăng nhập / Token hết hạn
- **Mô tả**: Đang thực hiện chỉnh sửa nhưng token gửi lên bị sai, trống hoặc hết hạn.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Sai, trống hoặc đã quá cũ.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - **Phía Client**: Toàn bộ phần nội dung người dùng đang chỉnh sửa dở dang trên UI sẽ **bị xóa sạch** để đảm bảo an toàn thông tin.
  - Điều hướng người dùng ngay lập tức về **Màn hình đăng nhập**.

### TC-03: Nội dung văn bản mới chứa từ ngữ độc hại
- **Mô tả**: Nội dung mới điền trong `described` chứa các từ ngữ độc hại bị cấm.
- **Dữ liệu đầu vào (Input)**:
  - `described`: Chứa ngôn từ độc hại hoặc vi phạm quy định.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống trả về mã lỗi `1010`.
  - Ứng dụng hiển thị thông báo lỗi chi tiết ra màn hình.
  - *(Chức năng này là tùy chọn, phía Server/Client có thể không phát triển ở phiên bản này)*.

### TC-04: Video thay thế không đúng định dạng hoặc không phù hợp
- **Mô tả**: Người dùng tải lên video không đạt tiêu chuẩn kiểm duyệt nội dung (ví dụ: ảnh động vật cấm, nội dung phản cảm) hoặc sai cấu trúc định dạng.
- **Dữ liệu đầu vào (Input)**:
  - Upload video thay thế sai định dạng hoặc vi phạm quy chuẩn.
- **Kết quả mong đợi (Expected Output)**:
  - **Kiểm tra phía Client (Bắt buộc)**: Ứng dụng chạy mô hình kiểm tra nội dung/định dạng ngay trên thiết bị trước. Điểm số đánh giá phải đạt mức tốt tối thiểu mới được phép gửi request lên server.
  - **Kiểm tra phía Server**: Server chạy mô hình kiểm duyệt riêng của hệ thống trước khi gửi dữ liệu cuối cùng đi xử lý tiếp (ví dụ: gửi tới hệ thống phân tích Rokoko).

### TC-05: Tài khoản người dùng bị khóa (Blocked Account)
- **Mô tả**: Tài khoản của giáo viên đã bị khóa trong hệ thống nhưng họ vẫn đang thao tác chỉnh sửa bài viết.
- **Dữ liệu đầu vào (Input)**:
  - `token` của tài khoản đã bị khóa.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống trả về mã lỗi `9995`.
  - Ứng dụng hiển thị thông báo tài khoản đã bị khóa và lập tức đẩy người dùng sang **Màn hình đăng nhập**.

### TC-06: Xác nhận xóa video cũ nhưng không tải lên video thay thế
- **Mô tả**: Người dùng đăng ký xóa video cũ (thông qua `video_indices`) nhưng lại không gửi kèm tệp video mới để thay thế tương ứng (thiếu tối thiểu 1 video thay thế).
- **Dữ liệu đầu vào (Input)**:
  - Truyền `video_indices` yêu cầu thay đổi nhưng không đính kèm tệp video tương ứng.
- **Kết quả mong đợi (Expected Output)**:
  - **Phía Client**: Phải thực hiện kiểm tra kiểm lỗi (validation) ngay tại thiết bị để chặn hành động gửi request lỗi này lên Server.
  - **Phía Server**: Cũng thực hiện kiểm tra chéo lại một lần nữa để tránh rò rỉ lỗi.

### TC-07: Yêu cầu xóa hai video nhưng tải lên video thay thế không đủ
- **Mô tả**: Giáo viên yêu cầu thay thế cả hai video (`video_indices` là `"all"` hoặc `"LR"`) nhưng chỉ đính kèm duy nhất một tệp video mới.
- **Dữ liệu đầu vào (Input)**:
  - `video_indices`: `"all"`.
  - Chỉ truyền `left_video` hoặc chỉ truyền `right_video`.
- **Kết quả mong đợi (Expected Output)**:
  - **Phía Client**: Tự kiểm tra và chặn ngay tại giao diện người dùng.
  - **Phía Server**: Nếu request lọt qua Client, Server phải trả về thông báo lỗi tham số không phù hợp.

### TC-08: Gửi mâu thuẫn giữa yêu cầu thay thế và file video đính kèm
- **Mô tả**: Yêu cầu xóa/thay thế một bên nhưng lại tải lên file video của bên ngược lại (ví dụ: yêu cầu xóa video bên trái nhưng lại tải lên file video bên phải).
- **Dữ liệu đầu vào (Input)**:
  - `video_indices` chỉ chứa `"L"` (chỉ thay video trái).
  - Không truyền `left_video` nhưng lại truyền tệp `right_video`.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng (Client) cần kiểm tra tính đồng bộ của tham số trước khi gửi.
  - Server cũng bắt buộc phải kiểm tra tính nhất quán này để xử lý từ chối request không hợp lệ
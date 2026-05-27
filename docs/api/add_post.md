# API Specification: add_post

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện việc đăng một bài viết cho một tài khoản của người dùng.
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/add_post`

## 2. Phân quyền và Logic nghiệp vụ (Business Logic)
- **Giáo viên**: Có quyền đăng bài tự do (không bắt buộc truyền `course_id`, `exercise_id`).
- **Học viên**: Muốn đăng bài thì truy cập vào bài đăng (post) của giáo viên và nhấn nút **"Nộp bài"** (vị trí tương đương nút Chia sẻ của Facebook). Khi học viên nhấn nút này, hệ thống tự động gán dữ liệu:
  - `exercise_id` = `id` của bài viết của giáo viên.
  - `course_id` = `id` của chủ bài viết (giáo viên).

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `multipart/form-data` (do có truyền file video).

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng (truyền trong Body Request) |
| 2 | `left_video` | file | X (Required) | File video từ camera trái |
| 3 | `right_video` | file | X (Required) | File video từ camera phải |
| 4 | `course_id` | string | X (Required)* | ID của khóa học. Bắt buộc có nếu là học viên đăng bài (lấy ID của giáo viên chủ bài viết). |
| 5 | `exercise_id` | string | X (Required)* | ID của bài tập. Bắt buộc có nếu là học viên đăng bài (lấy ID của bài viết của giáo viên). |
| 6 | `described` | string | X (Required) | Văn bản mô tả kèm theo bài viết |
| 7 | `device_slave` | string | X (Required) | ID của thiết bị phụ (slave) |
| 8 | `device_master`| string | O (Optional) | ID của thiết bị chính (master) |

*\*Chú ý: Các trường đánh dấu `X` ở trên là bắt buộc đối với luồng đăng của Học viên. Với Giáo viên, hệ thống linh hoạt hơn.*

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

| STT | Tên tham số | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- | :--- |
| 1 | `code` | string | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | Thông điệp phản hồi từ server |
| 3 | `data` | object | Đối tượng chứa dữ liệu trả về thành công |
| | `└── id` | string | ID của bài viết vừa được đăng thành công |

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

Dưới đây là 6 kịch bản kiểm thử bắt buộc ứng dụng phải xử lý khi tích hợp API `add_post`:

### TC-01: Giáo viên đăng bài thành công
- **Mục tiêu**: Xác thực luồng đăng bài thành công của tài khoản Giáo viên.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Mã phiên hợp lệ và còn hiệu lực.
  - `left_video`, `right_video`: Đúng định dạng và giới hạn cho phép.
  - `described`: Văn bản không trống, nằm trong số lượng từ cực đại.
  - Đúng mã xác thực gửi đến server.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã `1000` kèm thông báo thành công.
  - Ứng dụng nhận được `id` của bài viết trong đối tượng `data`.
  - Hiển thị thông báo đăng bài thành công trên UI và cập nhật danh bạ/bài viết.

### TC-02: Phiên đăng nhập không hợp lệ hoặc hết hạn
- **Mục tiêu**: Bảo mật tài khoản khi token gặp sự cố.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Gửi nhầm mã phiên hoặc mã phiên đã quá hạn.
  - Các tham số khác: Hợp lệ.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng tự động điều hướng người dùng quay trở lại **Màn hình đăng nhập**.

### TC-03: Kiểm tra dung lượng video quá lớn (Client-side)
- **Mục tiêu**: Tối ưu băng thông bằng cách chặn tải tệp quá lớn ngay tại thiết bị.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `left_video` hoặc `right_video`: Có tổng dung lượng vượt mức cho phép.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng phải tự kiểm tra kích thước file ngay tại phía Client (không gửi request lên server).
  - Ngăn chặn hành động gửi dữ liệu không chính xác.
  - Hiển thị thông báo lỗi trên UI: `"dung lượng video quá lớn"`.

### TC-04: Kiểm tra thời lượng video quá ngắn (Client-side)
- **Mục tiêu**: Đảm bảo chất lượng video đầu vào đạt chuẩn thời lượng tối thiểu.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `left_video` hoặc `right_video`: Có thời lượng quá ngắn.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng tự kiểm tra thời lượng video tại phía Client (không gửi request).
  - Ngăn chặn việc gửi request.
  - Hiển thị thông báo lỗi trên UI: `"thời lượng quá ngắn"`.

### TC-05: Lỗi hệ thống phía Server khi đăng bài
- **Mục tiêu**: Đảm bảo ứng dụng hoạt động ổn định và không làm mất dữ liệu người dùng khi server lỗi.
- **Dữ liệu đầu vào (Input)**:
  - Tất cả dữ liệu đầu vào đều hợp lệ nhưng server gặp sự cố bên trong.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã lỗi `9999` hoặc `1001`.
  - Ứng dụng nhận diện mã lỗi, hiển thị thông báo lỗi tương ứng cho người dùng.
  - **Quan trọng**: Ứng dụng vẫn phải giữ nguyên màn hình đăng bài và các thông tin đã điền trước đó để người dùng không phải nhập lại từ đầu.

### TC-06: Mất kết nối mạng trong quá trình gửi bài (Network Connection)
- **Mục tiêu**: Xử lý ngoại lệ mất mạng đột ngột.
- **Dữ liệu đầu vào (Input)**:
  - Người dùng nhập đủ dữ liệu hợp lệ và bấm đăng bài, nhưng kết nối mạng thiết bị bị ngắt đột ngột (mất Wi-Fi/4G).
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng kiểm tra trạng thái mạng phía Client.
  - Hiển thị thông báo lỗi rõ ràng trên UI về việc kết nối mạng bị ngắt.
  
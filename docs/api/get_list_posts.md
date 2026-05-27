# API Specification: get_list_posts

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện việc lấy danh sách các bài viết để hiển thị lên trang chủ (Newsfeed) của người dùng.
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/get_list_posts`

---

## 2. Cơ chế Phân trang & Logic nghiệp vụ (Pagination & Business Logic)

### 2.1. Tại sao cần tham số `last_id`?
Để giải quyết bài toán đồng bộ dữ liệu thời gian thực khi người dùng đang cuộn trang:
- **Tình huống**: Lúc 9:00 AM, ứng dụng tải về danh sách bài viết từ A1 đến A20. Lúc 9:01 AM, trên server có 10 bài viết mới đăng (B1 đến B10). Lúc 9:02 AM, người dùng cuộn xuống và ứng dụng yêu cầu trang tiếp theo (`index = 20` và `count = 20`).
- **Vấn đề**: Nếu phân trang bằng `index` thuần túy, server sẽ trả về danh sách từ bài thứ 21 (nhưng do có 10 bài mới chen vào đầu, bài thứ 21 lúc này thực chất là bài A11). Người dùng sẽ bị **trùng lặp** dữ liệu từ A11 đến A20.
- **Giải pháp**: Gửi kèm `last_id` (ID của bài viết mới nhất nhận được ở lượt đầu - bài A1). Server sẽ dựa vào `last_id` này để xác định mốc thời gian và tính toán phân trang chính xác (trả về đúng từ A21 đến A40). Đồng thời, server tính được có bao nhiêu bài mới xuất hiện (`new_items` từ B1 đến B10) để hiển thị thông báo "Có bài viết mới" trên UI.

### 2.2. Quy định về số lượng tải (`count`)
- Ứng dụng không bao giờ tải toàn bộ dữ liệu mà tải theo từng phần.
- Số lượng bản ghi mặc định cho mỗi lần gọi từ ứng dụng là **`count = 20`**. Phía server luôn xử lý động để giá trị này có thể thay đổi linh hoạt.

### 2.3. Hiển thị trường động dựa trên vai trò (Role-based Fields)
- **`time_series_poses`**: Chỉ xuất hiện và bắt buộc nếu tác giả bài viết là Giáo viên (`role == "GV"`). Đây là dữ liệu dùng để chấm điểm video bài nộp.
- **`exercise_id`**: Chỉ xuất hiện nếu tác giả bài viết là Học viên (`role == "HV"`), báo hiệu đây là một bài đăng nộp bài tập.

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `application/json` hoặc `application/x-www-form-urlencoded`.

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | X (Required)* | Mã phiên đăng nhập. Không có đăng nhập vẫn gọi được API này ở chế độ Khách (Guest mode). (truyền trong Body Request) |
| 2 | `category_id` | string | X (Required) | ID danh mục bài viết (Hiện tại có thể chưa dùng đến) |
| 3 | `last_id` | string | X (Required) | ID của bài viết mới nhất nhận được ở lần gọi đầu tiên |
| 4 | `index` | string | O (Optional) | Chỉ số bắt đầu lấy dữ liệu |
| 5 | `count` | string | O (Optional) | Số bài viết muốn lấy trong 1 lần (Mặc định là `"20"`) |
| 6 | `user_id` | string | X (Required)** | ID người dùng cần kiểm tra (Dành riêng cho Admin sử dụng kèm token Admin) |

*\*Lưu ý: Nếu người dùng gửi kèm token nhưng token đó bị sai/hết hạn, ứng dụng vẫn phải xử lý đẩy sang màn hình đăng nhập (Xem TC-14).*

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

### Bảng cấu trúc Response chính:
| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `code` | string | O | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | O | Thông điệp từ hệ thống |
| 3 | `data` | object | O | Đối tượng chứa dữ liệu bài viết |
| | `├── posts` | array | O | Danh sách chứa các bài viết chi tiết |
| | `├── new_items`| string | O | Số lượng bài viết mới đăng bị bỏ lỡ kể từ mốc `last_id` |
| | `└── last_id` | string | O | ID của bài viết cuối cùng để gửi lên cho lần tải kế tiếp |

### Chi tiết cấu trúc các trường bên trong từng bài viết thuộc mảng `posts`:
| Trường dữ liệu | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- |
| `post_id` | string | O | ID của bài viết |
| `described` | string | O | Nội dung văn bản của bài viết |
| `video` | array | X | Danh sách video đính kèm bài viết |
| `├── url` | string | X | URL của video |
| `└── thumb` | string | X | URL ảnh thu nhỏ của video |
| `created` | string | O | Thời gian đăng bài viết |
| `like` | string | O | Số lượng lượt thích bài viết |
| `comment` | string | O | Số lượng lượt bình luận bài viết |
| `is_liked` | string | O | Trạng thái User đã thích bài chưa (`"1"`: Đã thích, `"0"`: Chưa thích) |
| `is_blocked` | string | O | Trạng thái người xem có bị chủ bài viết chặn không |
| `can_edit` | string | O | Tài khoản hiện tại có quyền sửa bài viết này không |
| `can_comment` | string | O* | Quyền bình luận bài viết (`"1"`: Được bình luận, `"0"`: Khóa bình luận) |
| `banned` | string | O | Trạng thái chủ bài viết này đã bị khóa tài khoản chưa |
| `exercise_id` | string | X* | ID bài tập liên kết (Chỉ có nếu tác giả bài viết là Học viên) |
| `author` | object | O | Thông tin tác giả bài viết |
| `├── id` | string | O | ID của tác giả |
| `├── username` | string | O | Tên hiển thị của tác giả |
| `├── avatar` | string | O | URL ảnh đại diện của tác giả |
| `└── role` | string | X | Vai trò tác giả (`"HV"` hoặc `"GV"`). Có thể bỏ qua trường này. |

#### Trường động: Chuỗi tọa độ Pose theo thời gian (`time_series_poses`):
*Chỉ trả về nếu tác giả bài viết là Giáo viên (`role == "GV"`).*
- `time_series_poses` (array, X)
  - `frame` (array, O)
    - `frame_id` (string, O)
    - `created` (string, O) - Timestamp tạo frame
    - `poses` (array, O)
      - `pose_name` (string, O)
      - `pose_coord` (object, O)
        - `x` (string, O) - Trực tọa độ X *(Cần parse sang Double)*
        - `y` (string, O) - Trực tọa độ Y *(Cần parse sang Double)*
        - `z` (string, O) - Trực tọa độ Z *(Cần parse sang Double)*
      - `confident` (string, O) - Mức độ tin cậy của AI model cho điểm pose này *(Cần parse sang Double)*

---

## 5. Kịch bản kiểm thử chi tiết (Test Cases Specifications)

### TC-01: Lấy danh sách bài viết thành công (Luồng chuẩn)
- **Mô tả**: Gửi đúng thông tin phiên đăng nhập và các tham số phân trang hợp lệ.
- **Kết quả mong đợi**: Trả về code `1000 | OK`. Ứng dụng render danh sách bài viết lên giao diện trang chủ Newsfeed đầy đủ các thành phần.

### TC-02: Sai phiên đăng nhập / Token quá hạn
- **Mô tả**: Người dùng truyền sai token hoặc dùng mã phiên đã hết hạn.
- **Kết quả mong đợi**: Ứng dụng xóa dữ liệu tạm thời và điều hướng người dùng về **Màn hình đăng nhập**.

### TC-03: Không còn bài viết nào để tải thêm
- **Mô tả**: Người dùng cuộn tới cuối trang và gọi API tải thêm nhưng hệ thống đã hết bài viết.
- **Kết quả mong đợi**: Server phản hồi mã báo hết dữ liệu. Ứng dụng **không hiển thị lỗi kỹ thuật**, chỉ hiển thị dòng thông báo thân thiện gợi ý người dùng: *"Bạn có thể kết bạn thêm để xem nhiều bài viết hơn"*.

### TC-04: Tài khoản người dùng bị khóa toàn diện bởi hệ thống
- **Mô tả**: Người dùng đang lướt ứng dụng nhưng tài khoản đã bị hệ thống khóa.
- **Kết quả mong đợi**: Ứng dụng tự động **đăng xuất tài khoản**, xóa sạch toàn bộ dữ liệu lưu trữ tạm thời (cache) trên thiết bị, và điều hướng người dùng sang **Màn hình đăng nhập**.

### TC-05: Lỗi toàn bộ nội dung văn bản (`described`) của trang mới tải về
- **Mô tả**: Dữ liệu tải về bị lỗi định dạng nghiêm trọng ở trường `described` khiến không thể parse dữ liệu.
- **Kết quả mong đợi**: Ứng dụng không hiển thị các bài viết bị lỗi định dạng. Nếu toàn bộ danh sách vừa tải về đều bị lỗi, ứng dụng hiển thị trạng thái như không có thêm bài viết mới nào.

### TC-06: Lỗi các trường tương tác phụ (`like`, `comment`, `is_liked`)
- **Mô tả**: Một số bài viết tải về bị lỗi định dạng ở các trường tương tác phụ.
- **Kết quả mong đợi**: Ứng dụng vẫn render bài viết đó lên UI dựa trên các thông tin chính khác. Các trường bị lỗi sẽ được gán giá trị mặc định bằng `0` (hoặc `"0"`).

### TC-07: Trường trạng thái bình luận (`can_comment`) bị lỗi hoặc báo khóa
- **Mô tả**: Bài viết trả về có trường `can_comment` báo khóa (`"0"`) hoặc giá trị này bị lỗi định dạng.
- **Kết quả mong đợi**: Ứng dụng ẩn hoàn toàn ô nhập bình luận (comment box) của bài viết đó trên giao diện Newsfeed.

### TC-08: Trường thông tin tác giả bị lỗi ID (`author.id`)
- **Mô tả**: ID của tác giả bài viết bị thiếu hoặc bị lỗi định dạng.
- **Kết quả mong đợi**: Ứng dụng ẩn và **không hiển thị bài viết** bị lỗi ID tác giả này. Nếu chỉ lỗi các thông tin phụ khác của tác giả (như avatar, username), ứng dụng vẫn render bài viết và gán các giá trị mặc định cho tác giả.

### TC-09: Lỗi đồng thời cả hai trường mô tả (`described`) và đa phương tiện (`video`)
- **Mô tả**: Bài viết không có cả nội dung chữ lẫn video đính kèm hoặc cả hai trường đều lỗi định dạng.
- **Kết quả mong đợi**: Ứng dụng ẩn hoàn toàn và không hiển thị bài viết này lên màn hình.

### TC-10: Lỗi một trong hai trường mô tả (`described`) hoặc đa phương tiện (`video`)
- **Mô tả**: Bài viết bị lỗi ở 1 trong 2 trường (chỉ lỗi văn bản hoặc chỉ lỗi video).
- **Kết quả mong đợi**: Ứng dụng vẫn hiển thị bài viết cho các phần thông tin không bị lỗi. Phần bị lỗi sẽ được gán giá trị mặc định hoặc ẩn đi (ví dụ: lỗi video thì chỉ hiển thị văn bản mô tả).

### TC-11: Tham số phân trang `last_id` bị truyền sai định dạng
- **Mô tả**: Client truyền `last_id` trống hoặc sai định dạng kỹ thuật.
- **Kết quả mong đợi**: Server trả về mã lỗi sai giá trị tham số. Ứng dụng dừng việc tải thêm dữ liệu và giữ nguyên trạng thái danh sách hiện tại.

### TC-12: Tham số phân trang `index` hoặc `count` bị truyền sai định dạng
- **Mô tả**: Tham số `index` hoặc `count` bị lỗi định dạng hoặc trống.
- **Kết quả mong đợi**: Server trả về mã lỗi sai giá trị tham số. Ứng dụng dừng việc tải thêm dữ liệu.

### TC-13: Các tham số tọa độ thiết bị bị lỗi định dạng
- **Mô tả**: Người dùng truyền tọa độ thiết bị lên bị sai lệch định dạng.
- **Kết quả mong đợi**: Server tự động phát hiện và tái sử dụng dữ liệu tọa độ thiết bị hợp lệ ở lần gửi gần nhất của phiên làm việc.

### TC-14: Sai mã phiên đăng nhập, các tham số khác hợp lệ
- **Mô tả**: Token gửi kèm bị sai trong khi các trường phân trang và phân loại đều đúng chuẩn.
- **Kết quả mong đợi**: Ứng dụng ngay lập tức điều hướng người dùng sang **Màn hình đăng nhập**.
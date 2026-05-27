# API Specification: get_post

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện việc đọc/lấy thông tin chi tiết của một bài viết từ một tài khoản người dùng.
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/get_post`

---

## 2. Phân quyền và Logic nghiệp vụ (Business Logic)
- **Trường `user_id` ở đầu vào**: Giúp Admin kiểm tra xem nếu là người dùng thông thường thì họ sẽ nhận được kết quả gì. Khi sử dụng tham số này, `token` gửi lên bắt buộc phải là token của Admin.
- **Trường dữ liệu `time_series_poses` ở đầu ra**:
  - Chỉ trả về nếu **Người xem bài viết là Học viên (HV)** và **Người viết bài (Chủ bài viết) là Giáo viên (GV)**.
  - Nếu trường này được trả về, tất cả các trường con bên trong nó (được đánh dấu `O` - Optional ở bảng mô tả) sẽ **bắt buộc phải có** (trở thành Required).
- **Trường `lecturer`**: Nếu người viết bài (`author`) và giáo viên (`lecturer`) là cùng một người, hệ thống sẽ không trả về trường `lecturer` này.
- **Trường `exercise_id`**: Nếu người viết bài (`author`) và giáo viên (`lecturer`) là cùng một người thì không cần trả về trường này.

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `application/json` hoặc `application/x-www-form-urlencoded`.

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng (truyền trong Body Request) |
| 2 | `id` | string | O (Optional) | ID của bài viết cần lấy thông tin |
| 3 | `user_id` | string | X (Required) | ID của người dùng cần kiểm tra (Dành cho Admin, yêu cầu token của Admin) |

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

### Bảng cấu trúc Response chính:
| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `code` | string | O | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | O | Thông điệp từ hệ thống |
| 3 | `data` | array / object* | O | Chứa danh sách hoặc đối tượng chi tiết bài viết |

*\*Lưu ý: Tài liệu gốc ghi data là `array` nhưng cấu trúc chứa chi tiết một bài viết lồng nhau bên dưới. Cần xử lý linh hoạt.*

### Chi tiết các trường bên trong `data`:
| Trường dữ liệu | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | string | O | ID của bài viết |
| `described` | string | O | Nội dung văn bản của bài viết |
| `created` | string | O | Thời gian tạo bài viết |
| `modified` | string | O | Thời gian chỉnh sửa bài viết gần nhất |
| `like` | string | O | Số lượng lượt thích (like) của bài viết |
| `comment` | string | O | Số lượng lượt bình luận (comment) của bài viết |
| `is_liked` | string | O | Trạng thái User đã thích bài này chưa (`"1"`: Đã thích, `"0"`: Chưa thích) |
| `video` | array | X | Danh sách video đính kèm bài viết |
| `├── url` | string | X | Đường dẫn URL của video |
| `└── thumb` | string | X | Đường dẫn URL hình ảnh thu nhỏ (thumbnail) của video |
| `lecturer` | object/string*| O | Thông tin Giáo viên. Không trả về nếu `author` và `lecturer` là một. |
| `├── id` | string | O | ID của giáo viên |
| `├── name` | string | O | Tên của giáo viên |
| `└── avatar` | string | O | Đường dẫn ảnh đại diện của giáo viên |
| `author` | object/array* | O | Thông tin Người viết bài (Tác giả) |
| `├── id` | string | O | ID của tác giả |
| `├── name` | string | O | Tên của tác giả |
| `└── avatar` | string | O | Đường dẫn ảnh đại diện của tác giả |
| `exercise_id` | array | O | ID bài tập. Không trả về nếu `author` và `lecturer` là một. |
| `edited_times` | string | O | Số lần đã chỉnh sửa bài viết |
| `is_blocked` | string | O | Trạng thái chủ bài viết có chặn (`block`) người xem hay không (`"1"`: Đã chặn, `"0"`: Chưa chặn) |

### Chi tiết cấu trúc chuỗi Pose theo thời gian (`time_series_poses`):
*Trường này chỉ xuất hiện khi học viên xem bài viết của giáo viên. Các trường con bên dưới sẽ chuyển từ Optional (`O`) thành bắt buộc nếu trường cha xuất hiện.*

| Trường dữ liệu | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- |
| `time_series_poses`| array | X | Danh sách các điểm pose theo tiến trình thời gian |
| `└── frame` | array | O | Tập hợp các điểm poses trong một frame ảnh (Tần suất 4 frame/s) |
| `    ├── frame_id` | string | O | ID của khung hình |
| `    ├── created` | string | O | Thời gian tạo frame dưới dạng Time Stamp |
| `    └── poses` | array | O | Danh sách các điểm tư thế |
| `        ├── pose_name`| string| O | Tên của điểm tư thế (ví dụ: tay, chân, đầu...) |
| `        ├── pose_coord`| array| O | Tọa độ của điểm tư thế qua các trục Ox, Oy, Oz |
| `        │   ├── x` | string | O | Tọa độ trục X *(Lưu ý: Client cần parse từ String sang Double)* |
| `        │   ├── y` | string | O | Tọa độ trục Y *(Lưu ý: Client cần parse từ String sang Double)* |
| `        │   ├── z` | string | O | Tọa độ trục Z *(Lưu ý: Client cần parse từ String sang Double)* |
| `        └── confident`| string | X | Độ tin cậy của model AI xác định điểm poses *(Client cần parse sang Double)* |

---

## 5. Kịch bản kiểm thử chi tiết (Test Cases Specifications)

### TC-01: Lấy thông tin bài viết thành công (Luồng chuẩn)
- **Mô tả**: Người dùng gửi đúng phiên đăng nhập và ID bài viết đang hoạt động bình thường.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ và còn hiệu lực.
  - `id`: ID bài viết hợp lệ đang tồn tại trên hệ thống.
- **Kết quả mong đợi (Expected Output)**:
  - API trả về mã `1000` (OK) kèm đầy đủ thông tin bài viết.
  - Ứng dụng parse dữ liệu thành công, hiển thị chi tiết nội dung, số lượt like, comment, video và các thông tin liên quan lên màn hình chi tiết bài viết.

### TC-02: Sai phiên đăng nhập / Token hết hạn
- **Mô tả**: Người dùng có mã phiên đăng nhập không hợp lệ, bị trống hoặc quá ngắn.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Trống, quá ngắn hoặc là mã cũ đã hết hạn.
  - `id`: Hợp lệ.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng tự động điều hướng người dùng sang **Màn hình đăng nhập**.

### TC-03: Bài viết đã bị khóa (Vi phạm tiêu chuẩn)
- **Mô tả**: Bài viết bị khóa do vi phạm tiêu chuẩn cộng đồng hoặc bị hạn chế quốc gia.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `id`: ID bài viết đã bị khóa trên hệ thống.
- **Kết quả mong đợi (Expected Output)**:
  - API trả về mã lỗi `9992`.
  - Ứng dụng hiển thị thông báo lỗi phù hợp, tự động quay lại màn hình trước đó hoặc không cho phép chuyển tiếp sang màn hình chi tiết bài viết.

### TC-04: Người dùng xem bài viết bị chủ bài viết chặn (Block)
- **Mô tả**: Tác giả bài viết đã thực hiện chặn (`block`) tài khoản người đang xem.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `id`: ID bài viết của người đã chặn người xem.
- **Kết quả mong đợi (Expected Output)**:
  - API trả về dữ liệu trống ở hầu hết các trường, riêng trường `is_blocked` trả về giá trị `"1"`.
  - Ứng dụng phát hiện `is_blocked == "1"`, thông báo lỗi chặn và đưa người dùng trở lại màn hình trước đó.

### TC-05: Lỗi dữ liệu trường nội dung bài viết (`described`)
- **Mô tả**: Dữ liệu trả về từ server bị lỗi hoặc trống bất thường ở phần nội dung bài viết.
- **Dữ liệu đầu vào (Input)**:
  - Đúng token, đúng ID bài viết nhưng trường `described` bị lỗi giá trị.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng không hiển thị bài viết lỗi này lên UI.
  - Thực hiện điều hướng quay lại màn hình trước đó hoặc chặn việc chuyển trang hiển thị.

### TC-06: Lỗi dữ liệu tương tác (`like`, `comment`, `is_liked`)
- **Mô tả**: Các trường tương tác phụ bị lỗi định dạng hoặc không thể lấy dữ liệu từ server.
- **Dữ liệu đầu vào (Input)**:
  - Gửi request hợp lệ nhưng các trường `like`, `comment`, `is_liked` trả về giá trị lỗi từ server.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng không crash, tiếp tục hiển thị các thông tin bài viết chính cần thiết khác lên UI bằng cách tự động xử lý/bỏ qua các giá trị tương tác lỗi này.

### TC-07: Lỗi trường thông tin giáo viên (`lecturer`)
- **Mô tả**: Trường thông tin giảng viên bị lỗi cấu trúc hoặc sai lệch giá trị.
- **Dữ liệu đầu vào (Input)**:
  - Gửi request hợp lệ, nhưng giá trị của trường `lecturer` trả về bị lỗi.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng chặn hiển thị bài viết.
  - Tự động quay lại màn hình trước đó và không chuyển tiếp sang màn hình hiển thị bài viết.

### TC-08: Lỗi trường thông tin tác giả (`author`) bị lỗi ID
- **Mô tả**: Trường thông tin tác giả bài viết bị mất ID hoặc ID không hợp lệ.
- **Dữ liệu đầu vào (Input)**:
  - Gửi request hợp lệ, nhưng trường `author.id` bị lỗi.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng không hiển thị bài viết lỗi.
  - Quay lại màn hình trước đó và không chuyển sang trang hiển thị bài viết.

### TC-09: Lỗi trường thông tin tác giả (`author`) bị lỗi Tên/Avatar/Trạng thái Online
- **Mô tả**: Thông tin phụ của tác giả (Tên, ảnh đại diện, trạng thái online) trả về bị lỗi.
- **Dữ liệu đầu vào (Input)**:
  - Gửi request hợp lệ, thông tin tác giả bị lỗi Tên, Avatar hoặc Online.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng vẫn cho phép hiển thị bài viết dựa trên các thông tin cần thiết khác.
  - Tự động gán giá trị mặc định cho phần bị lỗi: Tên hiển thị là `"Người dùng"`, ảnh đại diện gán ảnh mặc định, và coi như người dùng này không online.

### TC-10: ID bài viết bị gửi sai
- **Mô tả**: Người dùng yêu cầu thông tin của một bài viết bằng ID không tồn tại.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `id`: Sai hoặc không tồn tại.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về lỗi không tìm thấy bài viết.
  - Ứng dụng không hiển thị bài viết, quay lại màn hình trước đó và không chuyển tiếp trang.
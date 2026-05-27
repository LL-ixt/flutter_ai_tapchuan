# API Specification: get_comment

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện lấy danh sách bình luận (comments) của một bài viết cụ thể.
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/get_comment`

## 2. Logic nghiệp vụ & Phân trang (Business Logic & Pagination)
- **Hiển thị danh sách**: Khi người dùng mở phần bình luận, một Popup/Bottom Sheet bình luận sẽ hiện ra và hiển thị danh sách các bình luận mới nhất.
- **Cơ chế Phân trang (Pagination)**: API sử dụng hai tham số `index` (vị trí bắt đầu) và `count` (số lượng bản ghi cần lấy) để tải bình luận theo từng phần.
- **Xử lý Tải thêm (Load More)**: 
  - Nếu số lượng bình luận trả về bằng với số lượng `count` yêu cầu, hiển thị tùy chọn/nút **"Tải thêm các bình luận..."** để người dùng tải các bình luận cũ hơn.
  - Nếu số lượng bình luận trả về nhỏ hơn số lượng `count`, điều đó có nghĩa là đã hết bình luận cũ. Hệ thống bắt buộc phải **ẩn nút** hoặc tùy chọn "Tải thêm các bình luận..." này trên UI.

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `application/json` hoặc `application/x-www-form-urlencoded`.

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng (truyền trong Body Request) |
| 2 | `id` | string | O (Optional) | ID của bài viết cần lấy danh sách bình luận |
| 3 | `index` | string | O (Optional) | Vị trí offset bắt đầu lấy dữ liệu (phục vụ phân trang) |
| 4 | `count` | string | O (Optional) | Số lượng bình luận muốn lấy trong lượt này (phục vụ phân trang) |
| 5 | `user_id` | string | X (Required)* | ID người dùng cần kiểm tra (Dành riêng cho Admin sử dụng kèm token Admin) |

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

### Bảng cấu trúc Response chính:
| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `code` | string | O | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | O | Thông điệp từ hệ thống |
| 3 | `data` | array | O | Danh sách chứa các đối tượng bình luận |
| 4 | `is_blocked` | string | O | Trạng thái block của chủ bài viết (nằm ở cấp độ root) |

### Chi tiết các trường bên trong từng đối tượng thuộc danh sách `data`:
| Trường dữ liệu | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | string | O | ID của bình luận |
| `comment` | string | O | Nội dung văn bản bình luận |
| `created` | string | O | Thời gian tạo bình luận (TIMESTAMP hoặc chuỗi định dạng) |
| `poster` | object/array* | O | Đối tượng chứa thông tin người viết bình luận |
| `├── id` | string | O | ID của người viết bình luận |
| `├── name` | string | O | Tên của người viết bình luận |
| `└── avatar` | string | O | Đường dẫn ảnh đại diện (URL) của người viết bình luận |

*\*Lưu ý: Tài liệu gốc hiển thị kiểu dữ liệu của `poster` là array, nhưng cấu trúc chứa `id`, `name`, `avatar` tương đương với cấu trúc của một Class/Object `Poster` trong Dart.*

---

## 5. Kịch bản kiểm thử chi tiết (Test Cases Specifications)

### TC-01: Lấy danh sách bình luận thành công (Luồng chuẩn)
- **Mô tả**: Người dùng truyền đúng phiên đăng nhập, ID bài viết và các chỉ số phân trang hợp lệ.
- **Dữ liệu đầu vào (Input)**:
  - `token`, `id`: Hợp lệ và còn hiệu lực.
  - `index`, `count`: Đúng quy định.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã `1000` (OK) kèm danh sách bình luận mới nhất trong trường `data`.
  - **Phía Client**: Hiển thị popup bình luận ra màn hình và kết xuất danh sách bình luận một cách chính xác.

### TC-02: Sai phiên đăng nhập / Token hết hạn
- **Mô tả**: Người dùng gửi yêu cầu với mã phiên đăng nhập trống, quá ngắn hoặc đã hết hiệu lực.
- **Dữ liệu đầu vào (Input)**:
  - `token`: Trống, quá ngắn hoặc là mã cũ.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng tự động điều hướng người dùng sang **Màn hình đăng nhập**.

### TC-03: Bài viết bị khóa ngay trước khi gửi yêu cầu xem bình luận
- **Mô tả**: Bài viết bị hệ thống khóa đột ngột do vi phạm hoặc bị hạn chế ngay trong lúc người dùng đang chuẩn bị gửi yêu cầu xem bình luận (ở màn hình trước đó bài viết vẫn hiển thị bình thường).
- **Dữ liệu đầu vào (Input)**:
  - `token`: Hợp lệ.
  - `id`: ID bài viết vừa bị khóa.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã lỗi `1010`.
  - **Phía Client**: 
    - Bài viết phải biến mất ngay lập tức khỏi giao diện hiện tại.
    - Nếu ở **Trang chủ**: Xóa bài viết khỏi danh sách hiển thị trên UI.
    - Nếu ở **Trang cá nhân**: Xóa bài viết khỏi danh sách hiển thị hoặc tiến hành tải lại (reload) trang cá nhân.

### TC-04: Tài khoản người xem bình luận bị khóa bởi hệ thống
- **Mô tả**: Tài khoản của người thực hiện hành động xem bình luận đã bị hệ thống khóa đột ngột.
- **Dữ liệu đầu vào (Input)**:
  - `token` của tài khoản đã bị khóa.
- **Kết quả mong đợi (Expected Output)**:
  - Hệ thống từ chối yêu cầu.
  - Ứng dụng tự động điều hướng người dùng sang **Màn hình đăng nhập**.

### TC-05: Lỗi kết nối Cơ sở dữ liệu phía Server (Database Error)
- **Mô tả**: Server gặp lỗi Database đột ngột dẫn đến việc không thể truy vấn để lấy danh sách bình luận.
- **Dữ liệu đầu vào (Input)**:
  - Request gửi đi đúng quy định nhưng server trả về lỗi Database.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng nhận mã lỗi DB từ server.
  - **Yêu cầu xử lý UI**: Không hiển thị trực tiếp mã lỗi kỹ thuật thô. Thay vào đó, hiển thị thông báo lỗi thân thiện như: `"Không thể kết nối Internet"` hoặc *"Đã có lỗi xảy ra, vui lòng thử lại sau"*.

### TC-06: Bài viết không tồn tại hoặc sai ID bài viết
- **Mô tả**: Người dùng gửi yêu cầu với một ID bài viết không có trên hệ thống.
- **Dữ liệu đầu vào (Input)**:
  - `id`: Không tồn tại trên hệ thống.
- **Kết quả mong đợi (Expected Output)**:
  - Server trả về mã lỗi `9992`.
  - Ứng dụng nhận dạng lỗi và hiển thị thông báo: `"Bài viết không tồn tại"`.

### TC-07: Mất kết nối mạng trong quá trình tải bình luận (Network Error)
- **Mô tả**: Thiết bị bị mất mạng đột ngột ngay khi gửi request tải bình luận hoặc tải thêm bình luận.
- **Dữ liệu đầu vào (Input)**:
  - Thiết bị mất Wi-Fi/4G khi đang gửi request.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng kiểm tra trạng thái mạng tại Client.
  - Hiển thị thông báo lỗi rõ ràng và nhanh nhất có thể: `"Không thể kết nối Internet"`.

### TC-08: Hết dữ liệu bình luận cũ (Hạn chế nút Load More)
- **Mô tả**: Người dùng thực hiện tải thêm bình luận nhưng số lượng bình luận thực tế trả về từ Server ít hơn số lượng yêu cầu của tham số `count` (ví dụ: yêu cầu `count = 10` nhưng server chỉ còn trả về `3` bình luận).
- **Dữ liệu đầu vào (Input)**:
  - Request lấy danh sách trang tiếp theo với `count` lớn hơn số lượng bản ghi còn lại trong database.
- **Kết quả mong đợi (Expected Output)**:
  - Ứng dụng hiển thị toàn bộ số bình luận còn lại đó lên UI bình thường.
  - **Logic UI bắt buộc**: Chắc chắn rằng không còn bình luận cũ hơn nữa, ứng dụng phải ẩn hoàn toàn nút hoặc dòng chữ **"Tải thêm các bình luận..."** trên màn hình.
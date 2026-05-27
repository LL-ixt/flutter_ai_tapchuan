# API Specification: set_comment

## 1. Tổng quan (Overview)
- **Chức năng**: API thực hiện gửi/đăng thêm một bình luận (comment) mới vào một bài viết.
- **Phương thức (Method)**: `POST`
- **Base URL**: `https://group1.it4788.sukkaito.id.vn/it4788`
- **Endpoint**: `/set_comment`

## 2. Logic nghiệp vụ & Ràng buộc UI/UX (Business Logic & UI/UX Constraints)

### 2.1. Quy tắc Loại trừ lẫn nhau (Mutual Exclusion for Inputs)
API này hỗ trợ hai loại bình luận khác nhau và bắt buộc phải gửi dữ liệu theo quy tắc loại trừ lẫn nhau:
- **Luồng 1 - Bình luận thông thường (Normal Comment)**:
  - Bắt buộc phải có trường `comment`.
  - **Không gửi** các trường `score` và `detail_mistakes`.
- **Luồng 2 - Bình luận chấm điểm (Grading Comment)**:
  - Bắt buộc phải có các trường `score` và `detail_mistakes`.
  - **Không gửi** trường `comment`.

*Chú ý cho thiết kế Model ở Client*: Dựa vào trạng thái loại bài đăng để tự động cấu hình bộ tham số gửi đi cho chính xác, tránh gửi thừa tham số gây lỗi logic server.

### 2.2. Logic Giao diện (UI UX Auto-Scroll)
Sau khi người dùng gửi bình luận thành công:
- Popup/Bottom Sheet bình luận sẽ hiện ra danh sách các bình luận mới nhất.
- **Yêu cầu bắt buộc**: Giao diện hiển thị danh sách bình luận (như `ListView`) phải **tự động cuộn xuống dưới cùng** (bằng `ScrollController.animateTo`) để người dùng nhìn thấy ngay bình luận mới nhất của chính họ vừa được đăng.

---

## 3. Tham số đầu vào (Input Parameters)
Dạng truyền dữ liệu: `application/json` hoặc `application/x-www-form-urlencoded`.

| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `token` | string | O (Optional) | Mã phiên đăng nhập của người dùng (truyền trong Body Request) |
| 2 | `id` | string | O (Optional) | ID của bài viết cần gửi bình luận |
| 3 | `comment` | string | X (Required)* | Nội dung văn bản bình luận (Dành cho bình luận thông thường) |
| 4 | `index` | string | O (Optional) | Chỉ số comment bắt đầu (phục vụ việc tải lại danh sách mới) |
| 5 | `count` | string | O (Optional) | Số lượng comment cần lấy về (phục vụ phân trang) |
| 6 | `score` | string | X (Required)* | Điểm số chấm được (Dành cho bình luận chấm điểm) |
| 7 | `detail_mistakes`| string| X (Required)* | Chuỗi HTML mô tả chi tiết lỗi (Dành cho bình luận chấm điểm) |

*\*Chú ý: Tham khảo quy tắc loại trừ lẫn nhau ở mục 2.1 để xác định tính bắt buộc của trường `comment` hoặc bộ đôi `score` & `detail_mistakes`.*

---

## 4. Dữ liệu trả về (Output Response)
Định dạng: `JSON`

### Bảng cấu trúc Response chính:
| STT | Tên tham số | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `code` | string | O | Mã phản hồi hệ thống (tham khảo Response Common) |
| 2 | `message` | string | O | Thông điệp từ hệ thống |
| 3 | `data` | array | O | Chứa danh sách các bình luận cập nhật mới nhất |
| 4 | `is_blocked` | string | X | Trạng thái block của chủ bài viết |

### Chi tiết cấu trúc các trường bên trong danh sách `data`:
| Trường dữ liệu | Kiểu dữ liệu | Bắt buộc (NN) | Mô tả |
| :--- | :--- | :--- | :--- |
| `id` | string | X | ID của bình luận |
| `comment` | string | X | Nội dung của bình luận |
| `created` | string | X | Thời gian tạo bình luận |
| `poster` | object/string*| X | Thông tin của người viết bình luận |
| `├── id` | string | X | ID của người viết bình luận |
| `├── name` | string | X | Tên của người viết bình luận |
| `└── avatar` | string | X | URL ảnh đại diện của người viết bình luận |

*\*Lưu ý: Kiểu dữ liệu của `poster` được server mô tả là string nhưng cấu trúc chứa `id`, `name`, `avatar` tương ứng với một Class/Object Poster trong Dart.*

---

## 5. Kịch bản kiểm thử chi tiết (Test Cases Specifications)

### TC-01: Gửi bình luận thành công (Luồng chuẩn)
- **Mô tả**: Gửi đúng phiên đăng nhập, ID bài viết, các tham số hợp lệ và hệ thống không có thêm bình luận mới nào khác ở thời điểm đó.
- **Kết quả mong đợi**: Trả về code `1000 | OK`. Hiển thị bình luận mới nhất vừa đăng của người dùng ở cuối danh sách.

### TC-02: Sai phiên đăng nhập / Token hết hạn
- **Mô tả**: Người dùng có mã phiên đăng nhập trống, quá ngắn hoặc đã hết hiệu lực.
- **Kết quả mong đợi**: Ứng dụng tự động xóa dữ liệu tạm và điều hướng người dùng quay trở lại **Màn hình đăng nhập**.

### TC-03: Bài viết bị khóa ngay trước khi người dùng nhấn gửi bình luận
- **Mô tả**: Bài viết bị hệ thống khóa đột ngột ngay trong lúc người dùng đang soạn thảo bình luận (ở màn hình trước bài viết vẫn bình thường).
- **Kết quả mong đợi**: Server trả về mã lỗi `1010`.
- **Phía Client**: 
  - Bài viết lỗi phải biến mất lập tức trên giao diện hiện tại.
  - Nếu ở **Trang chủ**: Xóa bài viết khỏi danh sách hiển thị trên UI.
  - Nếu ở **Trang cá nhân**: Xóa bài viết khỏi danh sách hiển thị hoặc tiến hành tải lại (reload) trang cá nhân.

### TC-04: Tài khoản người bình luận bị khóa bởi hệ thống
- **Mô tả**: Tài khoản của người thực hiện hành động bình luận đã bị hệ thống khóa đột ngột.
- **Kết quả mong đợi**: Hệ thống từ chối yêu cầu. Ứng dụng tự động điều hướng người dùng sang **Màn hình đăng nhập**.

### TC-05: Lỗi kết nối Cơ sở dữ liệu phía Server (Database Error)
- **Mô tả**: Server gặp lỗi Database đột ngột dẫn đến việc không thể chèn bình luận mới vào danh sách.
- **Kết quả mong đợi**: Server trả về lỗi Database. Ứng dụng nhận dạng lỗi và hiển thị thông báo lỗi thân thiện thay vì hiển thị mã lỗi kỹ thuật, chẳng hạn như: `"Không thể kết nối Internet"`.

### TC-06: Bài viết không tồn tại hoặc sai ID bài viết
- **Mô tả**: Người dùng gửi yêu cầu với một ID bài viết không có trên hệ thống.
- **Kết quả mong đợi**: Server trả về mã lỗi `9992`. Ứng dụng hiển thị thông báo: `"Bài viết không tồn tại"`.

### TC-07: Mất kết nối mạng trong quá trình gửi bình luận (Network Error)
- **Mô tả**: Thiết bị bị mất mạng đột ngột ngay khi nhấn gửi bình luận mới.
- **Kết quả mong đợi**: Ứng dụng tự động bắt lỗi kết nối tại Client. Hiển thị thông báo lỗi nhanh nhất có thể: `"Không thể kết nối Internet"`.

### TC-08: Đăng bình luận thành công và đồng thời có thêm các bình luận mới từ người khác
- **Mô tả**: Trong quá trình người dùng gửi bình luận, hệ thống cũng ghi nhận thêm một số bình luận mới từ các người dùng khác và API trả về tất cả.
- **Kết quả mong đợi**: Ứng dụng render toàn bộ các bình luận mới này xuất hiện nối tiếp bên dưới. **Đặc biệt**: Ứng dụng phải tự động cuộn (scroll) màn hình xuống vị trí bình luận cuối cùng vừa được cập nhật.

### TC-09: Lọc các bình luận từ người dùng bị chặn (Block filtering)
- **Mô tả**: Trong danh sách các bình luận mới do API trả về, có bình luận của những người đang chặn người dùng hoặc đã bị chính người dùng chặn.
- **Kết quả mong đợi**: Phía Server sẽ chịu trách nhiệm lọc và loại bỏ các bình luận bị chặn này ra khỏi danh sách trước khi trả về. Nếu sau khi lọc không còn bình luận nào, hệ thống vẫn phản hồi kết quả là bình luận thành công.

### TC-10: Người dùng gửi thiếu tham số bắt buộc hoặc nội dung bình luận bị bỏ trống
- **Mô tả**: Người dùng tìm cách gửi bình luận có nội dung trống hoặc sai bộ tham số bắt buộc.
- **Kết quả mong đợi**:
  - **Phía Client**: Ứng dụng phải tự kiểm duyệt độ dài và tính hợp lệ của dữ liệu trước khi gửi (không cho bấm nút gửi nếu rỗng).
  - **Trường hợp bỏ lọt lên Server**: Server phát hiện thiếu tham số và trả về mã lỗi sai tham số. Ứng dụng nhận diện lỗi, giữ nguyên giao diện hiển thị hiện hành mà không hiển thị thông báo lỗi kỹ thuật gây phiền phức cho người dùng.
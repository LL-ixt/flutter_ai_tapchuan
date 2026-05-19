# TASK 08: API INTEGRATION (SWAP MOCK DATA TO REAL NETWORK)

## 1. API Rules (Từ Backend Contract)
- **Base URL:** `http://[YOUR_SERVER_IP]/api/`
- **Method:** Tất cả đều là `POST`.
- **Format:** `FormData` hoặc `application/json`.
- **Response Base Model:**
  Tạo class `BaseResponse<T>` để hứng dữ liệu:
  `code` (String), `message` (String), `data` (Generic T).
- **Mã Code thành công:** `code == "1000"`.

## 2. Mapping Object (Domain <-> Data)
Backend dùng hệ thống E-Commerce cũ nên tên API hơi khác so với UI của Mạng xã hội:
- Bảng tin (Feed): Gọi API `get_list_products`. Map `Product` từ API thành entity `Post` của App.
- Đăng bài: Gọi API `add_products`. Truyền `video`, `described`...
- Bình luận: Gọi API `get_comment_products` và `set_comment_products`.
- Chat: Gọi API `get_list_conversation` và `get_conversation_detail`.

## 3. Nhiệm vụ của Developer (AI)
Không được sửa UI hay Cubit. Chỉ được vào thư mục `lib/features/.../data/repositories/` và `lib/features/.../data/datasources/`:
1. Sửa file `..._remote_data_source.dart`: Dùng `Dio` gửi POST request tới Endpoint tương ứng.
2. Xử lý logic: Nếu `code != "1000"`, ném ra `ServerException(message)`.
3. Cập nhật Repository để gọi Data Source này thay vì trả về Mock Data.
# 📜 API Contract - Hệ thống Mạng Xã Hội & E-Learning

**Base URL:** `https://ABC.def/it4788` (Tên miền giả định theo tài liệu, thay thế bằng IP Local hoặc Mock Server của team).
**HTTP Method chung:** `POST` (Theo đặc tả, toàn bộ API sử dụng POST request).
**Content-Type:** `application/json` hoặc `multipart/form-data` (đối với upload file).

---

## 1. Đăng nhập (Login)
* **Endpoint:** `/login`
* **Method:** `POST`
* **Mô tả:** Xác thực người dùng, trả về thông tin cá nhân và `token` để sử dụng cho các API sau.
* **Payload Request:** `phonenumber`, `password`, `uuid` (Device ID)

**Mock Response (Success):**
```json
{
  "code": "1000",
  "message": "OK",
  "data": {
    "id": "user_987654",
    "username": "Nguyễn Tiến Thành",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.MockToken123456",
    "avatar": "https://i.pravatar.cc/150?u=user_987654",
    "role": "GV" 
  }
}
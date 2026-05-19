# TASK 07: QUAY VIDEO ĐỒNG BỘ VÀ CHẤM ĐIỂM AI (DTW)

## 1. Objective
Xây dựng logic quay 2 video đồng bộ qua Socket, trích xuất Poses và dùng thuật toán DTW để chấm điểm tại Client.

## 2. Yêu cầu triển khai
- **Sync Record (Trang 2 PDF):** Màn hình kết nối 2 thiết bị (1 Master, 1 Slave) qua Socket. Tự động đồng bộ thời gian (NTP) để bắt đầu quay video cùng lúc.
- **Video Processing:** Lấy 2 file MP4 sau khi quay. Rút trích frames (4 fps).
- **AI Poses & DTW Grading (Trang 8 PDF):**
  + Gửi frames lên server để lấy tọa độ Poses 2D/3D.
  + (Client-side Grading): Viết thuật toán `Dynamic Time Warping (DTW)` bằng Dart để so sánh mảng `time_series_poses` của Học viên với mảng của Giáo viên.
  + Tính ra điểm số. Tự động gọi API `set_comment` để gửi điểm vào bài viết của HV.
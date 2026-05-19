import 'dart:math';

class DTWCalculator {
  /// Triển khai thuật toán Dynamic Time Warping (DTW)
  /// Tính toán độ sai lệch giữa 2 chuỗi số thực (ví dụ: chuỗi tọa độ khớp xương)
  static double calculateDTWDistance(List<double> seq1, List<double> seq2) {
    int n = seq1.length;
    int m = seq2.length;

    // Trường hợp mảng rỗng
    if (n == 0 && m == 0) return 0.0;
    if (n == 0 || m == 0) return double.infinity;

    // Khởi tạo ma trận (n+1) x (m+1) với giá trị Infinity
    List<List<double>> dtw = List.generate(
      n + 1,
      (_) => List.filled(m + 1, double.infinity),
    );

    // Điểm xuất phát có khoảng cách bằng 0
    dtw[0][0] = 0.0;

    // Quy hoạch động để điền ma trận
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        // Chi phí tại điểm hiện tại (khoảng cách tuyệt đối giữa 2 phần tử)
        double cost = (seq1[i - 1] - seq2[j - 1]).abs();

        // Tìm đường đi có chi phí lũy kế nhỏ nhất từ 3 ô liền kề (Trái, Trên, Chéo)
        double minPrevious = [
          dtw[i - 1][j], // Kéo giãn chuỗi 2 (Insertion)
          dtw[i][j - 1], // Kéo giãn chuỗi 1 (Deletion)
          dtw[i - 1][j - 1], // Khớp nhau (Match)
        ].reduce(min);

        // Chi phí lũy kế tại ô [i][j]
        dtw[i][j] = cost + minPrevious;
      }
    }

    // Kết quả là chi phí lũy kế tại góc dưới cùng bên phải của ma trận
    return dtw[n][m];
  }

  /// Quy đổi khoảng cách DTW thành điểm số (thang 10)
  static double gradeMovement(double dtwDistance) {
    if (dtwDistance == double.infinity) return 0.0;

    // Sử dụng hàm suy giảm mũ (Exponential Decay)
    // Khoảng cách bằng 0 -> Điểm 10 tuyệt đối.
    // Khoảng cách càng lớn -> Điểm giảm dần về 0.
    // Tham số 0.05 là hệ số scale, có thể tinh chỉnh sau khi có dữ liệu thật.
    double score = 10.0 * exp(-0.05 * dtwDistance);

    // Đảm bảo điểm số luôn nằm trong giới hạn [0, 10]
    return score.clamp(0.0, 10.0);
  }
}

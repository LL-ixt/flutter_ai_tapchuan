import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ai_tapchuan/core/utils/dtw_calculator.dart';

void main() {
  group('DTWCalculator Tests', () {
    test('calculateDTWDistance trả về 0 cho 2 chuỗi giống hệt nhau', () {
      final seq1 = [1.0, 2.0, 3.0, 4.0];
      final seq2 = [1.0, 2.0, 3.0, 4.0];

      final distance = DTWCalculator.calculateDTWDistance(seq1, seq2);
      expect(distance, 0.0);
    });

    test(
      'calculateDTWDistance xử lý được 2 chuỗi bị trượt thời gian (shifted)',
      () {
        // Chuỗi 2 giống chuỗi 1 nhưng bị delay 1 nhịp ở đầu (thêm số 0.0)
        final seq1 = [1.0, 2.0, 3.0, 4.0];
        final seq2 = [0.0, 1.0, 2.0, 3.0, 4.0];

        final distance = DTWCalculator.calculateDTWDistance(seq1, seq2);

        // Nhờ DTW, thuật toán nhận diện được sự giống nhau dù bị trượt thời gian.
        // Chi phí để khớp 0.0 (seq2) với 1.0 (seq1) là 1.0. Còn lại khớp hoàn toàn (chi phí 0).
        // Tổng chi phí = 1.0
        expect(distance, 1.0);
      },
    );

    test('gradeMovement trả về 10 điểm tuyệt đối khi distance = 0', () {
      final score = DTWCalculator.gradeMovement(0.0);
      expect(score, 10.0);
    });

    test('gradeMovement trả về điểm thấp hơn khi distance cao hơn', () {
      final score1 = DTWCalculator.gradeMovement(10.0);
      final score2 = DTWCalculator.gradeMovement(50.0);

      expect(score1 < 10.0, true);
      expect(
        score2 < score1,
        true,
      ); // Khoảng cách 50 sẽ ra điểm thấp hơn so với khoảng cách 10
    });
  });
}

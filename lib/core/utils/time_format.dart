String formatTimestamp(String timestamp) {
    try {
      DateTime date;
      if (timestamp.contains('T') || timestamp.contains('-')) {
        date = DateTime.parse(timestamp).toLocal();
      } else {
        double timestampDouble = double.parse(timestamp);
        date = DateTime.fromMillisecondsSinceEpoch((timestampDouble * 1000).toInt());
      }
      String pad(int n) => n.toString().padLeft(2, '0');
      return '${pad(date.day)}/${pad(date.month)}/${date.year} ${pad(date.hour)}:${pad(date.minute)}';
    } catch (e) {
      return timestamp; // Trả về nguyên gốc nếu lỗi
    }
  }
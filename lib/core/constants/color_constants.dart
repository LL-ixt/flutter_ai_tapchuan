import 'package:flutter/material.dart';

class AppColors {
  // 🔵 Brand Colors
  static const Color primaryBlue = Color(0xFF1877F2); // Xanh FB chính
  static const Color secondaryBlueLight = Color(0xFFE7F3FF); // Nền thông báo chưa đọc
  static const Color primaryIconAction = Color(0xFF65676B); // Icon chưa active

  // ⚪ Background Colors
  static const Color scaffoldBackground = Color(0xFFF2F4F7); // Nền xám nhạt toàn app
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Nền thẻ bài viết, trắng tinh
  static const Color dividerBorder = Color(0xFFCED0D4); // Đường kẻ phân cách

  // 🟢/🔴 Semantic Colors (Màu trạng thái)
  static const Color successGreen = Color(0xFF42B72A); // Online, Tạo TK
  static const Color errorRed = Color(0xFFFA383E); // Lỗi nhập liệu
  static const Color warningYellow = Color(0xFFF5C33B); // Chờ duyệt

  // ⚫ Text Colors
  static const Color textPrimary = Color(0xFF050505); // Nội dung bài viết, tên user
  static const Color textSecondary = Color(0xFF65676B); // Thời gian đăng bài
  static const Color textDisabled = Color(0xFFBCC0C4); // Nút bị vô hiệu hóa
}
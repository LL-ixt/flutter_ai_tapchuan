import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_constants.dart';

class AppTextStyles {
  // --- HEADING ---
  // Dùng cho tiêu đề lớn, tiêu đề màn hình
  static TextStyle heading1 = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Dùng cho tên người dùng trong bài viết (Post Card)
  static TextStyle nameHeading = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // --- SUBTITLE ---
  // Dùng cho thời gian đăng bài, thông tin phụ
  static TextStyle subtitle = GoogleFonts.roboto(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // --- BODY ---
  // Nội dung bài viết chính
  static TextStyle bodyMain = GoogleFonts.roboto(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.4, // Tạo độ giãn dòng cho dễ đọc
    color: AppColors.textPrimary,
  );

  // Nội dung bình luận, text nhỏ hơn
  static TextStyle bodySmall = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  // --- BUTTON/ACTION ---
  // Chữ trên các nút bấm chính hoặc nút Like/Comment
  static TextStyle buttonText = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}
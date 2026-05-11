class AppValidators {
  // TEST CASE 3 & 6: Kiểm tra số điện thoại
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    
    // Quy định: 10 số, có số 0 ở đầu tiên
    final phoneRegex = RegExp(r'^0\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Số điện thoại không đúng định dạng (10 số, bắt đầu bằng 0)';
    }
    return null;
  }

  // TEST CASE 4 & 6: Kiểm tra mật khẩu
  static String? validatePassword(String? value, String? phoneNumber) {
    if (value == null || value.isEmpty) {
      return 'Mật khẩu không được để trống';
    }
    
    // Quy định: 6 đến 10 ký tự
    if (value.length < 6 || value.length > 10) {
      return 'Mật khẩu phải từ 6 đến 10 ký tự';
    }
    
    // Quy định: Không chứa ký tự đặc biệt
    final passRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!passRegex.hasMatch(value)) {
      return 'Mật khẩu không được chứa ký tự đặc biệt';
    }
    
    // Quy định: Không trùng với số điện thoại
    if (value == phoneNumber) {
      return 'Mật khẩu không được trùng với số điện thoại';
    }
    return null;
  }

  // TEST CASE 5: Kiểm tra loại người dùng
}
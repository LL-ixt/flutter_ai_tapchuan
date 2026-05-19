import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';

class SyncRecordScreen extends StatefulWidget {
  const SyncRecordScreen({super.key});

  @override
  State<SyncRecordScreen> createState() => _SyncRecordScreenState();
}

class _SyncRecordScreenState extends State<SyncRecordScreen> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    // Giả lập trạng thái kết nối sau 3 giây
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quay Video Đồng Bộ',
          style: AppTextStyles.heading1.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header: Trạng thái kết nối
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
            color: AppColors.surfaceWhite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isConnected) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Đang tìm thiết bị Slave...',
                    style: AppTextStyles.nameHeading.copyWith(color: AppColors.textSecondary),
                  ),
                ] else ...[
                  const Icon(Icons.check_circle, color: AppColors.successGreen, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Đã kết nối thiết bị',
                    style: AppTextStyles.nameHeading.copyWith(color: AppColors.successGreen),
                  ),
                ]
              ],
            ),
          ),
          
          // Camera View (Khung giả lập Camera chiếm phần lớn màn hình)
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: const Center(
                child: Icon(Icons.videocam, color: Colors.white54, size: 64),
              ),
            ),
          ),
          
          // Footer: Nút bấm quay Video
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_isConnected) {
                        // Logic bấm nút quay
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isConnected ? AppColors.errorRed : AppColors.dividerBorder,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _isConnected ? AppColors.errorRed : AppColors.textDisabled,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nhấn để bắt đầu quay trên cả 2 máy',
                    style: AppTextStyles.bodyMain.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

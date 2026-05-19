import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../domain/entities/student_entity.dart';

class StudentListTile extends StatelessWidget {
  final StudentEntity student;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const StudentListTile({
    super.key,
    required this.student,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.dividerBorder, width: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AvatarWidget(
            imageUrl: student.avatarUrl,
            radius: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // Subtitle 1
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tham gia: ${student.joinDate}',
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusOrActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOrActions() {
    if (student.status == 'approved') {
      return Row(
        children: const [
          Icon(Icons.check_circle, color: AppColors.successGreen, size: 16),
          SizedBox(width: 4),
          Text(
            'Đã tham gia',
            style: TextStyle(
              color: AppColors.successGreen,
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else if (student.status == 'rejected') {
      return Row(
        children: const [
          Icon(Icons.cancel, color: AppColors.errorRed, size: 16),
          SizedBox(width: 4),
          Text(
            'Đã từ chối',
            style: TextStyle(
              color: AppColors.errorRed,
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      // Pending actions
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.surfaceWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Chấp nhận', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: onReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dividerBorder.withValues(alpha: 0.3),
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text('Hủy', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      );
    }
  }
}

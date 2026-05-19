import '../../domain/entities/notification_entity.dart';

class NotificationMockData {
  static List<NotificationEntity> getMockNotifications() {
    return [
      NotificationEntity(
        id: '1',
        senderName: 'Trần Văn A',
        senderAvatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
        content: 'đã thích video bài tập nhảy của bạn.',
        time: 'Vừa xong',
        isRead: false,
        type: 'like',
      ),
      NotificationEntity(
        id: '2',
        senderName: 'Giảng viên Lê B',
        senderAvatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026024d',
        content: 'đã chấm điểm và nhận xét về bài tập Kỹ năng di chuyển của bạn.',
        time: '2 giờ trước',
        isRead: false,
        type: 'comment',
      ),
      NotificationEntity(
        id: '3',
        senderName: 'Hệ thống EduSocial',
        senderAvatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026703d',
        content: 'Khóa học "Võ thuật cơ bản" của bạn sẽ bắt đầu vào ngày mai.',
        time: '1 ngày trước',
        isRead: true,
        type: 'system',
      ),
      NotificationEntity(
        id: '4',
        senderName: 'Nguyễn Thị C',
        senderAvatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026705d',
        content: 'đã bình luận vào video của bạn: "Động tác dứt khoát quá!"',
        time: '2 ngày trước',
        isRead: true,
        type: 'comment',
      ),
    ];
  }
}

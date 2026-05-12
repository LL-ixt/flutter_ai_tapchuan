import '../../domain/entities/user_profile_entity.dart';

class ProfileMockData {
  static UserProfileEntity getCurrentUserProfile() {
    return UserProfileEntity(
      id: 'u1',
      name: 'Trần Văn A',
      avatarUrl: 'https://i.pravatar.cc/300?u=a042581f4e29026704d',
      coverUrl: 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?auto=format&fit=crop&w=1000&q=80',
      bio: 'Người yêu thích võ thuật và lập trình.',
      location: 'Hà Nội, Việt Nam',
      link: 'github.com/tranvana',
    );
  }

  static List<Map<String, dynamic>> getUserPosts() {
    return [
      {
        'id': 'p1',
        'author': {
          'id': 'u1',
          'username': 'Trần Văn A',
          'avatar': 'https://i.pravatar.cc/300?u=a042581f4e29026704d',
        },
        'created_at': 'Vừa xong',
        'described': 'Bài tập về nhà môn Di chuyển cơ bản. Cảm ơn thầy giáo đã chỉ bảo! #EduSocial',
        'mediaUrl': 'https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/360/Big_Buck_Bunny_360_10s_1MB.mp4',
        'isDualVideo': false,
        'like': '15',
        'comment': '2',
        'isLiked': true,
      },
      {
        'id': 'p2',
        'author': {
          'id': 'u1',
          'username': 'Trần Văn A',
          'avatar': 'https://i.pravatar.cc/300?u=a042581f4e29026704d',
        },
        'created_at': '2 ngày trước',
        'described': 'Đã hoàn thành khóa học Võ thuật tự vệ cơ bản.',
        'mediaUrl': null,
        'isDualVideo': false,
        'like': '42',
        'comment': '5',
        'isLiked': false,
      },
    ];
  }
}

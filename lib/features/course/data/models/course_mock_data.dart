import '../../domain/entities/student_entity.dart';
import '../../domain/entities/course_entity.dart';

class CourseMockData {
  static List<CourseEntity> getMockRegisteredCourses() {
    return [
      CourseEntity(
        id: 'c1',
        title: 'Kỹ thuật di chuyển cơ bản',
        coverUrl: 'https://via.placeholder.com/150/1877F2/FFFFFF?text=Course+1',
        instructor: 'Giảng viên Lê B',
        progress: 45,
        instructorId: 'inst_b',
      ),
      CourseEntity(
        id: 'c2',
        title: 'Võ thuật tự vệ thực chiến',
        coverUrl: 'https://via.placeholder.com/150/42B72A/FFFFFF?text=Course+2',
        instructor: 'Võ sư Nguyễn D',
        progress: 10,
        instructorId: 'inst_d',
      ),
    ];
  }

  static List<StudentEntity> getMockStudents() {
    return [
      StudentEntity(
        id: 's1',
        name: 'Trần Văn A',
        avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026704d',
        status: 'pending',
        joinDate: '2 giờ trước',
      ),
      StudentEntity(
        id: 's2',
        name: 'Lê Thị H',
        avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026705d',
        status: 'approved',
        joinDate: 'Hôm qua',
      ),
      StudentEntity(
        id: 's3',
        name: 'Hoàng Minh M',
        avatarUrl: 'https://i.pravatar.cc/150?u=a042581f4e29026706d',
        status: 'pending',
        joinDate: '10 phút trước',
      ),
    ];
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/api_service.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../data/models/course_mock_data.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit() : super(CourseInitial());

  String? _token;
  String? _userId;
  String? _role;
  int _currentIndex = 0;
  final int _count = 10;
  bool _isFetching = false;

  void initData(String? role, String? token, String? userId) {
    _role = role;
    _token = token;
    _userId = userId;
    _currentIndex = 0;
    
    emit(CourseLoading());

    // Nếu là Học viên thì gọi API lấy danh sách khoá học, nếu là GV thì chỉ lấy mock học viên
    if (_role != 'GV') {
      _fetchCourses();
    } else {
      // Role Giáo viên, hiện tại vẫn load mock data cho yêu cầu nhập học
      final students = CourseMockData.getMockStudents();
      emit(CourseLoaded(
        registeredCourses: [],
        students: students,
      ));
    }
  }

  Future<void> _fetchCourses() async {
    if (_token == null || _userId == null) {
      emit(CourseError(message: 'Thiếu thông tin đăng nhập.'));
      return;
    }

    try {
      final response = await ApiService.getListCoursesOfStudent(
        _token!,
        _userId!,
        _currentIndex,
        _count,
      );

      if (response['code'] == '1000') {
        final Map<String, dynamic> dataMap = response['data'] is Map ? response['data'] : {};
        final List<dynamic> data = dataMap['courses'] ?? [];
        final List<CourseEntity> newCourses = data.map((json) => CourseEntity(
          id: json['id']?.toString() ?? '',
          title: json['name'] ?? json['title'] ?? 'Khoá học không tên',
          coverUrl: json['avatar'] ?? json['coverUrl'] ?? '',
          instructor: json['instructorName'] ?? 'Giáo viên',
          progress: int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
          instructorId: json['instructorId']?.toString() ?? json['id']?.toString() ?? '',
        )).toList();

        final hasReachedMax = newCourses.length < _count;
        _currentIndex += newCourses.length;

        emit(CourseLoaded(
          registeredCourses: newCourses,
          students: [],
          hasReachedMax: hasReachedMax,
        ));
      } else {
        emit(CourseError(message: response['message'] ?? 'Lỗi khi tải khoá học.'));
      }
    } catch (e) {
      emit(CourseError(message: 'Ngoại lệ: $e'));
    }
  }

  Future<void> loadMoreCourses() async {
    if (_isFetching || _role == 'GV') return;
    
    final currentState = state;
    if (currentState is CourseLoaded && !currentState.hasReachedMax) {
      _isFetching = true;
      emit(currentState.copyWith(isLoadingMore: true));
      
      try {
        final response = await ApiService.getListCoursesOfStudent(
          _token!,
          _userId!,
          _currentIndex,
          _count,
        );

        if (response['code'] == '1000') {
          final Map<String, dynamic> dataMap = response['data'] is Map ? response['data'] : {};
          final List<dynamic> data = dataMap['courses'] ?? [];
          final List<CourseEntity> newCourses = data.map((json) => CourseEntity(
            id: json['id']?.toString() ?? '',
            title: json['name'] ?? json['title'] ?? 'Khoá học không tên',
            coverUrl: json['avatar'] ?? json['coverUrl'] ?? '',
            instructor: json['instructorName'] ?? 'Giáo viên',
            progress: int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
            instructorId: json['instructorId']?.toString() ?? json['id']?.toString() ?? '',
          )).toList();

          final hasReachedMax = newCourses.length < _count;
          _currentIndex += newCourses.length;

          emit(currentState.copyWith(
            registeredCourses: List.of(currentState.registeredCourses)..addAll(newCourses),
            hasReachedMax: hasReachedMax,
            isLoadingMore: false,
          ));
        } else {
          emit(currentState.copyWith(isLoadingMore: false));
        }
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      } finally {
        _isFetching = false;
      }
    }
  }

  void approveStudent(String studentId) {
    if (state is CourseLoaded) {
      final currentState = state as CourseLoaded;
      final updatedStudents = currentState.students.map((student) {
        if (student.id == studentId) {
          return student.copyWith(status: 'approved');
        }
        return student;
      }).toList();
      
      emit(currentState.copyWith(students: updatedStudents));
    }
  }

  void rejectStudent(String studentId) {
    if (state is CourseLoaded) {
      final currentState = state as CourseLoaded;
      final updatedStudents = currentState.students.map((student) {
        if (student.id == studentId) {
          return student.copyWith(status: 'rejected');
        }
        return student;
      }).toList();
      
      emit(currentState.copyWith(students: updatedStudents));
    }
  }
}

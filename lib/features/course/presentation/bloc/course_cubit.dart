import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/course_entity.dart';
import '../../data/models/course_mock_data.dart';

part 'course_state.dart';

class CourseCubit extends Cubit<CourseState> {
  CourseCubit() : super(CourseInitial());

  void loadCourseData() {
    emit(CourseLoading());
    try {
      final courses = CourseMockData.getMockRegisteredCourses();
      final students = CourseMockData.getMockStudents();
      
      emit(CourseLoaded(
        registeredCourses: courses,
        students: students,
      ));
    } catch (e) {
      emit(CourseError(message: e.toString()));
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
      
      emit(CourseLoaded(
        registeredCourses: currentState.registeredCourses,
        students: updatedStudents,
      ));
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
      
      emit(CourseLoaded(
        registeredCourses: currentState.registeredCourses,
        students: updatedStudents,
      ));
    }
  }
}

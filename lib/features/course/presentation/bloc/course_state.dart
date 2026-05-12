part of 'course_cubit.dart';

abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<CourseEntity> registeredCourses;
  final List<StudentEntity> students;

  CourseLoaded({
    required this.registeredCourses,
    required this.students,
  });
}

class CourseError extends CourseState {
  final String message;

  CourseError({required this.message});
}

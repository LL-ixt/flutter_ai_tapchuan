part of 'course_cubit.dart';

abstract class CourseState {}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<CourseEntity> registeredCourses;
  final List<StudentEntity> students;
  final bool hasReachedMax;
  final bool isLoadingMore;

  CourseLoaded({
    required this.registeredCourses,
    required this.students,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
  });

  CourseLoaded copyWith({
    List<CourseEntity>? registeredCourses,
    List<StudentEntity>? students,
    bool? hasReachedMax,
    bool? isLoadingMore,
  }) {
    return CourseLoaded(
      registeredCourses: registeredCourses ?? this.registeredCourses,
      students: students ?? this.students,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CourseError extends CourseState {
  final String message;

  CourseError({required this.message});
}

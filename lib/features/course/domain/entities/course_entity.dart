class CourseEntity {
  final String id;
  final String title;
  final String coverUrl;
  final String instructor;
  final int progress; // 0 to 100
  final String instructorId;

  CourseEntity({
    required this.id,
    required this.title,
    required this.coverUrl,
    required this.instructor,
    required this.progress,
    required this.instructorId,
  });
}

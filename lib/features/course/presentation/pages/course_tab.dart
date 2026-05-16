import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/course_request_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../bloc/course_cubit.dart';
import '../widgets/student_list_tile.dart';

class CourseTab extends StatelessWidget {
  const CourseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseCubit()..loadCourseData(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceWhite,
            elevation: 0,
            title: const Text(
              'Khóa học',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            bottom: const TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              tabs: [
                Tab(text: 'Yêu cầu học'),
                Tab(text: 'Đã đăng ký'),
                
              ],
            ),
          ),
          body: BlocBuilder<CourseCubit, CourseState>(
            builder: (context, state) {
              if (state is CourseLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CourseError) {
                return Center(child: Text(state.message));
              } else if (state is CourseLoaded) {
                return TabBarView(
                  children: [
                    const CourseRequestTab(),
                    _buildRegisteredCourses(state.registeredCourses),
                    
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredCourses(List courses) {
    if (courses.isEmpty) {
      return const Center(child: Text('Bạn chưa đăng ký khóa học nào.'));
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    course.coverUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.dividerBorder,
                      child: const Icon(Icons.book),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course.instructor,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: course.progress / 100,
                        backgroundColor: AppColors.dividerBorder,
                        color: AppColors.primaryBlue,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tiến độ: ${course.progress}%',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudentList(BuildContext context, List students) {
    if (students.isEmpty) {
      return const Center(child: Text('Chưa có học viên nào.'));
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentListTile(
          student: student,
          onApprove: () {
            context.read<CourseCubit>().approveStudent(student.id);
          },
          onReject: () {
            context.read<CourseCubit>().rejectStudent(student.id);
          },
        );
      },
    );
  }
}

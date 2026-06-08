import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/course_request_tab.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/search_teacher_tab.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/teacher_assignments_tab.dart';
import 'package:flutter_ai_tapchuan/features/course/presentation/pages/student_assignment_stats_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/course_cubit.dart';

class CourseTab extends StatefulWidget {
  const CourseTab({super.key});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> {
  final ScrollController _scrollController = ScrollController();
  late CourseCubit _courseCubit;

  @override
  void initState() {
    super.initState();
    _courseCubit = CourseCubit();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      _courseCubit.initData(authState.role, authState.token, authState.userId);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _courseCubit.loadMoreCourses();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _courseCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthCubit>().state.role;
    final isTeacher = role == 'GV';

    return BlocProvider.value(
      value: _courseCubit,
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
            bottom: TabBar(
              labelColor: AppColors.primaryBlue,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primaryBlue,
              tabs: [
                Tab(text: isTeacher ? 'Yêu cầu học' : 'Tìm giáo viên'),
                Tab(text: isTeacher ? 'Thống kê các bài tập' : 'Đã đăng ký'),
              ],
            ),
          ),
          body: BlocBuilder<CourseCubit, CourseState>(
            builder: (context, state) {
              if (state is CourseLoading || state is CourseInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CourseError) {
                return Center(child: Text(state.message));
              } else if (state is CourseLoaded) {
                return TabBarView(
                  children: [
                    isTeacher 
                        ? const CourseRequestTab() 
                        : const SearchTeacherTab(),
                    isTeacher 
                        ? const TeacherAssignmentsTab()
                        : _buildRegisteredCourses(state),
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

  Widget _buildRegisteredCourses(CourseLoaded state) {
    final courses = state.registeredCourses;
    if (courses.isEmpty) {
      return const Center(child: Text('Bạn chưa đăng ký khóa học nào.'));
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: courses.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= courses.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final course = courses[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentAssignmentStatsScreen(
                    instructorId: course.instructorId,
                    instructorName: course.instructor,
                    courseId: course.id,
                    courseName: course.title,
                  ),
                ),
              );
            },
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
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


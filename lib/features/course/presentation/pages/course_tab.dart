import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/constants/text_style_constants.dart';
import '../../../../core/widgets/avatar_widget.dart';

class CourseTab extends StatelessWidget {
  const CourseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0.5,
          title: Text('Khóa học', style: AppTextStyles.heading1),
          centerTitle: false,
          bottom: TabBar(
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primaryBlue,
            labelStyle: AppTextStyles.nameHeading,
            tabs: const [
              Tab(text: 'Đã đăng ký'),
              Tab(text: 'Học viên'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _RegisteredCoursesView(),
            _StudentRequestsView(),
          ],
        ),
      ),
    );
  }
}

class _RegisteredCoursesView extends StatelessWidget {
  const _RegisteredCoursesView();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockCourses = List.generate(5, (index) {
      return {
        "title": "Khóa học Lập trình Flutter Thực chiến - Phần ${index + 1}",
        "teacher": "Giảng viên: Trần Văn B",
        "time": "Khai giảng: 12/0${index + 1}/2026",
        "status": index % 2 == 0 ? "Đang học" : "Đã hoàn thành",
        "image": "https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=300&auto=format&fit=crop"
      };
    });

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: mockCourses.length,
      itemBuilder: (context, index) {
        final course = mockCourses[index];
        final isCompleted = course["status"] == "Đã hoàn thành";
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ]
          ),
          child: Row(
            children: [
              // Ảnh khóa học
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  course["image"]!,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              // Thông tin
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course["title"]!,
                        style: AppTextStyles.nameHeading,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(course["teacher"]!, style: AppTextStyles.subtitle),
                      const SizedBox(height: 2),
                      Text(course["time"]!, style: AppTextStyles.subtitle),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted ? AppColors.scaffoldBackground : AppColors.secondaryBlueLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course["status"]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? AppColors.textSecondary : AppColors.primaryBlue,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class _StudentRequestsView extends StatefulWidget {
  const _StudentRequestsView();

  @override
  State<_StudentRequestsView> createState() => _StudentRequestsViewState();
}

class _StudentRequestsViewState extends State<_StudentRequestsView> {
  late List<Map<String, dynamic>> mockRequests;

  @override
  void initState() {
    super.initState();
    mockRequests = List.generate(8, (index) {
      return {
        "id": "req_$index",
        "name": "Học viên đăng ký $index",
        "course": "Lập trình Flutter Thực chiến",
        "avatar": "https://i.pravatar.cc/150?u=req_$index",
        "status": "pending", // pending, accepted, rejected
      };
    });
  }

  void _handleRequest(int index, String status) {
    setState(() {
      mockRequests[index]["status"] = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: mockRequests.length,
      itemBuilder: (context, index) {
        final req = mockRequests[index];
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarWidget(imageUrl: req["avatar"], radius: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req["name"], style: AppTextStyles.nameHeading),
                    const SizedBox(height: 4),
                    Text("Đăng ký khóa: ${req["course"]}", style: AppTextStyles.subtitle),
                    const SizedBox(height: 12),
                    
                    if (req["status"] == "pending")
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleRequest(index, "accepted"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text('Chấp nhận'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _handleRequest(index, "rejected"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.scaffoldBackground,
                                foregroundColor: AppColors.textPrimary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              child: const Text('Từ chối'),
                            ),
                          ),
                        ],
                      )
                    else if (req["status"] == "accepted")
                      Text('Đã chấp nhận', style: AppTextStyles.subtitle.copyWith(color: AppColors.successGreen, fontWeight: FontWeight.bold))
                    else
                      Text('Đã từ chối', style: AppTextStyles.subtitle.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

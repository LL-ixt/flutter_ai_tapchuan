import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../services/api_service.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../feed/data/models/get_list_posts_models.dart';

class StudentAssignmentStatsScreen extends StatefulWidget {
  final String instructorId;
  final String instructorName;
  final String courseId;
  final String courseName;

  const StudentAssignmentStatsScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<StudentAssignmentStatsScreen> createState() =>
      _StudentAssignmentStatsScreenState();
}

class _StudentAssignmentStatsScreenState
    extends State<StudentAssignmentStatsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<StudentAssignmentStat> _allStats = [];
  List<StudentAssignmentStat> _filteredStats = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _searchController.addListener(_filterStats);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authState = context.read<AuthCubit>().state;
      final token = authState.token ?? '';
      final myUserId = authState.userId ?? '';

      // Gọi đồng thời lấy bài đăng của giảng viên và bài đăng của học viên
      final results = await Future.wait([
        ApiService.getListPosts(
          GetListPostsRequest(
            token: token,
            userId: widget.instructorId,
            index: '0',
            count: '50',
          ),
        ),
        ApiService.getListPosts(
          GetListPostsRequest(
            token: token,
            userId: myUserId,
            index: '0',
            count: '100',
          ),
        ),
      ]);

      final GetListPostsResponse teacherPostsRes = results[0] as GetListPostsResponse;
      final GetListPostsResponse studentPostsRes = results[1] as GetListPostsResponse;

      if (!mounted) return;

      List<dynamic> teacherPosts = [];
      if (teacherPostsRes.code == '1000' || teacherPostsRes.code == '200') {
        teacherPosts = teacherPostsRes.posts ?? [];
      } else {
        final msg = teacherPostsRes.message.toLowerCase();
        if (!msg.contains('no data')) {
          throw Exception(
            teacherPostsRes.message.isNotEmpty
                ? teacherPostsRes.message
                : 'Không thể tải danh sách bài tập của giảng viên.',
          );
        }
      }

      List<dynamic> studentPosts = [];
      if (studentPostsRes.code == '1000' || studentPostsRes.code == '200') {
        studentPosts = studentPostsRes.posts ?? [];
      } else {
        final msg = studentPostsRes.message.toLowerCase();
        if (!msg.contains('no data')) {
          throw Exception(
            studentPostsRes.message.isNotEmpty
                ? studentPostsRes.message
                : 'Không thể tải lịch sử nộp bài của học viên.',
          );
        }
      }

      final List<StudentAssignmentStat> stats = [];

      for (var post in teacherPosts) {
        final described = post['described']?.toString() ?? '';
        if (described.trim().isEmpty) continue;

        // Trích xuất tên bài tập
        String assignmentName = described.split('\n').first.trim();
        if (assignmentName.length > 50) {
          assignmentName = '${assignmentName.substring(0, 47)}...';
        }

        final createdTime = post['created']?.toString() ?? 'Không rõ';

        // Lọc bài nộp của học viên khớp với bài tập này
        final matches = studentPosts.where((sp) {
          final spDesc = sp['described']?.toString() ?? '';
          return spDesc.toLowerCase().contains(assignmentName.toLowerCase()) &&
              spDesc.toLowerCase().contains('giảng viên:');
        }).toList();

        final submissionCount = matches.length;
        final latestTime = submissionCount > 0
            ? (matches.first['created']?.toString() ?? 'Vừa xong')
            : 'Chưa nộp';

        stats.add(
          StudentAssignmentStat(
            assignmentName: assignmentName,
            publishTime: createdTime,
            isSubmitted: submissionCount > 0,
            submissionCount: submissionCount,
            latestSubmissionTime: latestTime,
            score: '-',
          ),
        );
      }

      setState(() {
        _allStats = stats;
        _filteredStats = List.from(_allStats);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Lỗi thống kê: $e';
        _isLoading = false;
      });
    }
  }

  void _filterStats() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredStats = List.from(_allStats);
      } else {
        _filteredStats = _allStats
            .where((stat) =>
                stat.assignmentName.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thống kê bài tập',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: _fetchStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue,
                ),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchStats,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: const Text(
                            'Thử lại',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Teacher details header card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                            child: const Icon(
                              Icons.person,
                              color: AppColors.primaryBlue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.instructorName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.courseName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm bài tập theo tên...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.surfaceWhite,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Stats Table
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _filteredStats.isEmpty
                            ? const Center(
                                child: Text(
                                  'Không có bài tập nào.',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Table(
                                    columnWidths: const {
                                      0: FlexColumnWidth(2.5), // Tên bài tập
                                      1: FlexColumnWidth(2.0), // Thời gian đăng
                                      2: FlexColumnWidth(1.8), // Trạng thái nộp bài
                                      3: FlexColumnWidth(1.5), // Số lần nộp
                                      4: FlexColumnWidth(2.2), // Thời gian nộp gần nhất
                                      5: FlexColumnWidth(1.0), // Điểm
                                    },
                                    defaultVerticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    border: TableBorder(
                                      horizontalInside: BorderSide(
                                        color: Colors.grey.shade100,
                                        width: 1,
                                      ),
                                    ),
                                    children: [
                                      // Header Row
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                        ),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              'Tên bài tập',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              'Thời gian đăng',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              'Trạng thái nộp',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              'Số lần nộp',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              'Nộp gần nhất',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              'Điểm',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                                fontSize: 12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Data Rows
                                      ..._filteredStats.map((stat) {
                                        return TableRow(
                                          children: [
                                            // Tên bài tập
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 10.0,
                                              ),
                                              child: Text(
                                                stat.assignmentName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            // Thời gian đăng
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 10.0,
                                              ),
                                              child: Text(
                                                stat.publishTime,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            // Trạng thái nộp bài
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 8.0,
                                              ),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: stat.isSubmitted
                                                      ? Colors.green.shade50
                                                      : Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  stat.isSubmitted ? 'Đã nộp' : 'Chưa nộp',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: stat.isSubmitted
                                                        ? Colors.green.shade700
                                                        : Colors.red.shade700,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Số lần nộp
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 10.0,
                                              ),
                                              child: Text(
                                                '${stat.submissionCount} lần',
                                                style: const TextStyle(
                                                  color: AppColors.textPrimary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            // Thời gian nộp gần nhất
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 10.0,
                                              ),
                                              child: Text(
                                                stat.latestSubmissionTime,
                                                style: TextStyle(
                                                  color: stat.isSubmitted
                                                      ? AppColors.textPrimary
                                                      : AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                            // Điểm
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 10.0,
                                              ),
                                              child: Text(
                                                stat.score,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class StudentAssignmentStat {
  final String assignmentName;
  final String publishTime;
  final bool isSubmitted;
  final int submissionCount;
  final String latestSubmissionTime;
  final String score;

  StudentAssignmentStat({
    required this.assignmentName,
    required this.publishTime,
    required this.isSubmitted,
    required this.submissionCount,
    required this.latestSubmissionTime,
    required this.score,
  });
}

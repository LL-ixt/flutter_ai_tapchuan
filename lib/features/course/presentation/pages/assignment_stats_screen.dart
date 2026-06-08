import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../services/api_service.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../post/data/models/comment_models.dart';

class StudentStat {
  final String id;
  final String name;
  final String avatar;
  int submissionCount;
  String latestSubmissionTime;
  String score;

  StudentStat({
    required this.id,
    required this.name,
    required this.avatar,
    this.submissionCount = 0,
    this.latestSubmissionTime = 'Chưa nộp',
    this.score = '-',
  });
}

class AssignmentStatsScreen extends StatefulWidget {
  final String postId;
  final String postDescribed;

  const AssignmentStatsScreen({
    super.key,
    required this.postId,
    required this.postDescribed,
  });

  @override
  State<AssignmentStatsScreen> createState() => _AssignmentStatsScreenState();
}

class _AssignmentStatsScreenState extends State<AssignmentStatsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<StudentStat> _allStats = [];
  List<StudentStat> _filteredStats = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredStats = List.from(_allStats);
      } else {
        _filteredStats = _allStats
            .where((stat) => stat.name.toLowerCase().contains(query))
            .toList();
      }
    });
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
      final teacherId = authState.userId ?? '';

      // Gọi đồng thời cả 2 API
      final results = await Future.wait([
        ApiService.getListStudents(token, 0, 100),
        ApiService.getComment(
          GetCommentRequest(
            token: token,
            id: widget.postId,
            userId: teacherId,
            index: '0',
            count: '100',
          ),
        ),
      ]);

      final Map<String, dynamic> studentsRes =
          results[0] as Map<String, dynamic>;
      final GetCommentResponse commentsRes = results[1] as GetCommentResponse;

      if (!mounted) return;

      // Xử lý danh sách học viên
      List<dynamic> studentList = [];
      if (studentsRes['code'] == '1000' && studentsRes['data'] != null) {
        studentList = studentsRes['data']['students'] ?? [];
      } else if (studentsRes['code'] != '1000') {
        final msg = studentsRes['message']?.toString().toLowerCase() ?? '';
        if (msg.contains('no data')) {
          studentList = [];
        } else {
          throw Exception(
            studentsRes['message'] ?? 'Không thể tải danh sách học viên.',
          );
        }
      }

      // Xử lý danh sách bình luận
      List<CommentItemModel> commentsList = [];
      if (commentsRes is GetCommentResponse) {
        if (commentsRes.code == '1000' || commentsRes.code == '200') {
          commentsList = commentsRes.data ?? [];
        } else {
          final msg = commentsRes.message.toLowerCase();
          if (msg.contains('no data')) {
            commentsList = [];
          } else {
            throw Exception(
              commentsRes.message.isNotEmpty
                  ? commentsRes.message
                  : 'Không thể tải bình luận bài viết.',
            );
          }
        }
      }

      // Khởi tạo Map thống kê
      final Map<String, StudentStat> statsMap = {};
      for (var s in studentList) {
        final id = s['id']?.toString() ?? '';
        final name = s['user_name'] ?? s['name'] ?? 'Không tên';
        final avatar = s['avatar']?.toString() ?? '';
        statsMap[id] = StudentStat(
          id: id,
          name: name,
          avatar: avatar.isNotEmpty ? avatar : 'https://i.pravatar.cc/150',
        );
      }

      // Đếm số lần nộp bài dựa trên nội dung comment
      for (var c in commentsList) {
        final posterId = c.poster.id;
        final posterName = c.poster.name;
        final commentText = c.comment;
        final createdTime = c.created;

        // Chỉ đếm comment nộp bài
        if (commentText.contains('Đã nộp bài tập bài viết này')) {
          StudentStat? stat = statsMap[posterId];
          if (stat == null && posterName.isNotEmpty) {
            // Tìm kiếm fallback bằng tên
            try {
              stat = statsMap.values.firstWhere(
                (element) =>
                    element.name.toLowerCase() == posterName.toLowerCase(),
              );
            } catch (_) {
              stat = null;
            }
          }

          if (stat != null) {
            stat.submissionCount++;
            stat.latestSubmissionTime = createdTime;
          }
        }
      }

      setState(() {
        _allStats = statsMap.values.toList();
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
          'Thống kê nộp bài',
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
                // Post Description Card
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.assignment,
                            color: AppColors.primaryBlue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Nội dung bài tập',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.postDescribed,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
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
                      hintText: 'Tìm học viên theo tên...',
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
                        ? Center(
                            child: Text(
                              _allStats.isEmpty
                                  ? 'Không có học viên nào đăng ký.'
                                  : 'Không tìm thấy học viên tương thích.',
                              style: const TextStyle(
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
                                  0: FlexColumnWidth(3.0), // Tên học viên
                                  1: FlexColumnWidth(2.0), // Số lần nộp
                                  2: FlexColumnWidth(
                                    3.5,
                                  ), // Thời gian nộp gần nhất
                                  3: FlexColumnWidth(1.5), // Điểm
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
                                          horizontal: 16.0,
                                        ),
                                        child: Text(
                                          'Tên học viên',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 16.0,
                                        ),
                                        child: Text(
                                          'Số lần nộp',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 16.0,
                                        ),
                                        child: Text(
                                          'Thời gian nộp gần nhất',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.0,
                                          horizontal: 16.0,
                                        ),
                                        child: Text(
                                          'Điểm',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Data Rows
                                  ..._filteredStats.map((stat) {
                                    final bool hasSubmitted =
                                        stat.submissionCount > 0;
                                    return TableRow(
                                      children: [
                                        // Tên học viên
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                            horizontal: 16.0,
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundImage: NetworkImage(
                                                  stat.avatar,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  stat.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Số lần nộp
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                            horizontal: 16.0,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: hasSubmitted
                                                    ? Colors.green.shade50
                                                    : Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                hasSubmitted
                                                    ? '${stat.submissionCount} lần'
                                                    : 'Chưa nộp',
                                                style: TextStyle(
                                                  color: hasSubmitted
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Thời gian nộp gần nhất
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                            horizontal: 16.0,
                                          ),
                                          child: Text(
                                            stat.latestSubmissionTime,
                                            style: TextStyle(
                                              color: hasSubmitted
                                                  ? AppColors.textPrimary
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        // Điểm
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12.0,
                                            horizontal: 16.0,
                                          ),
                                          child: Text(
                                            stat.score,
                                            style: const TextStyle(
                                              color: AppColors.textSecondary,
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

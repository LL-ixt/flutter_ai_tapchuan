import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/core/constants/color_constants.dart';
import '../../../feed/presentation/pages/home_screen.dart';
import '../../../course/presentation/pages/course_tab.dart';
import '../../../notification/presentation/pages/notification_tab.dart';
import '../../../profile/presentation/pages/profile_screen.dart';
import '../../../main/presentation/pages/menu_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  String _unreadNotifications = '0';
  String _unreadMessages = '0';

  @override
  void initState() {
    super.initState();
    _checkNewVersion();
  }

  Future<void> _checkNewVersion() async {
    final token = context.read<AuthCubit>().state.token ?? '';
    final userId = context.read<AuthCubit>().state.userId ?? '';
    final lastUpdate = '1.0.0'; // Hardcode app version current

    if (token.isEmpty) return;

    final response = await ApiService.checkNewVersion(
      token: token,
      lastUpdate: lastUpdate,
      userId: userId,
    );

    if (mounted && response['code'] == '1000') {
      final data = response['data'];
      if (data != null) {
        final user = data['user'];
        if (user != null) {
          final isActive = user['active'] == '1' || user['active'] == true;
          if (!isActive) {
            // Tài khoản bị khóa, force logout
            if (context.mounted) {
              context.read<AuthCubit>().logout();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tài khoản của bạn đã bị khóa hoặc vô hiệu hóa.')),
              );
            }
            return;
          }
        }

        setState(() {
          _unreadNotifications = data['badge']?.toString() ?? '0';
          _unreadMessages = data['unread_message']?.toString() ?? '0';
        });

        final versionData = data['version'];
        if (versionData != null) {
          final isRequired = versionData['required'] == '1' || versionData['required'] == true;
          final updateUrl = versionData['url']?.toString() ?? '';
          
          // Giả sử version mới khác version hiện tại (đơn giản hoá việc so sánh)
          if (versionData['version'] != null && versionData['version'] != lastUpdate) {
            _showUpdateDialog(
              isRequired: isRequired,
              url: updateUrl,
            );
          }
        }
      }
    }
  }

  void _showUpdateDialog({required bool isRequired, required String url}) {
    showDialog(
      context: context,
      barrierDismissible: !isRequired, // Không cho tắt nếu bắt buộc cập nhật
      builder: (context) {
        return PopScope(
          canPop: !isRequired,
          child: AlertDialog(
            title: const Text('Cập nhật phiên bản mới'),
            content: const Text('Đã có phiên bản mới của ứng dụng. Vui lòng cập nhật để có trải nghiệm tốt nhất.'),
            actions: [
              if (!isRequired)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
                ),
              ElevatedButton(
                onPressed: () async {
                  if (url.isNotEmpty) {
                    final uri = Uri.parse(url);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Không thể mở link tải ứng dụng')),
                        );
                      }
                    }
                  }
                },
                child: const Text('Cập nhật ngay'),
              ),
            ],
          ),
        );
      },
    );
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CourseTab(),
    const NotificationTab(),
    const ProfileScreen(),
    const MenuScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceWhite,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle_fill),
            label: 'Khóa học',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: _unreadNotifications != '0',
              label: Text(_unreadNotifications),
              child: const Icon(Icons.notifications_none),
            ),
            activeIcon: Badge(
              isLabelVisible: _unreadNotifications != '0',
              label: Text(_unreadNotifications),
              child: const Icon(Icons.notifications),
            ),
            label: 'Thông báo',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            activeIcon: Icon(Icons.menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}

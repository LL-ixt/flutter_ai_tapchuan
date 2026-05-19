import 'package:flutter/material.dart';
import 'package:flutter_ai_tapchuan/features/search/search_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/color_constants.dart';
import '../bloc/notification_cubit.dart';
import '../widgets/notification_tile.dart';

class NotificationTab extends StatelessWidget {
  const NotificationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationCubit()..loadNotifications(),
      child: Scaffold(
        backgroundColor: AppColors.surfaceWhite,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
          title: const Text(
            'Thông báo',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.textPrimary),
              onPressed: () {
                // Lệnh phóng sang trang Tìm Kiếm
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage()));
              },
            ),
          ],
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: AppColors.errorRed),
                ),
              );
            } else if (state is NotificationLoaded) {
              final notifications = state.notifications;
              
              if (notifications.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có thông báo nào.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationCubit>().loadNotifications();
                },
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationTile(
                      notification: notification,
                      onTap: () {
                        context
                            .read<NotificationCubit>()
                            .markAsRead(notification.id);
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ai_tapchuan/services/api_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/models/notification_mock_data.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final String? token;

  NotificationCubit({this.token}) : super(NotificationInitial());

  Future<void> loadNotifications() async {
    emit(NotificationLoading());
    try {
      final currentToken = token;
      if (currentToken == null || currentToken.isEmpty) {
        final notifications = NotificationMockData.getMockNotifications();
        emit(NotificationLoaded(notifications: notifications));
        return;
      }

      final result = await ApiService.getNotification(currentToken, 0, 20);
      if (result['code'] != '1000') {
        emit(
          NotificationError(
            message: result['message'] ?? 'Không thể tải thông báo',
          ),
        );
        return;
      }

      final notifications = _parseNotifications(result['data']);
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  Future<void> markAsRead(String id) async {
    final currentToken = token;
    if (currentToken != null && currentToken.isNotEmpty) {
      await ApiService.setReadNotification(currentToken, id);
    }

    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = currentState.notifications.map((notif) {
        if (notif.id == id) {
          return notif.copyWith(isRead: true);
        }
        return notif;
      }).toList();

      emit(NotificationLoaded(notifications: updatedNotifications));
    }
  }

  Future<void> markAllAsRead() async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final currentToken = token;
      if (currentToken != null && currentToken.isNotEmpty) {
        final unreadNotifications = currentState.notifications.where(
          (notif) => !notif.isRead,
        );
        await Future.wait(
          unreadNotifications.map(
            (notif) => ApiService.setReadNotification(currentToken, notif.id),
          ),
        );
      }

      final updatedNotifications = currentState.notifications.map((notif) {
        return notif.copyWith(isRead: true);
      }).toList();

      emit(NotificationLoaded(notifications: updatedNotifications));
    }
  }

  List<NotificationEntity> _parseNotifications(dynamic data) {
    final rawItems = _extractList(data);
    return rawItems
        .whereType<Map>()
        .map((item) => _parseNotification(Map<String, dynamic>.from(item)))
        .toList();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final nestedData = data['data'];
      if (nestedData is List) return nestedData;
      final notifications = data['notifications'];
      if (notifications is List) return notifications;
    }
    return const [];
  }

  NotificationEntity _parseNotification(Map<String, dynamic> item) {
    final sender =
        _asMap(item['sender']) ?? _asMap(item['user']) ?? _asMap(item['from']);
    final id =
        item['notificationId'] ?? item['id'] ?? item['notification_id'] ?? '';
    return NotificationEntity(
      id: id.toString(),
      senderName: _firstString([
        item['senderName'],
        item['username'],
        sender?['username'],
        sender?['name'],
      ], fallback: 'Người dùng'),
      senderAvatarUrl: _firstString([
        item['senderAvatarUrl'],
        item['avatar'],
        sender?['avatar'],
      ]),
      content: _firstString([
        item['content'],
        item['message'],
        item['title'],
        item['notification'],
      ]),
      time: _firstString([
        item['time'],
        item['created'],
        item['created_at'],
        item['updatedAt'],
        item['lastUpdate'],
      ], fallback: 'Vừa xong'),
      isRead: _isRead(item),
      type: _firstString([
        item['type'],
        item['notificationType'],
      ], fallback: 'system'),
    );
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  String _firstString(List<dynamic> values, {String fallback = ''}) {
    for (final value in values) {
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return fallback;
  }

  bool _isRead(Map<String, dynamic> item) {
    final value =
        item['isRead'] ?? item['read'] ?? item['is_read'] ?? item['status'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value == '1' ||
          value.toLowerCase() == 'true' ||
          value.toLowerCase() == 'read';
    }
    return false;
  }
}

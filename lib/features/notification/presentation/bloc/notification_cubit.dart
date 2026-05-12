import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../data/models/notification_mock_data.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  void loadNotifications() {
    emit(NotificationLoading());
    try {
      // Simulate network delay
      final notifications = NotificationMockData.getMockNotifications();
      emit(NotificationLoaded(notifications: notifications));
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }

  void markAsRead(String id) {
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

  void markAllAsRead() {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = currentState.notifications.map((notif) {
        return notif.copyWith(isRead: true);
      }).toList();
      
      emit(NotificationLoaded(notifications: updatedNotifications));
    }
  }
}

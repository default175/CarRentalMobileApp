import '../../../shared/models/app_notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> fetchNotifications();

  Future<void> dismissNotification(String notificationId);
}

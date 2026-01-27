import '../../../../shared/demo/demo_data_store.dart';
import '../../../../shared/models/app_notification.dart';
import '../../domain/notifications_repository.dart';

class FakeNotificationsRepository implements NotificationsRepository {
  FakeNotificationsRepository(this._store);

  final DemoDataStore _store;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    return _store.notifications;
  }

  @override
  Future<void> dismissNotification(String notificationId) async {
    _store.dismissNotification(notificationId);
  }
}

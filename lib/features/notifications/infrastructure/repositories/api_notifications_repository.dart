import '../../../../core/network/api_client.dart';
import '../../../../shared/models/app_notification.dart';
import '../../domain/notifications_repository.dart';

class ApiNotificationsRepository implements NotificationsRepository {
  ApiNotificationsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final response =
        await _client.dio.get<List<dynamic>>('/api/notifications');
    final items = response.data ?? const [];

    return items
        .map(
          (item) {
            final raw = Map<String, dynamic>.from(item as Map);

            return AppNotification(
            id: raw['id'] as String,
            title: raw['title'] as String,
            message: raw['message'] as String,
            type: _typeFromString(raw['type'] as String),
            createdAt: DateTime.parse(raw['created_at'] as String),
            );
          },
        )
        .toList(growable: false);
  }

  @override
  Future<void> dismissNotification(String notificationId) async {
    await _client.dio.delete<void>('/api/notifications/$notificationId');
  }

  AppNotificationType _typeFromString(String value) {
    switch (value) {
      case 'booking':
        return AppNotificationType.booking;
      case 'geofence':
        return AppNotificationType.geofence;
      case 'reminder':
        return AppNotificationType.reminder;
      case 'system':
      default:
        return AppNotificationType.system;
    }
  }
}

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../config/app_runtime_config.dart';

class PushNotificationsService {
  PushNotificationsService(this._config);

  final AppRuntimeConfig _config;
  static PushNotificationsService? _instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final Set<String> _shownLocalNotificationIds = <String>{};
  bool _localNotificationsEnabled = true;

  static PushNotificationsService? get instance => _instance;

  void setLocalNotificationsEnabled(bool enabled) {
    _localNotificationsEnabled = enabled;
  }

  Future<String?> initialize() async {
    _instance = this;

    if (!kIsWeb) {
      await _localNotifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    if (!_config.isFirebaseConfigured || kIsWeb) {
      debugPrint('FCM bootstrap skipped for current runtime.');
      return null;
    }

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    return messaging.getToken();
  }

  Future<void> showLocalNotification({
    required String notificationId,
    required String title,
    required String body,
  }) async {
    if (kIsWeb ||
        !_localNotificationsEnabled ||
        _shownLocalNotificationIds.contains(notificationId)) {
      return;
    }

    _shownLocalNotificationIds.add(notificationId);
    await _localNotifications.show(
      notificationId.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'car_rental_alerts',
          'Car rental alerts',
          channelDescription: 'Rental reminders and booking updates',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

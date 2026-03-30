import 'package:car_rental_app/bootstrap/bootstrap.dart';
import 'package:flutter/widgets.dart';

import 'app/car_rental_app.dart';
import 'core/config/app_config.dart';
import 'core/services/firebase_app_service.dart';
import 'core/services/firebase_usage_service.dart';
import 'core/services/local_app_storage.dart';
import 'core/services/mapbox_service_stub.dart'
    if (dart.library.io) 'core/services/mapbox_service.dart';
import 'core/services/push_notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final runtimeConfig = AppConfig.runtime;
  await LocalAppStorage.instance.initialize();
  await FirebaseAppService(runtimeConfig).initialize();
  await FirebaseUsageService(runtimeConfig).recordAppLaunch();
  MapboxService(runtimeConfig).initialize();
  final pushNotificationsService = PushNotificationsService(runtimeConfig)
    ..setLocalNotificationsEnabled(
      LocalAppStorage.instance.pushNotificationsEnabled,
    );
  await pushNotificationsService.initialize();

  bootstrap(() => const CarRentalApp());
}

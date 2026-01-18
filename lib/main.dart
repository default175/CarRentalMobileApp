import 'package:car_rental_app/bootstrap/bootstrap.dart';
import 'package:flutter/widgets.dart';

import 'app/car_rental_app.dart';
import 'core/config/app_config.dart';
import 'core/services/firebase_app_service.dart';
import 'core/services/local_app_storage.dart';
import 'core/services/mapbox_service_stub.dart'
    if (dart.library.io) 'core/services/mapbox_service.dart';
import 'core/services/push_notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final runtimeConfig = AppConfig.runtime;
  await LocalAppStorage.instance.initialize();
  await FirebaseAppService(runtimeConfig).initialize();
  MapboxService(runtimeConfig).initialize();
  await PushNotificationsService(runtimeConfig).initialize();

  bootstrap(() => const CarRentalApp());
}

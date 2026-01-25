import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/app_runtime_config.dart';
import '../config/firebase_options.dart';

class FirebaseAppService {
  FirebaseAppService(this._config);

  final AppRuntimeConfig _config;

  bool get isEnabled => _config.isFirebaseConfigured;

  Future<void> initialize() async {
    if (!isEnabled) {
      debugPrint('Firebase bootstrap skipped: missing runtime config.');
      return;
    }

    if (Firebase.apps.isNotEmpty) {
      return;
    }

    await Firebase.initializeApp(
      options: AppFirebaseOptions.fromRuntimeConfig(_config),
    );
  }
}

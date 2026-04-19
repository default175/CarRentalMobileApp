import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../config/app_runtime_config.dart';

class FirebaseUsageService {
  FirebaseUsageService(this._config);

  final AppRuntimeConfig _config;

  bool get isEnabled => _config.isRealtimeDatabaseConfigured;

  Future<void> recordAppLaunch() async {
    if (!isEnabled) {
      return;
    }

    try {
      final database = FirebaseDatabase.instance;
      await database.ref('runtime/app_launches').push().set({
        'project': _config.firebaseProjectId,
        'platform': defaultTargetPlatform.name,
        'web': kIsWeb,
        'createdAt': ServerValue.timestamp,
      });
      await database.ref('runtime/last_launch').set({
        'project': _config.firebaseProjectId,
        'platform': defaultTargetPlatform.name,
        'web': kIsWeb,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (error) {
      debugPrint('Firebase runtime event skipped: $error');
    }
  }
}

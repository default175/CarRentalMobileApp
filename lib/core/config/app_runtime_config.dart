import 'package:flutter/foundation.dart';

class AppRuntimeConfig {
  const AppRuntimeConfig._({
    required this.apiBaseUrl,
    required this.enableBackendApi,
    required this.mapboxAccessToken,
    required this.firebaseApiKey,
    required this.firebaseAppId,
    required this.firebaseMessagingSenderId,
    required this.firebaseProjectId,
    required this.firebaseDatabaseUrl,
    required this.firebaseStorageBucket,
    required this.firebaseAuthDomain,
  });

  factory AppRuntimeConfig.fromEnvironment() {
    return const AppRuntimeConfig._(
      apiBaseUrl: String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://dev.api.carrental.local',
      ),
      enableBackendApi: bool.fromEnvironment(
        'ENABLE_BACKEND_API',
        defaultValue: false,
      ),
      mapboxAccessToken: String.fromEnvironment('MAPBOX_ACCESS_TOKEN'),
      firebaseApiKey: String.fromEnvironment('FIREBASE_API_KEY'),
      firebaseAppId: String.fromEnvironment('FIREBASE_APP_ID'),
      firebaseMessagingSenderId: String.fromEnvironment(
        'FIREBASE_MESSAGING_SENDER_ID',
      ),
      firebaseProjectId: String.fromEnvironment('FIREBASE_PROJECT_ID'),
      firebaseDatabaseUrl: String.fromEnvironment('FIREBASE_DATABASE_URL'),
      firebaseStorageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
      firebaseAuthDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
    );
  }

  final String apiBaseUrl;
  final bool enableBackendApi;
  final String mapboxAccessToken;
  final String firebaseApiKey;
  final String firebaseAppId;
  final String firebaseMessagingSenderId;
  final String firebaseProjectId;
  final String firebaseDatabaseUrl;
  final String firebaseStorageBucket;
  final String firebaseAuthDomain;

  bool get isFirebaseConfigured =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;

  bool get isRealtimeDatabaseConfigured =>
      isFirebaseConfigured && firebaseDatabaseUrl.isNotEmpty;

  bool get isMapboxConfigured => mapboxAccessToken.isNotEmpty;

  bool get shouldUseFakeRepositories => !isFirebaseConfigured;
  bool get shouldUseApiRepositories =>
      enableBackendApi &&
      (apiBaseUrl.startsWith('http://') || apiBaseUrl.startsWith('https://'));

  String get firebaseAppLabel =>
      isFirebaseConfigured ? firebaseProjectId : 'demo-mode';

  String get mapboxModeLabel =>
      isMapboxConfigured ? 'live-mapbox' : 'text-preview';

  String get runtimeModeLabel =>
      shouldUseFakeRepositories ? 'demo repositories' : 'live Firebase';

  List<String> get bootstrapWarnings {
    final warnings = <String>[];

    if (!isFirebaseConfigured) {
      warnings.add('Firebase is not fully configured. Demo auth and demo GPS are active.');
    }

    if (!isMapboxConfigured) {
      warnings.add('Mapbox token is missing. Tracking falls back to the text summary view.');
    }

    return warnings;
  }

  @override
  String toString() {
    return 'AppRuntimeConfig(firebase: $firebaseAppLabel, mapbox: $mapboxModeLabel, mode: $runtimeModeLabel, web: $kIsWeb)';
  }
}

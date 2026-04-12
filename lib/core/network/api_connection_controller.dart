import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../services/local_app_storage.dart';
import 'api_connection_settings.dart';

class ApiConnectionController extends StateNotifier<ApiConnectionSettings> {
  ApiConnectionController(this._storage)
      : super(
          ApiConnectionSettings(
            baseUrl:
                _storage.apiBaseUrlOverride ?? AppConfig.runtime.apiBaseUrl,
            enabled: _storage.backendApiEnabledOverride ??
                AppConfig.runtime.enableBackendApi,
          ),
        );

  final LocalAppStorage _storage;

  Future<void> save({
    required String baseUrl,
    required bool enabled,
  }) async {
    final normalized = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    state = ApiConnectionSettings(baseUrl: normalized, enabled: enabled);
    await _storage.saveApiConnectionSettings(
      baseUrl: normalized,
      enabled: enabled,
    );
  }

  Future<void> reset() async {
    state = ApiConnectionSettings(
      baseUrl: AppConfig.runtime.apiBaseUrl,
      enabled: AppConfig.runtime.enableBackendApi,
    );
    await _storage.clearApiConnectionSettings();
  }
}

import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import '../config/app_runtime_config.dart';

class MapboxService {
  MapboxService(this._config);

  final AppRuntimeConfig _config;

  bool get isEnabled => _config.isMapboxConfigured;

  void initialize() {
    if (!isEnabled) {
      debugPrint('Mapbox bootstrap skipped: access token is missing.');
      return;
    }

    MapboxOptions.setAccessToken(_config.mapboxAccessToken);
  }
}

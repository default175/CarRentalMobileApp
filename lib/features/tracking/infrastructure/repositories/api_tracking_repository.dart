import 'dart:async';

import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../shared/models/geo_point.dart';
import '../../../../shared/models/tracking_snapshot.dart';
import '../../domain/tracking_repository.dart';

class ApiTrackingRepository implements TrackingRepository {
  ApiTrackingRepository(this._client);

  final ApiClient _client;

  @override
  Stream<TrackingSnapshot> watchCar(String carId) async* {
    while (true) {
      final response =
          await _client.dio.get<Map<String, dynamic>>('/api/tracking/$carId');
      final raw = response.data ?? const {};

      yield TrackingSnapshot(
        carId: raw['car_id'] as String,
        position: GeoPoint(
          lat: (raw['lat'] as num).toDouble(),
          lng: (raw['lng'] as num).toDouble(),
        ),
        route: (raw['route'] as List<dynamic>? ?? const []).map(
          (item) {
            final point = Map<String, dynamic>.from(item as Map);

            return GeoPoint(
              lat: (point['lat'] as num).toDouble(),
              lng: (point['lng'] as num).toDouble(),
            );
          },
        ).toList(growable: false),
        speedKph: (raw['speed_kph'] as num).toDouble(),
        isInsideGeofence: raw['is_inside_geofence'] as bool,
        geofenceName: raw['geofence_name'] as String,
        distanceKm: (raw['distance_km'] as num).toDouble(),
        lastUpdated: DateTime.parse(raw['updated_at'] as String),
      );

      await Future<void>.delayed(
        const Duration(seconds: AppConfig.coordinateRefreshSeconds),
      );
    }
  }
}

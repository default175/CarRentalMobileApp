import 'package:firebase_database/firebase_database.dart';

import '../../../../shared/models/geo_point.dart';
import '../../../../shared/models/tracking_snapshot.dart';
import '../../domain/tracking_repository.dart';

class FirebaseTrackingRepository implements TrackingRepository {
  FirebaseTrackingRepository(this._database);

  final FirebaseDatabase _database;

  @override
  Stream<TrackingSnapshot> watchCar(String carId) {
    final ref = _database.ref('live_locations/$carId');

    return (() async* {
      yield _fallbackSnapshot(carId);
      yield* ref.onValue.map((event) {
        final rawValue = event.snapshot.value;
        if (rawValue is! Map) {
          return _fallbackSnapshot(carId);
        }

        final raw = Map<String, dynamic>.from(rawValue);
        final routeRaw = raw['route'];

        return TrackingSnapshot(
          carId: carId,
          position: GeoPoint(
            lat: (raw['lat'] as num?)?.toDouble() ?? 0,
            lng: (raw['lng'] as num?)?.toDouble() ?? 0,
          ),
          route: routeRaw is List
              ? routeRaw
                  .whereType<Map>()
                  .map(
                    (point) => GeoPoint(
                      lat: (point['lat'] as num?)?.toDouble() ?? 0,
                      lng: (point['lng'] as num?)?.toDouble() ?? 0,
                    ),
                  )
                  .toList(growable: false)
              : const [],
          speedKph: (raw['speedKph'] as num?)?.toDouble() ?? 0,
          isInsideGeofence: raw['isInsideGeofence'] as bool? ?? true,
          geofenceName: raw['geofenceName'] as String? ?? 'Unknown geofence',
          distanceKm: (raw['distanceKm'] as num?)?.toDouble() ?? 0,
          lastUpdated: DateTime.tryParse(raw['updatedAt'] as String? ?? '') ??
              DateTime.now(),
        );
      }).handleError((_, __) => _fallbackSnapshot(carId));
    })()
        .asBroadcastStream();
  }

  TrackingSnapshot _fallbackSnapshot(String carId) {
    const position = GeoPoint(lat: 43.2389, lng: 76.8897);
    return TrackingSnapshot(
      carId: carId,
      position: position,
      route: const [
        GeoPoint(lat: 43.2389, lng: 76.8897),
        GeoPoint(lat: 43.2415, lng: 76.8962),
        GeoPoint(lat: 43.2451, lng: 76.9021),
      ],
      speedKph: 0,
      isInsideGeofence: true,
      geofenceName: 'Fallback route',
      distanceKm: 0,
      lastUpdated: DateTime.now(),
    );
  }
}

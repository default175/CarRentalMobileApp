import 'dart:async';
import 'dart:math';

import '../../../../core/config/app_config.dart';
import '../../../../shared/models/geo_point.dart';
import '../../../../shared/models/tracking_snapshot.dart';
import '../../domain/tracking_repository.dart';

class FakeTrackingRepository implements TrackingRepository {
  @override
  Stream<TrackingSnapshot> watchCar(String carId) {
    const base = GeoPoint(lat: 43.2389, lng: 76.8897);
    final seed = carId.codeUnits.fold<int>(0, (sum, code) => sum + code);
    final latSeedOffset = ((seed % 17) - 8) * 0.006;
    final lngSeedOffset = (((seed ~/ 3) % 17) - 8) * 0.007;
    final carBase = base.shift(
      latOffset: latSeedOffset,
      lngOffset: lngSeedOffset,
    );

    TrackingSnapshot snapshotForTick(int tick) {
      final phase = tick.toDouble();
      final point = carBase.shift(
        latOffset: sin(phase / 3) * 0.01,
        lngOffset: cos(phase / 4) * 0.015,
      );

      return TrackingSnapshot(
        carId: carId,
        position: point,
        route: List.generate(
          min(tick + 3, 12),
          (index) => carBase.shift(
            latOffset: sin((phase - index) / 3) * 0.01,
            lngOffset: cos((phase - index) / 4) * 0.015,
          ),
        ),
        speedKph: 38 + (tick % 4) * 7,
        isInsideGeofence: tick % 5 != 4,
        geofenceName: 'Almaty south sector',
        distanceKm: 42 + tick * 1.7,
        lastUpdated: DateTime.now(),
      );
    }

    return (() async* {
      yield snapshotForTick(0);
      yield* Stream.periodic(
        const Duration(seconds: AppConfig.coordinateRefreshSeconds),
        (tick) => snapshotForTick(tick + 1),
      );
    })()
        .asBroadcastStream();
  }
}

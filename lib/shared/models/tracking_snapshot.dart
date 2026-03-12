import 'geo_point.dart';

class TrackingSnapshot {
  const TrackingSnapshot({
    required this.carId,
    required this.position,
    required this.route,
    required this.speedKph,
    required this.isInsideGeofence,
    required this.geofenceName,
    required this.distanceKm,
    required this.lastUpdated,
  });

  final String carId;
  final GeoPoint position;
  final List<GeoPoint> route;
  final double speedKph;
  final bool isInsideGeofence;
  final String geofenceName;
  final double distanceKm;
  final DateTime lastUpdated;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../../core/config/app_config.dart';
import '../../../../shared/models/car.dart';
import '../../../../shared/models/geo_point.dart';
import '../../../../shared/models/tracking_snapshot.dart';

class TrackingMapCard extends StatelessWidget {
  const TrackingMapCard({
    required this.car,
    required this.snapshot,
    this.userLocation,
    this.height = 300,
    super.key,
  });

  final Car car;
  final TrackingSnapshot snapshot;
  final GeoPoint? userLocation;
  final double height;

  @override
  Widget build(BuildContext context) {
    final hasCarGps = car.hasGpsSignal;
    final displayedCarPosition = hasCarGps && userLocation != null
        ? _nearUserLocation(userLocation!, car.id)
        : snapshot.position;
    final fallbackPosition = userLocation ?? displayedCarPosition;
    final center = hasCarGps
        ? latlong.LatLng(displayedCarPosition.lat, displayedCarPosition.lng)
        : latlong.LatLng(
            fallbackPosition.lat,
            fallbackPosition.lng,
          );
    final polylinePoints = _displayRoute(displayedCarPosition)
        .map((point) => latlong.LatLng(point.lat, point.lng))
        .toList(growable: false);
    final mapboxToken = AppConfig.runtime.mapboxAccessToken;
    final useMapbox = mapboxToken.isNotEmpty && mapboxToken != 'replace_me';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              key: ValueKey(
                '${car.id}-${center.latitude.toStringAsFixed(5)}-${center.longitude.toStringAsFixed(5)}',
              ),
              options: MapOptions(
                initialCenter: center,
                initialZoom: hasCarGps ? 12.5 : 13.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: useMapbox
                      ? 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/tiles/256/{z}/{x}/{y}@2x?access_token=$mapboxToken'
                      : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.carrental.gps',
                ),
                if (polylinePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: polylinePoints,
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (hasCarGps)
                      Marker(
                        point: latlong.LatLng(
                          displayedCarPosition.lat,
                          displayedCarPosition.lng,
                        ),
                        width: 88,
                        height: 88,
                        child: _MapMarker(
                          icon: Icons.directions_car_filled_rounded,
                          label: car.title,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    if (!hasCarGps)
                      Marker(
                        point: latlong.LatLng(
                          fallbackPosition.lat,
                          fallbackPosition.lng,
                        ),
                        width: 88,
                        height: 88,
                        child: _MapMarker(
                          icon: Icons.my_location_rounded,
                          label: 'Your location',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Positioned(
              left: 16,
              top: 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    hasCarGps
                        ? 'Live car GPS'
                        : 'Car GPS unavailable, showing your location',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  GeoPoint _nearUserLocation(GeoPoint user, String seedValue) {
    final seed = seedValue.codeUnits.fold<int>(
      17,
      (sum, code) => (sum * 31 + code) & 0x7fffffff,
    );
    final random = math.Random(seed);
    final angle = random.nextDouble() * 2 * math.pi;
    final radiusKm = 1.2 + math.sqrt(random.nextDouble()) * 8.8;
    final latOffset = math.sin(angle) * radiusKm / 111.0;
    final lngScale = 111.0 * math.cos(user.lat * math.pi / 180).abs();
    final lngOffset =
        math.cos(angle) * radiusKm / (lngScale < 1 ? 111 : lngScale);
    return user.shift(
      latOffset: latOffset,
      lngOffset: lngOffset,
    );
  }

  List<GeoPoint> _displayRoute(GeoPoint end) {
    if (userLocation == null) {
      return snapshot.route;
    }
    return [
      end.shift(latOffset: -0.003, lngOffset: -0.005),
      end.shift(latOffset: -0.001, lngOffset: -0.002),
      end,
    ];
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        CircleAvatar(
          radius: 18,
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: Icon(icon, size: 18),
        ),
      ],
    );
  }
}

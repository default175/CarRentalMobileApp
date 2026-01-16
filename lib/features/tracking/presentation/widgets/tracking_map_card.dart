import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

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
    final fallbackPosition = userLocation ?? snapshot.position;
    final center = hasCarGps
        ? latlong.LatLng(snapshot.position.lat, snapshot.position.lng)
        : latlong.LatLng(
            fallbackPosition.lat,
            fallbackPosition.lng,
          );
    final polylinePoints = snapshot.route
        .map((point) => latlong.LatLng(point.lat, point.lng))
        .toList(growable: false);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: hasCarGps ? 12.5 : 13.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                          snapshot.position.lat,
                          snapshot.position.lng,
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
                  color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    hasCarGps ? 'Live car GPS' : 'Car GPS unavailable, showing your location',
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
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
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

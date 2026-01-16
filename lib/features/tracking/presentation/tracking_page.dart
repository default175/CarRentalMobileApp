import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/info_card.dart';
import 'widgets/tracking_map_card.dart';

class TrackingPage extends ConsumerStatefulWidget {
  const TrackingPage({super.key});

  @override
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  String? _selectedCarId;

  @override
  Widget build(BuildContext context) {
    final cars = ref.watch(carsProvider);
    final locationState = ref.watch(locationAccessControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncValueWidget(
        value: cars,
        data: (items) {
          _selectedCarId ??= items.first.id;
          final selectedCar = items.firstWhere((car) => car.id == _selectedCarId);
          final tracking = ref.watch(trackingStreamProvider(selectedCar.id));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GPS and geofencing',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Track the car on a live map, see geofence status and fall back to your own position whenever a vehicle GPS signal is unavailable.',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedCar.id,
                decoration: const InputDecoration(labelText: 'Tracked vehicle'),
                items: [
                  for (final car in items)
                    DropdownMenuItem(
                      value: car.id,
                      child: Text(car.title),
                    ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCarId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AsyncValueWidget(
                  value: tracking,
                  data: (snapshot) {
                    final formatter = DateFormat('HH:mm:ss');
                    return ListView(
                      children: [
                        TrackingMapCard(
                          car: selectedCar,
                          snapshot: snapshot,
                          userLocation: locationState.currentLocation,
                        ),
                        const SizedBox(height: 12),
                        InfoCard(
                          title: 'Vehicle',
                          value: selectedCar.title,
                          subtitle: selectedCar.hasGpsSignal
                              ? 'Live vehicle GPS signal'
                              : 'Fallback to your current position',
                        ),
                        const SizedBox(height: 12),
                        InfoCard(
                          title: 'Latest point',
                          value:
                              '${snapshot.position.lat.toStringAsFixed(5)}, ${snapshot.position.lng.toStringAsFixed(5)}',
                          subtitle:
                              'Updated at ${formatter.format(snapshot.lastUpdated)}',
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InfoCard(
                                title: 'Speed',
                                value: '${snapshot.speedKph.toStringAsFixed(0)} km/h',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(
                                title: 'Geofence',
                                value: snapshot.isInsideGeofence
                                    ? 'Inside zone'
                                    : 'Violation',
                                subtitle: snapshot.geofenceName,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InfoCard(
                                title: 'Distance',
                                value: '${snapshot.distanceKm.toStringAsFixed(1)} km',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Route',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                ...snapshot.route.map(
                                  (point) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text(
                                      '${point.lat.toStringAsFixed(5)}, ${point.lng.toStringAsFixed(5)}',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

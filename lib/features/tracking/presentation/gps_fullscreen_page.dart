import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/geo_point.dart';
import '../../../shared/models/tracking_snapshot.dart';
import 'widgets/tracking_map_card.dart';

class GpsFullscreenPage extends ConsumerStatefulWidget {
  const GpsFullscreenPage({super.key});

  @override
  ConsumerState<GpsFullscreenPage> createState() => _GpsFullscreenPageState();
}

class _GpsFullscreenPageState extends ConsumerState<GpsFullscreenPage> {
  String? _selectedCarId;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser!;
    final cars = ref.watch(carsProvider);
    final bookings = ref.watch(bookingsControllerProvider);
    final locationState = ref.watch(locationAccessControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS map'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cars.when(
          data: (carItems) => bookings.when(
            data: (bookingItems) {
              final bookedCars = bookingItems
                  .where(
                    (booking) =>
                        booking.userId == user.id &&
                        (booking.status == BookingStatus.created ||
                            booking.status == BookingStatus.confirmed ||
                            booking.status == BookingStatus.active),
                  )
                  .map((booking) => carItems.where((car) => car.id == booking.carId).firstOrNull)
                  .whereType<Car>()
                  .toList(growable: false);

              if (bookedCars.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No booked car for tracking',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You do not have an active or upcoming booking right now, so the map stays on your own location.',
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TrackingMapCard(
                        car: _fallbackUserCar(locationState.currentLocation),
                        snapshot: _fallbackSnapshot(locationState.currentLocation),
                        userLocation: locationState.currentLocation,
                        height: 520,
                      ),
                    ),
                  ],
                );
              }

              final selectedCar = bookedCars.firstWhere(
                (car) => car.id == _selectedCarId,
                orElse: () => bookedCars.first,
              );
              _selectedCarId ??= selectedCar.id;
              final tracking = ref.watch(trackingStreamProvider(selectedCar.id));

              return tracking.when(
                data: (snapshot) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booked car GPS',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    if (bookedCars.length > 1) ...[
                      DropdownButtonFormField<String>(
                        initialValue: selectedCar.id,
                        decoration: const InputDecoration(labelText: 'Tracked booked car'),
                        items: bookedCars
                            .map(
                              (car) => DropdownMenuItem<String>(
                                value: car.id,
                                child: Text(car.title),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setState(() {
                            _selectedCarId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Expanded(
                      child: TrackingMapCard(
                        car: selectedCar,
                        snapshot: snapshot,
                        userLocation: locationState.currentLocation,
                        height: 520,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      selectedCar.hasGpsSignal
                          ? 'Tracking ${selectedCar.title}'
                          : 'Car GPS is offline, so your own location is used as fallback.',
                    ),
                  ],
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('GPS is unavailable right now.')),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Bookings are unavailable right now.')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Cars are unavailable right now.')),
        ),
      ),
    );
  }

  Car _fallbackUserCar(GeoPoint? userLocation) {
    final point = userLocation ?? const GeoPoint(lat: 43.2389, lng: 76.8897);
    return Car(
      id: 'user-location',
      brand: 'Your',
      model: 'Location',
      year: DateTime.now().year,
      type: 'Map',
      category: 'Map',
      pricePerHour: 0,
      status: CarStatus.available,
      location: point,
      imageUrl: '',
      batteryLevel: 0,
      rangeKm: 0,
      seats: 0,
      transmission: 'Automatic',
      color: 'Teal',
      description: 'Current device location',
      features: const [],
      hasGpsSignal: false,
    );
  }

  TrackingSnapshot _fallbackSnapshot(GeoPoint? userLocation) {
    final point = userLocation ?? const GeoPoint(lat: 43.2389, lng: 76.8897);
    return TrackingSnapshot(
      carId: 'user-location',
      position: point,
      route: const [],
      speedKph: 0,
      isInsideGeofence: true,
      geofenceName: 'User location',
      distanceKm: 0,
      lastUpdated: DateTime.now(),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

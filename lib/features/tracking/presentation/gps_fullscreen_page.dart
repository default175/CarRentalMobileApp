import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
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
    if (user.role != AppRole.admin) {
      return Scaffold(
        appBar: AppBar(title: const Text('GPS map')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Vehicle GPS is available only for administrators.'),
          ),
        ),
      );
    }

    final cars = ref.watch(carsProvider);
    final bookings =
        ref.watch(bookingsControllerProvider).valueOrNull ?? const <Booking>[];
    final locationState = ref.watch(locationAccessControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Fleet GPS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: cars.when(
          data: (carItems) {
            final rentedCarIds = bookings
                .where(_hasActiveTrackingStatus)
                .map((booking) => booking.carId)
                .toSet();
            final trackableCars = carItems
                .where((car) => rentedCarIds.contains(car.id))
                .toList(growable: false);

            if (trackableCars.isEmpty) {
              return const Center(child: Text('No rented cars to track.'));
            }

            final selectedCar = trackableCars.firstWhere(
              (car) => car.id == _selectedCarId,
              orElse: () => trackableCars.first,
            );
            _selectedCarId ??= selectedCar.id;
            final tracking = ref.watch(trackingStreamProvider(selectedCar.id));

            return tracking.when(
              data: (snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedCar.id,
                    decoration: const InputDecoration(labelText: 'Fleet car'),
                    items: trackableCars
                        .map(
                          (car) => DropdownMenuItem<String>(
                            value: car.id,
                            child: Text(
                              '${car.title} - ${_renterLabel(car, bookings)}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      setState(() {
                        _selectedCarId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TrackingMapCard(
                      car: selectedCar,
                      snapshot: snapshot,
                      userLocation: locationState.currentLocation,
                      height: 620,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedCar.hasGpsSignal
                        ? 'Live tracking: ${selectedCar.title}'
                        : 'Car GPS is offline; map falls back to device location.',
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('GPS is unavailable right now.')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Cars are unavailable right now.')),
        ),
      ),
    );
  }

  String _renterLabel(Car car, List<Booking> bookings) {
    final booking = bookings
        .where((item) => item.carId == car.id && _hasActiveTrackingStatus(item))
        .firstOrNull;
    return booking?.userName ?? 'no active renter';
  }

  bool _hasActiveTrackingStatus(Booking item) {
    return item.status == BookingStatus.created ||
        item.status == BookingStatus.confirmed ||
        item.status == BookingStatus.active;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

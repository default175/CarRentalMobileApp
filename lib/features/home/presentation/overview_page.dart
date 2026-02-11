import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/geo_point.dart';
import '../../../shared/models/tracking_snapshot.dart';
import '../../../shared/widgets/info_card.dart';
import '../../tracking/presentation/gps_fullscreen_page.dart';
import '../../tracking/presentation/widgets/tracking_map_card.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  String? _selectedTrackedCarId;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser!;
    final bookings = ref.watch(bookingsControllerProvider);
    final locationState = ref.watch(locationAccessControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [Color(0xFF0D7A6C), Color(0xFF12A996)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${user.name.split(' ').first}',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                locationState.canUseLocation
                    ? 'Your location is connected. GPS is shown for your booked cars only. Without a booking, the map stays on your own position.'
                    : 'Connect geodata to keep the map centered on your own position when you do not have an active booking.',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: bookings.when(
                data: (items) => InfoCard(
                  title: 'Upcoming trips',
                  value:
                      '${items.where((booking) => booking.userId == user.id && booking.isUpcoming).length}',
                  subtitle: 'Your confirmed and created bookings',
                ),
                loading: () => const _LoadingCard(title: 'Upcoming trips'),
                error: (_, __) => const _LoadingCard(title: 'Upcoming trips'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: bookings.when(
                data: (items) => InfoCard(
                  title: 'Rental history',
                  value:
                      '${items.where((booking) => booking.userId == user.id && booking.isHistory).length}',
                  subtitle: 'Completed and cancelled bookings',
                ),
                loading: () => const _LoadingCard(title: 'Rental history'),
                error: (_, __) => const _LoadingCard(title: 'Rental history'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: bookings.when(
                data: (items) {
                  final trackedCount = items
                      .where(
                        (booking) =>
                            booking.userId == user.id &&
                            (booking.status == BookingStatus.created ||
                                booking.status == BookingStatus.confirmed ||
                                booking.status == BookingStatus.active),
                      )
                      .map((booking) => booking.carId)
                      .toSet()
                      .length;
                  return InfoCard(
                    title: 'GPS access',
                    value: '$trackedCount',
                    subtitle: trackedCount == 0
                        ? 'No booked cars selected for tracking'
                        : 'Booked cars can be selected below',
                  );
                },
                loading: () => const _LoadingCard(title: 'GPS access'),
                error: (_, __) => const _LoadingCard(title: 'GPS access'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: bookings.when(
                data: (items) {
                  final total = items
                      .where((booking) => booking.userId == user.id)
                      .fold<double>(0, (sum, booking) => sum + booking.totalPrice);
                  return InfoCard(
                    title: 'Total spend',
                    value: total.toStringAsFixed(0),
                    subtitle: 'Across all your bookings',
                  );
                },
                loading: () => const _LoadingCard(title: 'Total spend'),
                error: (_, __) => const _LoadingCard(title: 'Total spend'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: bookings.when(
                data: (items) {
                  final upcoming = items
                      .where((booking) => booking.userId == user.id && booking.isUpcoming)
                      .toList()
                    ..sort((a, b) => a.startTime.compareTo(b.startTime));
                  final next = upcoming.isNotEmpty ? upcoming.first : null;

                  return _DashboardBlock(
                    title: 'Rental',
                    icon: Icons.calendar_month_outlined,
                    child: next == null
                        ? const Text('No upcoming booking yet. Pick a car in the catalog.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(next.carName),
                              const SizedBox(height: 8),
                              Text(DateFormat('dd.MM HH:mm').format(next.startTime)),
                              Text('Status: ${next.status.name}'),
                              const SizedBox(height: 8),
                              Text('Ends: ${DateFormat('dd.MM HH:mm').format(next.endTime)}'),
                            ],
                          ),
                  );
                },
                loading: () => const _DashboardBlock(
                  title: 'Rental',
                  icon: Icons.calendar_month_outlined,
                  child: Text('Loading...'),
                ),
                error: (_, __) => const _DashboardBlock(
                  title: 'Rental',
                  icon: Icons.calendar_month_outlined,
                  child: Text('Unavailable'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _GpsOverviewBlock(
                userId: user.id,
                selectedCarId: _selectedTrackedCarId,
                onSelectedCarChanged: (value) {
                  setState(() {
                    _selectedTrackedCarId = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GpsOverviewBlock extends ConsumerWidget {
  const _GpsOverviewBlock({
    required this.userId,
    required this.selectedCarId,
    required this.onSelectedCarChanged,
  });

  final String userId;
  final String? selectedCarId;
  final ValueChanged<String?> onSelectedCarChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider);
    final bookings = ref.watch(bookingsControllerProvider);
    final locationState = ref.watch(locationAccessControllerProvider);

    return cars.when(
      data: (carItems) => bookings.when(
        data: (bookingItems) {
          final bookedCars = bookingItems
              .where(
                (booking) =>
                    booking.userId == userId &&
                    (booking.status == BookingStatus.created ||
                        booking.status == BookingStatus.confirmed ||
                        booking.status == BookingStatus.active),
              )
              .map((booking) => carItems.where((car) => car.id == booking.carId).firstOrNull)
              .whereType<Car>()
              .toList(growable: false);

          if (bookedCars.isEmpty) {
            return _DashboardBlock(
              title: 'GPS',
              icon: Icons.gps_fixed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const GpsFullscreenPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_full),
                        label: const Text('Fullscreen'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 240,
                    child: TrackingMapCard(
                      car: _fallbackUserCar(locationState.currentLocation),
                      snapshot: _fallbackSnapshot(locationState.currentLocation),
                      userLocation: locationState.currentLocation,
                      height: 240,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('No active booking. Showing your current position only.'),
                ],
              ),
            );
          }

          final effectiveCar = bookedCars.firstWhere(
            (car) => car.id == selectedCarId,
            orElse: () => bookedCars.first,
          );
          if (selectedCarId != effectiveCar.id) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onSelectedCarChanged(effectiveCar.id);
            });
          }

          final tracking = ref.watch(trackingStreamProvider(effectiveCar.id));
          return tracking.when(
            data: (snapshot) => _DashboardBlock(
              title: 'GPS',
              icon: Icons.gps_fixed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (bookedCars.length > 1)
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: effectiveCar.id,
                            decoration: const InputDecoration(
                              labelText: 'Tracked booked car',
                            ),
                            items: bookedCars
                                .map(
                                  (car) => DropdownMenuItem<String>(
                                    value: car.id,
                                    child: Text(car.title),
                                  ),
                                )
                                .toList(growable: false),
                            onChanged: onSelectedCarChanged,
                          ),
                        )
                      else
                        const Spacer(),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const GpsFullscreenPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.open_in_full),
                        label: const Text('Fullscreen'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 240,
                    child: TrackingMapCard(
                      car: effectiveCar,
                      snapshot: snapshot,
                      userLocation: locationState.currentLocation,
                      height: 240,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    effectiveCar.hasGpsSignal
                        ? 'Tracking ${effectiveCar.title}'
                        : 'Car GPS is offline. Showing your position until the car comes online.',
                  ),
                ],
              ),
            ),
            loading: () => const _DashboardBlock(
              title: 'GPS',
              icon: Icons.gps_fixed,
              child: Text('Loading...'),
            ),
            error: (_, __) => const _DashboardBlock(
              title: 'GPS',
              icon: Icons.gps_fixed,
              child: Text('Unavailable'),
            ),
          );
        },
        loading: () => const _DashboardBlock(
          title: 'GPS',
          icon: Icons.gps_fixed,
          child: Text('Loading...'),
        ),
        error: (_, __) => const _DashboardBlock(
          title: 'GPS',
          icon: Icons.gps_fixed,
          child: Text('Unavailable'),
        ),
      ),
      loading: () => const _DashboardBlock(
        title: 'GPS',
        icon: Icons.gps_fixed,
        child: Text('Loading...'),
      ),
      error: (_, __) => const _DashboardBlock(
        title: 'GPS',
        icon: Icons.gps_fixed,
        child: Text('Unavailable'),
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

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: title,
      value: '...',
      subtitle: 'Loading',
    );
  }
}

class _DashboardBlock extends StatelessWidget {
  const _DashboardBlock({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 390,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

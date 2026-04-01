import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/car_review.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/async_value_widget.dart';

class CarDetailsPage extends ConsumerWidget {
  const CarDetailsPage({
    required this.carId,
    super.key,
  });

  final String carId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final car = ref.watch(carByIdProvider(carId));
    final bookings = ref.watch(bookingsControllerProvider);
    final favorites = ref.watch(favoriteCarIdsProvider);
    final reviews = ref.watch(carReviewsProvider);
    final isFavorite = favorites.contains(carId);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton.outlined(
            onPressed: () {
              final next = {...favorites};
              isFavorite ? next.remove(carId) : next.add(carId);
              ref.read(favoriteCarIdsProvider.notifier).state = next;
              ref.read(localAppStorageProvider).saveFavoriteCarIds(next);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFavorite
                        ? 'Removed from favorites'
                        : 'Added to favorites',
                  ),
                ),
              );
            },
            icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
          ),
          const SizedBox(width: 8),
          IconButton.outlined(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content:
                        Text('${car.valueOrNull?.title ?? 'Car'} link copied')),
              );
            },
            icon: const Icon(Icons.ios_share),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: AsyncValueWidget(
          value: car,
          data: (item) {
            if (item == null) {
              return const Center(child: Text('Car not found.'));
            }

            final schedule = (bookings.valueOrNull ?? const <Booking>[])
                .where(
                  (booking) =>
                      booking.carId == item.id &&
                      booking.status != BookingStatus.cancelled &&
                      booking.status != BookingStatus.completed,
                )
                .toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 92),
                  children: [
                    AppNetworkImage(
                      imageUrl: item.displayImageUrl,
                      height: 300,
                      width: double.infinity,
                      borderRadius: 28,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(item.brand),
                            ],
                          ),
                        ),
                        Text(
                          '${item.pricePerHour.toStringAsFixed(0)} KZT/h',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SPECIFICATIONS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).disabledColor,
                          ),
                    ),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.25,
                      children: [
                        _SpecTile(
                            icon: Icons.palette_outlined,
                            label: 'Color',
                            value: item.color),
                        _SpecTile(
                            icon: Icons.settings,
                            label: 'Gearbox',
                            value: item.transmission),
                        _SpecTile(
                            icon: Icons.event_seat_outlined,
                            label: 'Seats',
                            value: '${item.seats}'),
                        _SpecTile(
                          icon: item.isElectric
                              ? Icons.battery_charging_full
                              : Icons.local_gas_station_outlined,
                          label: item.fuelLabel,
                          value: item.energyValue,
                        ),
                        _SpecTile(
                            icon: Icons.route_outlined,
                            label: 'Range',
                            value: '${item.rangeKm} km'),
                        _SpecTile(
                            icon: Icons.calendar_month,
                            label: 'Year',
                            value: '${item.year}'),
                        _SpecTile(
                            icon: Icons.local_fire_department_outlined,
                            label: 'Fuel',
                            value: item.fuelType),
                        _SpecTile(
                            icon: Icons.speed_outlined,
                            label: 'Mileage',
                            value: '${item.mileageKm} km'),
                        _SpecTile(
                            icon: Icons.account_tree_outlined,
                            label: 'Drive',
                            value: item.drive),
                        if (item.engineVolume != null)
                          _SpecTile(
                              icon: Icons.tune,
                              label: 'Engine',
                              value: '${item.engineVolume} L'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Features',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: item.features
                          .map(
                            (feature) => Chip(
                              avatar: Icon(
                                _featureIcon(feature),
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              label: Text(feature),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 16),
                    Text('Description',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(item.description),
                    const SizedBox(height: 16),
                    _ReviewsCard(
                      reviews: reviews
                          .where((review) => review.carId == item.id)
                          .toList(),
                      onWrite: () => context
                          .push('/screens/write-review?carId=${item.id}'),
                      onViewAll: () =>
                          context.push('/screens/reviews?carId=${item.id}'),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking calendar',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 10),
                            if (schedule.isEmpty)
                              const Text('No reserved dates yet.')
                            else
                              ...schedule.map(
                                (booking) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.event_busy_outlined,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${DateFormat('dd.MM.yyyy HH:mm').format(booking.startTime)} - ${DateFormat('dd.MM.yyyy HH:mm').format(booking.endTime)}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    child: FilledButton.icon(
                      onPressed: item.status == CarStatus.maintenance
                          ? null
                          : () => context
                              .push('/screens/car-booking?carId=${item.id}'),
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        item.status == CarStatus.maintenance
                            ? 'Unavailable'
                            : 'Choose dates in catalog',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  const _SpecTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({
    required this.reviews,
    required this.onWrite,
    required this.onViewAll,
  });

  final List<CarReview> reviews;
  final VoidCallback onWrite;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final preview = reviews.take(3).toList(growable: false);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Reviews',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: onWrite,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Write'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (reviews.isEmpty)
              const Text('No reviews yet.')
            else
              ...preview.map(
                (review) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${review.rating}/5 - ${review.userName}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(review.comment),
                    ],
                  ),
                ),
              ),
            if (reviews.length > 3)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onViewAll,
                  child: Text('View all (${reviews.length})'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

IconData _featureIcon(String feature) {
  final value = feature.toLowerCase();
  if (value.contains('music') || value.contains('audio')) {
    return Icons.music_note;
  }
  if (value.contains('seat') || value.contains('interior')) {
    return Icons.event_seat;
  }
  if (value.contains('drive') || value.contains('awd')) {
    return Icons.all_inclusive;
  }
  if (value.contains('charging') || value.contains('battery')) {
    return Icons.electric_bolt;
  }
  if (value.contains('camera')) {
    return Icons.photo_camera_outlined;
  }
  return Icons.check_circle_outline;
}

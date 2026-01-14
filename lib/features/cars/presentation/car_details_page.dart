import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Car details')),
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

            return ListView(
              children: [
                if (item.imageUrl.isNotEmpty)
                  AppNetworkImage(
                    imageUrl: item.imageUrl,
                    height: 240,
                    borderRadius: 24,
                  ),
                if (item.imageUrl.isNotEmpty) const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(item.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _DetailChip(label: '${item.year}'),
                    _DetailChip(label: item.type),
                    _DetailChip(label: item.category),
                    _DetailChip(label: '${item.seats} seats'),
                    _DetailChip(label: item.transmission),
                    _DetailChip(label: item.color),
                    _DetailChip(label: '${item.batteryLevel}% battery'),
                    _DetailChip(label: '${item.rangeKm} km range'),
                    _DetailChip(
                      label:
                          '${item.pricePerHour.toStringAsFixed(0)} ${AppConstants.defaultCurrency}/hour',
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
                        Text('Features', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 12),
                        ...item.features.map(Text.new),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location and booking info',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.hasGpsSignal
                              ? 'Current position: ${item.location.lat.toStringAsFixed(4)}, ${item.location.lng.toStringAsFixed(4)}'
                              : 'Vehicle GPS is unavailable right now. The map will use the device position instead.',
                        ),
                        const SizedBox(height: 8),
                        Text('Status: ${item.status.name}'),
                        if (schedule.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Reserved dates',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ...schedule.map(
                            (booking) => Text(
                              '${DateFormat('dd.MM.yyyy HH:mm').format(booking.startTime)} - ${DateFormat('dd.MM.yyyy HH:mm').format(booking.endTime)}',
                            ),
                          ),
                        ],
                      ],
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

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(label: Text(label));
  }
}

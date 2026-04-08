import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/widgets/async_value_widget.dart';

class BookingsPage extends ConsumerWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(bookingsControllerProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncValueWidget(
        value: bookings,
        data: (items) {
          final upcoming =
              items.where((booking) => booking.isUpcoming).toList();
          final active = items.where((booking) => booking.isActive).toList();
          final history = items.where((booking) => booking.isHistory).toList();

          return ListView(
            children: [
              _SectionCard(
                title: 'Rental workflow',
                subtitle:
                    'This feature corresponds to the rental-service from the reference project: availability check, booking creation, rental status and trip history.',
              ),
              const SizedBox(height: 12),
              _BookingGroup(title: 'Active now', bookings: active),
              const SizedBox(height: 12),
              _BookingGroup(title: 'Upcoming', bookings: upcoming),
              const SizedBox(height: 12),
              _BookingGroup(title: 'History', bookings: history),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

class _BookingGroup extends StatelessWidget {
  const _BookingGroup({
    required this.title,
    required this.bookings,
  });

  final String title;
  final List<Booking> bookings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (bookings.isEmpty)
              const Text('No records yet.')
            else
              ...bookings.map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BookingCard(booking: booking),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  String _statusLabel() {
    switch (booking.status) {
      case BookingStatus.created:
        return 'Created';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.active:
        return 'Active';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd.MM.yyyy HH:mm');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(booking.carName, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
              '${formatter.format(booking.startTime)} - ${formatter.format(booking.endTime)}'),
          const SizedBox(height: 8),
          Text('Status: ${_statusLabel()}'),
          const SizedBox(height: 8),
          Text(
            'Total: ${booking.totalPrice.toStringAsFixed(0)} ${AppConstants.defaultCurrency}',
          ),
          const SizedBox(height: 4),
          Text('Distance: ${booking.distanceKm.toStringAsFixed(1)} km'),
          if (booking.routeSummary != null) ...[
            const SizedBox(height: 4),
            Text('Route: ${booking.routeSummary}'),
          ],
        ],
      ),
    );
  }
}

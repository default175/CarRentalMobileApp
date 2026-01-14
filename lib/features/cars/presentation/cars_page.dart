import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/async_value_widget.dart';

class CarsPage extends ConsumerStatefulWidget {
  const CarsPage({super.key});

  @override
  ConsumerState<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends ConsumerState<CarsPage> {
  final _priceFromController = TextEditingController();
  final _priceToController = TextEditingController();
  String _category = 'All';
  String _transmission = 'All';
  String _status = 'All';
  String _color = 'All';
  int _minSeats = 4;
  int _minBattery = 0;
  int _minRange = 0;
  int _minYear = 2010;
  bool _availableOnly = false;
  bool _gpsOnly = false;

  @override
  void dispose() {
    _priceFromController.dispose();
    _priceToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cars = ref.watch(carsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncValueWidget(
        value: cars,
        data: (items) {
          final filtered = items.where((car) {
            final matchesCategory = _category == 'All' || car.category == _category;
            final matchesTransmission =
                _transmission == 'All' || car.transmission == _transmission;
            final matchesStatus = _status == 'All' || car.status.name == _status;
            final matchesColor = _color == 'All' || car.color == _color;
            final matchesSeats = car.seats >= _minSeats;
            final matchesAvailability =
                !_availableOnly || car.status == CarStatus.available;
            final matchesGps = !_gpsOnly || car.hasGpsSignal;
            final priceFrom = double.tryParse(_priceFromController.text);
            final priceTo = double.tryParse(_priceToController.text);
            final matchesPriceFrom =
                priceFrom == null || car.pricePerHour >= priceFrom;
            final matchesPriceTo = priceTo == null || car.pricePerHour <= priceTo;
            final matchesBattery = car.batteryLevel >= _minBattery;
            final matchesRange = car.rangeKm >= _minRange;
            final matchesYear = car.year >= _minYear;

            return matchesCategory &&
                matchesTransmission &&
                matchesStatus &&
                matchesColor &&
                matchesSeats &&
                matchesAvailability &&
                matchesGps &&
                matchesPriceFrom &&
                matchesPriceTo &&
                matchesBattery &&
                matchesRange &&
                matchesYear;
          }).toList();

          final available = items.where((car) => car.status == CarStatus.available);

          return ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FleetSummary(
                  total: items.length,
                  available: available.length,
                  priceFromController: _priceFromController,
                  priceToController: _priceToController,
                  category: _category,
                  transmission: _transmission,
                  status: _status,
                  color: _color,
                  minSeats: _minSeats,
                  minBattery: _minBattery,
                  minRange: _minRange,
                  minYear: _minYear,
                  availableOnly: _availableOnly,
                  gpsOnly: _gpsOnly,
                  onChanged: () => setState(() {}),
                  onCategoryChanged: (value) => setState(() => _category = value),
                  onTransmissionChanged: (value) =>
                      setState(() => _transmission = value),
                  onStatusChanged: (value) => setState(() => _status = value),
                  onColorChanged: (value) => setState(() => _color = value),
                  onSeatsChanged: (value) => setState(() => _minSeats = value),
                  onBatteryChanged: (value) => setState(() => _minBattery = value),
                  onRangeChanged: (value) => setState(() => _minRange = value),
                  onYearChanged: (value) => setState(() => _minYear = value),
                  onAvailableChanged: (value) =>
                      setState(() => _availableOnly = value),
                  onGpsChanged: (value) => setState(() => _gpsOnly = value),
                );
              }

              return _CarCard(
                car: filtered[index - 1],
                onBook: (car) => _showBookingDialog(context, car),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: filtered.length + 1,
          );
        },
      ),
    );
  }

  Future<void> _showBookingDialog(BuildContext context, Car car) async {
    final user = ref.read(authControllerProvider).currentUser;
    final bookings = ref.read(bookingsControllerProvider).valueOrNull ?? const [];
    if (user == null) {
      return;
    }

    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedTime = const TimeOfDay(hour: 10, minute: 0);
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    String? validationMessage;

    final carBookings = bookings
        .where(
          (booking) =>
              booking.carId == car.id &&
              booking.status != BookingStatus.cancelled &&
              booking.status != BookingStatus.completed,
        )
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    DateTime buildDateTime(DateTime date, TimeOfDay time) {
      return DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    }

    String? validateSelection() {
      final start = buildDateTime(selectedDate, selectedTime);
      final end = buildDateTime(endDate, endTime);
      if (!end.isAfter(start)) {
        return 'End date and time must be later than the start.';
      }

      final conflict = carBookings.where((booking) {
        return start.isBefore(booking.endTime) && end.isAfter(booking.startTime);
      }).firstOrNull;

      if (conflict != null) {
        final formatter = DateFormat('dd.MM HH:mm');
        return 'This time overlaps with an existing booking: ${formatter.format(conflict.startTime)} - ${formatter.format(conflict.endTime)}.';
      }

      return null;
    }

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text('Book ${car.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (carBookings.isNotEmpty) ...[
                Text(
                  'Unavailable periods',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: carBookings
                        .map(
                          (booking) => Chip(
                            label: Text(
                              '${DateFormat('dd.MM HH:mm').format(booking.startTime)} - ${DateFormat('dd.MM HH:mm').format(booking.endTime)}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start date'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(selectedDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    initialDate: selectedDate,
                  );
                  if (picked != null) {
                    setModalState(() {
                      selectedDate = picked;
                      if (endDate.isBefore(selectedDate)) {
                        endDate = selectedDate;
                      }
                      validationMessage = validateSelection();
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start time'),
                subtitle: Text(selectedTime.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null) {
                    setModalState(() {
                      selectedTime = picked;
                      validationMessage = validateSelection();
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End date'),
                subtitle: Text(DateFormat('dd.MM.yyyy').format(endDate)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: selectedDate,
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                    initialDate: endDate.isBefore(selectedDate) ? selectedDate : endDate,
                  );
                  if (picked != null) {
                    setModalState(() {
                      endDate = picked;
                      validationMessage = validateSelection();
                    });
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End time'),
                subtitle: Text(endTime.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (picked != null) {
                    setModalState(() {
                      endTime = picked;
                      validationMessage = validateSelection();
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (_) {
                  final start = buildDateTime(selectedDate, selectedTime);
                  final end = buildDateTime(endDate, endTime);
                  final duration = end.difference(start);
                  final totalHours = duration.inMinutes > 0
                      ? (duration.inMinutes / 60).toStringAsFixed(1)
                      : '0.0';
                  final totalPrice = duration.inMinutes > 0
                      ? car.pricePerHour * (duration.inMinutes / 60)
                      : 0.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration: $totalHours hours'),
                      const SizedBox(height: 4),
                      Text(
                        'Estimated total: ${totalPrice.toStringAsFixed(0)} ${AppConstants.defaultCurrency}',
                      ),
                    ],
                  );
                },
              ),
              if (validationMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  validationMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final start = buildDateTime(selectedDate, selectedTime);
                final end = buildDateTime(endDate, endTime);
                final error = validateSelection();
                if (error != null) {
                  setModalState(() {
                    validationMessage = error;
                  });
                  return;
                }

                try {
                  await ref.read(bookingsControllerProvider.notifier).createBooking(
                        user: user,
                        car: car,
                        start: start,
                        end: end,
                      );
                  ref.invalidate(adminOverviewProvider);
                  ref.invalidate(notificationsProvider);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking created for ${car.title}'),
                      ),
                    );
                  }
                } catch (error) {
                  setModalState(() {
                    validationMessage = '$error';
                  });
                }
              },
              child: const Text('Confirm booking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FleetSummary extends StatelessWidget {
  const _FleetSummary({
    required this.total,
    required this.available,
    required this.priceFromController,
    required this.priceToController,
    required this.category,
    required this.transmission,
    required this.status,
    required this.color,
    required this.minSeats,
    required this.minBattery,
    required this.minRange,
    required this.minYear,
    required this.availableOnly,
    required this.gpsOnly,
    required this.onChanged,
    required this.onCategoryChanged,
    required this.onTransmissionChanged,
    required this.onStatusChanged,
    required this.onColorChanged,
    required this.onSeatsChanged,
    required this.onBatteryChanged,
    required this.onRangeChanged,
    required this.onYearChanged,
    required this.onAvailableChanged,
    required this.onGpsChanged,
  });

  final int total;
  final int available;
  final TextEditingController priceFromController;
  final TextEditingController priceToController;
  final String category;
  final String transmission;
  final String status;
  final String color;
  final int minSeats;
  final int minBattery;
  final int minRange;
  final int minYear;
  final bool availableOnly;
  final bool gpsOnly;
  final VoidCallback onChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTransmissionChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<int> onSeatsChanged;
  final ValueChanged<int> onBatteryChanged;
  final ValueChanged<int> onRangeChanged;
  final ValueChanged<int> onYearChanged;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onGpsChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fleet catalog', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text('Use the filters below to narrow the fleet by price, class, year, GPS and technical characteristics.'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('$total total vehicles')),
                Chip(label: Text('$available available now')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                      DropdownMenuItem(value: 'Business', child: Text('Business')),
                      DropdownMenuItem(value: 'Family', child: Text('Family')),
                      DropdownMenuItem(value: 'Comfort', child: Text('Comfort')),
                    ],
                    onChanged: (value) => onCategoryChanged(value ?? 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'booked', child: Text('Booked')),
                      DropdownMenuItem(value: 'inUse', child: Text('In use')),
                      DropdownMenuItem(value: 'maintenance', child: Text('Service')),
                    ],
                    onChanged: (value) => onStatusChanged(value ?? 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: transmission,
                    decoration: const InputDecoration(labelText: 'Transmission'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                      DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                    ],
                    onChanged: (value) => onTransmissionChanged(value ?? 'All'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: color,
                    decoration: const InputDecoration(labelText: 'Color'),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Black', child: Text('Black')),
                      DropdownMenuItem(value: 'Blue', child: Text('Blue')),
                      DropdownMenuItem(value: 'Gray', child: Text('Gray')),
                      DropdownMenuItem(value: 'Pearl White', child: Text('Pearl White')),
                      DropdownMenuItem(value: 'Silver', child: Text('Silver')),
                      DropdownMenuItem(value: 'White', child: Text('White')),
                    ],
                    onChanged: (value) => onColorChanged(value ?? 'All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceFromController,
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(labelText: 'Price from'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: priceToController,
                    onChanged: (_) => onChanged(),
                    decoration: const InputDecoration(labelText: 'Price to'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Minimum year: $minYear'),
                      Slider(
                        value: minYear.toDouble(),
                        min: 2010,
                        max: 2025,
                        divisions: 15,
                        label: '$minYear',
                        onChanged: (value) => onYearChanged(value.round()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Minimum battery: $minBattery%'),
                      Slider(
                        value: minBattery.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: '$minBattery%',
                        onChanged: (value) => onBatteryChanged(value.round()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Minimum seats: $minSeats'),
            Slider(
              value: minSeats.toDouble(),
              min: 2,
              max: 7,
              divisions: 5,
              label: '$minSeats',
              onChanged: (value) => onSeatsChanged(value.round()),
            ),
            Text('Minimum range: $minRange km'),
            Slider(
              value: minRange.toDouble(),
              min: 0,
              max: 700,
              divisions: 14,
              label: '$minRange km',
              onChanged: (value) => onRangeChanged(value.round()),
            ),
            SwitchListTile(
              value: availableOnly,
              onChanged: onAvailableChanged,
              title: const Text('Available only'),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: gpsOnly,
              onChanged: onGpsChanged,
              title: const Text('GPS signal available'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

class _CarCard extends ConsumerWidget {
  const _CarCard({
    required this.car,
    required this.onBook,
  });

  final Car car;
  final ValueChanged<Car> onBook;

  Color _statusColor(BuildContext context) {
    switch (car.status) {
      case CarStatus.available:
        return Colors.green;
      case CarStatus.booked:
        return Colors.orange;
      case CarStatus.inUse:
        return Colors.blue;
      case CarStatus.maintenance:
        return Theme.of(context).colorScheme.error;
    }
  }

  String _statusLabel() {
    switch (car.status) {
      case CarStatus.available:
        return 'Available';
      case CarStatus.booked:
        return 'Booked';
      case CarStatus.inUse:
        return 'In use';
      case CarStatus.maintenance:
        return 'Service';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).currentUser;
    final bookings = ref.watch(bookingsControllerProvider);
    final canBook = user != null && car.status != CarStatus.maintenance;
    final dateFormatter = DateFormat('dd.MM HH:mm');

    return bookings.when(
      data: (items) {
        final upcomingBooking = items
            .where(
              (booking) =>
                  booking.carId == car.id &&
                  booking.status != BookingStatus.cancelled &&
                  booking.status != BookingStatus.completed &&
                  booking.endTime.isAfter(DateTime.now()),
            )
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
        final nextBooking = upcomingBooking.isEmpty ? null : upcomingBooking.first;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (car.imageUrl.isNotEmpty) ...[
                  AppNetworkImage(
                    imageUrl: car.imageUrl,
                    height: 180,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        car.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Chip(
                      label: Text(_statusLabel()),
                      side: BorderSide.none,
                      backgroundColor: _statusColor(context).withValues(alpha: 0.12),
                      labelStyle: TextStyle(color: _statusColor(context)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${car.year} | ${car.type} | ${car.batteryLevel}% battery'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(label: Text(car.category)),
                    Chip(label: Text('${car.seats} seats')),
                    Chip(label: Text(car.transmission)),
                    Chip(label: Text(car.color)),
                    Chip(label: Text(car.hasGpsSignal ? 'GPS online' : 'GPS offline')),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${car.pricePerHour.toStringAsFixed(0)} ${AppConstants.defaultCurrency} / hour',
                ),
                const SizedBox(height: 8),
                Text(
                  car.hasGpsSignal
                      ? 'Range ${car.rangeKm} km | GPS ${car.location.lat.toStringAsFixed(3)}, ${car.location.lng.toStringAsFixed(3)}'
                      : 'Range ${car.rangeKm} km | Vehicle GPS unavailable',
                ),
                if (nextBooking != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Booked: ${dateFormatter.format(nextBooking.startTime)} - ${dateFormatter.format(nextBooking.endTime)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/cars/${car.id}'),
                        child: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: canBook ? () => onBook(car) : null,
                        child: Text(
                          car.status == CarStatus.maintenance
                              ? 'Unavailable'
                              : 'Choose dates',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Card(child: SizedBox(height: 120)),
      error: (_, __) => const Card(child: SizedBox(height: 120)),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

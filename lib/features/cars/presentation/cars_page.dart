import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/car_review.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/async_value_widget.dart';

class CarsPage extends ConsumerStatefulWidget {
  const CarsPage({super.key});

  @override
  ConsumerState<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends ConsumerState<CarsPage> {
  final _searchController = TextEditingController();
  String _category = 'All';
  String _fuelType = 'All';
  String _drive = 'All';
  String _transmission = 'All';
  String _status = 'All';
  String _color = 'All';
  int _minSeats = 4;
  int _minBattery = 0;
  int _minRange = 0;
  RangeValues _priceRange = const RangeValues(0, 1000000);
  RangeValues _yearRange = const RangeValues(1990, 2026);
  RangeValues _mileageRange = const RangeValues(0, 300000);
  bool _availableOnly = false;
  bool _withoutRentalsOnly = false;
  bool _gpsOnly = false;
  bool _registeredOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
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
          final activeBookings =
              ref.watch(bookingsControllerProvider).valueOrNull ?? const [];
          final filtered = items.where((car) {
            final query = _searchController.text.trim().toLowerCase();
            final matchesSearch = query.isEmpty ||
                car.title.toLowerCase().contains(query) ||
                car.brand.toLowerCase().contains(query) ||
                car.model.toLowerCase().contains(query) ||
                car.type.toLowerCase().contains(query) ||
                car.category.toLowerCase().contains(query) ||
                car.fuelType.toLowerCase().contains(query) ||
                car.drive.toLowerCase().contains(query) ||
                car.features.any(
                  (feature) => feature.toLowerCase().contains(query),
                );
            final matchesCategory =
                _category == 'All' || car.category == _category;
            final matchesFuel = _fuelType == 'All' || car.fuelType == _fuelType;
            final matchesDrive = _drive == 'All' || car.drive == _drive;
            final matchesTransmission =
                _transmission == 'All' || car.transmission == _transmission;
            final matchesStatus =
                _status == 'All' || car.status.name == _status;
            final matchesColor = _color == 'All' || car.color == _color;
            final matchesSeats = car.seats >= _minSeats;
            final matchesAvailability =
                !_availableOnly || car.status == CarStatus.available;
            final matchesGps = !_gpsOnly || car.hasGpsSignal;
            final matchesPriceFrom = car.pricePerHour >= _priceRange.start;
            final matchesPriceTo = car.pricePerHour <= _priceRange.end;
            final matchesBattery = car.batteryLevel >= _minBattery;
            final matchesRange = car.rangeKm >= _minRange;
            final matchesYear = car.year >= _yearRange.start.round() &&
                car.year <= _yearRange.end.round();
            final matchesMileage =
                car.mileageKm >= _mileageRange.start.round() &&
                    car.mileageKm <= _mileageRange.end.round();
            final matchesRegistration = !_registeredOnly || car.registered;

            final hasActiveRental = activeBookings.any((booking) {
              final active = booking.status == BookingStatus.created ||
                  booking.status == BookingStatus.confirmed ||
                  booking.status == BookingStatus.active;
              return booking.carId == car.id && active;
            });
            final matchesRental = !_withoutRentalsOnly || !hasActiveRental;

            return matchesSearch &&
                matchesCategory &&
                matchesFuel &&
                matchesDrive &&
                matchesTransmission &&
                matchesStatus &&
                matchesColor &&
                matchesSeats &&
                matchesAvailability &&
                matchesRental &&
                matchesGps &&
                matchesPriceFrom &&
                matchesPriceTo &&
                matchesBattery &&
                matchesRange &&
                matchesYear &&
                matchesMileage &&
                matchesRegistration;
          }).toList();

          final available =
              items.where((car) => car.status == CarStatus.available);
          final maxAvailablePrice = available.isEmpty
              ? items.fold<double>(
                  0,
                  (max, car) => car.pricePerHour > max ? car.pricePerHour : max,
                )
              : available.fold<double>(
                  0,
                  (max, car) => car.pricePerHour > max ? car.pricePerHour : max,
                );

          return ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0) {
                return _FleetSummary(
                  total: items.length,
                  available: available.length,
                  searchController: _searchController,
                  priceRange: _priceRange,
                  maxPrice: maxAvailablePrice <= 0 ? 50000 : maxAvailablePrice,
                  category: _category,
                  fuelType: _fuelType,
                  drive: _drive,
                  transmission: _transmission,
                  status: _status,
                  color: _color,
                  minSeats: _minSeats,
                  minBattery: _minBattery,
                  minRange: _minRange,
                  yearRange: _yearRange,
                  mileageRange: _mileageRange,
                  availableOnly: _availableOnly,
                  withoutRentalsOnly: _withoutRentalsOnly,
                  gpsOnly: _gpsOnly,
                  registeredOnly: _registeredOnly,
                  onChanged: () => setState(() {}),
                  onPriceRangeChanged: (value) =>
                      setState(() => _priceRange = value),
                  onCategoryChanged: (value) =>
                      setState(() => _category = value),
                  onFuelTypeChanged: (value) =>
                      setState(() => _fuelType = value),
                  onDriveChanged: (value) => setState(() => _drive = value),
                  onTransmissionChanged: (value) =>
                      setState(() => _transmission = value),
                  onStatusChanged: (value) => setState(() => _status = value),
                  onColorChanged: (value) => setState(() => _color = value),
                  onSeatsChanged: (value) => setState(() => _minSeats = value),
                  onBatteryChanged: (value) =>
                      setState(() => _minBattery = value),
                  onRangeChanged: (value) => setState(() => _minRange = value),
                  onYearRangeChanged: (value) =>
                      setState(() => _yearRange = value),
                  onMileageRangeChanged: (value) =>
                      setState(() => _mileageRange = value),
                  onAvailableChanged: (value) =>
                      setState(() => _availableOnly = value),
                  onWithoutRentalsChanged: (value) =>
                      setState(() => _withoutRentalsOnly = value),
                  onGpsChanged: (value) => setState(() => _gpsOnly = value),
                  onRegisteredChanged: (value) =>
                      setState(() => _registeredOnly = value),
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
    final bookings =
        ref.read(bookingsControllerProvider).valueOrNull ?? const [];
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
        return start.isBefore(booking.endTime) &&
            end.isAfter(booking.startTime);
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
                    initialDate:
                        endDate.isBefore(selectedDate) ? selectedDate : endDate,
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
                  await ref
                      .read(bookingsControllerProvider.notifier)
                      .createBooking(
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
    required this.searchController,
    required this.priceRange,
    required this.maxPrice,
    required this.category,
    required this.fuelType,
    required this.drive,
    required this.transmission,
    required this.status,
    required this.color,
    required this.minSeats,
    required this.minBattery,
    required this.minRange,
    required this.yearRange,
    required this.mileageRange,
    required this.availableOnly,
    required this.withoutRentalsOnly,
    required this.gpsOnly,
    required this.registeredOnly,
    required this.onChanged,
    required this.onPriceRangeChanged,
    required this.onCategoryChanged,
    required this.onFuelTypeChanged,
    required this.onDriveChanged,
    required this.onTransmissionChanged,
    required this.onStatusChanged,
    required this.onColorChanged,
    required this.onSeatsChanged,
    required this.onBatteryChanged,
    required this.onRangeChanged,
    required this.onYearRangeChanged,
    required this.onMileageRangeChanged,
    required this.onAvailableChanged,
    required this.onWithoutRentalsChanged,
    required this.onGpsChanged,
    required this.onRegisteredChanged,
  });

  final int total;
  final int available;
  final TextEditingController searchController;
  final RangeValues priceRange;
  final double maxPrice;
  final String category;
  final String fuelType;
  final String drive;
  final String transmission;
  final String status;
  final String color;
  final int minSeats;
  final int minBattery;
  final int minRange;
  final RangeValues yearRange;
  final RangeValues mileageRange;
  final bool availableOnly;
  final bool withoutRentalsOnly;
  final bool gpsOnly;
  final bool registeredOnly;
  final VoidCallback onChanged;
  final ValueChanged<RangeValues> onPriceRangeChanged;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onFuelTypeChanged;
  final ValueChanged<String> onDriveChanged;
  final ValueChanged<String> onTransmissionChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<int> onSeatsChanged;
  final ValueChanged<int> onBatteryChanged;
  final ValueChanged<int> onRangeChanged;
  final ValueChanged<RangeValues> onYearRangeChanged;
  final ValueChanged<RangeValues> onMileageRangeChanged;
  final ValueChanged<bool> onAvailableChanged;
  final ValueChanged<bool> onWithoutRentalsChanged;
  final ValueChanged<bool> onGpsChanged;
  final ValueChanged<bool> onRegisteredChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeMaxPrice = maxPrice <= 0 ? 1.0 : maxPrice.ceilToDouble();
    final safePriceRange = RangeValues(
      priceRange.start.clamp(0, safeMaxPrice).toDouble(),
      priceRange.end.clamp(0, safeMaxPrice).toDouble(),
    );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Available Cars ($total)',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 10),
                    FilledButton.tonalIcon(
                      onPressed: () => _showFilters(context),
                      icon: const Icon(Icons.tune, size: 18),
                      label: const Text('Filter'),
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      'Available Cars ($total)',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _showFilters(context),
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Filter'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: searchController,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              hintText: 'Search by brand, model, fuel, drive or feature',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CategoryChip(
                label: 'All',
                selected: category == 'All',
                onSelected: () => onCategoryChanged('All'),
              ),
              _CategoryChip(
                label: 'Electric',
                selected: category == 'Electric',
                onSelected: () => onCategoryChanged('Electric'),
              ),
              _CategoryChip(
                label: 'Business',
                selected: category == 'Business',
                onSelected: () => onCategoryChanged('Business'),
              ),
              _CategoryChip(
                label: 'Comfort',
                selected: category == 'Comfort',
                onSelected: () => onCategoryChanged('Comfort'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CounterPill(label: '$available available'),
              _CounterPill(
                  label: '${yearRange.start.round()}-${yearRange.end.round()}'),
              _CounterPill(
                  label:
                      '${safePriceRange.start.round()}-${safePriceRange.end.round()} KZT/h'),
              _CounterPill(label: '$minSeats+ seats'),
              _CounterPill(label: fuelType == 'All' ? 'all fuel' : fuelType),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    final safeMaxPrice = maxPrice <= 0 ? 1.0 : maxPrice.ceilToDouble();
    final safePriceRange = RangeValues(
      priceRange.start.clamp(0, safeMaxPrice).toDouble(),
      priceRange.end.clamp(0, safeMaxPrice).toDouble(),
    );
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Filter cars',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: fuelType,
                decoration: const InputDecoration(labelText: 'Fuel type'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                  DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                  DropdownMenuItem(value: 'Gas', child: Text('Gas')),
                  DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => onFuelTypeChanged(value ?? 'All'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: drive,
                decoration: const InputDecoration(labelText: 'Drive'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'front', child: Text('Front')),
                  DropdownMenuItem(value: 'rear', child: Text('Rear')),
                  DropdownMenuItem(value: 'full', child: Text('Full / AWD')),
                ],
                onChanged: (value) => onDriveChanged(value ?? 'All'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(
                      value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'booked', child: Text('Booked')),
                  DropdownMenuItem(value: 'inUse', child: Text('In use')),
                  DropdownMenuItem(
                      value: 'maintenance', child: Text('Service')),
                ],
                onChanged: (value) => onStatusChanged(value ?? 'All'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: transmission,
                decoration: const InputDecoration(labelText: 'Transmission'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(
                      value: 'Automatic', child: Text('Automatic')),
                  DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                ],
                onChanged: (value) => onTransmissionChanged(value ?? 'All'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: color,
                decoration: const InputDecoration(labelText: 'Color'),
                items: const [
                  DropdownMenuItem(value: 'All', child: Text('All')),
                  DropdownMenuItem(value: 'Black', child: Text('Black')),
                  DropdownMenuItem(value: 'Blue', child: Text('Blue')),
                  DropdownMenuItem(value: 'Gray', child: Text('Gray')),
                  DropdownMenuItem(
                      value: 'Pearl White', child: Text('Pearl White')),
                  DropdownMenuItem(value: 'Silver', child: Text('Silver')),
                  DropdownMenuItem(value: 'White', child: Text('White')),
                ],
                onChanged: (value) => onColorChanged(value ?? 'All'),
              ),
              const SizedBox(height: 14),
              Text(
                'Price range: ${safePriceRange.start.round()} - ${safePriceRange.end.round()} KZT/h',
              ),
              RangeSlider(
                values: safePriceRange,
                min: 0,
                max: safeMaxPrice,
                divisions: safeMaxPrice.round().clamp(1, 100),
                labels: RangeLabels(
                  '${safePriceRange.start.round()}',
                  '${safePriceRange.end.round()} KZT/h',
                ),
                onChanged: onPriceRangeChanged,
              ),
              const SizedBox(height: 10),
              Text(
                'Year range: ${yearRange.start.round()} - ${yearRange.end.round()}',
              ),
              RangeSlider(
                values: yearRange,
                min: 1990,
                max: 2026,
                divisions: 36,
                labels: RangeLabels(
                  '${yearRange.start.round()}',
                  '${yearRange.end.round()}',
                ),
                onChanged: onYearRangeChanged,
              ),
              Text(
                'Mileage range: ${mileageRange.start.round()} - ${mileageRange.end.round()} km',
              ),
              RangeSlider(
                values: mileageRange,
                min: 0,
                max: 300000,
                divisions: 30,
                labels: RangeLabels(
                  '${mileageRange.start.round()}',
                  '${mileageRange.end.round()} km',
                ),
                onChanged: onMileageRangeChanged,
              ),
              Text('Minimum battery: $minBattery%'),
              Slider(
                value: minBattery.toDouble(),
                min: 0,
                max: 100,
                divisions: 10,
                label: '$minBattery%',
                onChanged: (value) => onBatteryChanged(value.round()),
              ),
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
                value: withoutRentalsOnly,
                onChanged: onWithoutRentalsChanged,
                title: const Text('Without active rental'),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: gpsOnly,
                onChanged: onGpsChanged,
                title: const Text('GPS signal available'),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                value: registeredOnly,
                onChanged: onRegisteredChanged,
                title: const Text('Registered only'),
                contentPadding: EdgeInsets.zero,
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Apply filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CounterPill extends StatelessWidget {
  const _CounterPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      labelStyle: TextStyle(
        color:
            selected ? Colors.white : Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w800,
      ),
      selectedColor: Theme.of(context).colorScheme.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      side: BorderSide(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).dividerColor.withValues(alpha: 0.35),
      ),
      onSelected: (_) => onSelected(),
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
    final reviews = ref.watch(carReviewsProvider);
    final canBook = user != null && car.status != CarStatus.maintenance;
    final dateFormatter = DateFormat('dd.MM HH:mm');
    final rating = _averageRating(reviews, car.id);

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
        final nextBooking =
            upcomingBooking.isEmpty ? null : upcomingBooking.first;

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AppNetworkImage(
                      imageUrl: car.displayImageUrl,
                      height: 178,
                      width: double.infinity,
                      borderRadius: 18,
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _statusLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        car.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    Text(
                      car.pricePerHour.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${car.brand} | ${car.year} | ${car.type}'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                        icon: Icons.event_seat_outlined,
                        label: '${car.seats} seats'),
                    _InfoChip(icon: Icons.settings, label: car.transmission),
                    _InfoChip(
                      icon: car.isElectric
                          ? Icons.battery_charging_full
                          : Icons.local_gas_station_outlined,
                      label: '${car.fuelType} ${car.energyValue}',
                    ),
                    _InfoChip(icon: Icons.route_outlined, label: car.drive),
                    _InfoChip(
                        icon: Icons.star, label: rating.toStringAsFixed(1)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${AppConstants.defaultCurrency} / hour | ${car.mileageKm} km | Range ${car.rangeKm} km',
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
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/cars/${car.id}'),
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('Details'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: canBook ? () => onBook(car) : null,
                        child: Text(
                          car.status == CarStatus.maintenance
                              ? 'Unavailable'
                              : 'Book this car',
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

  double _averageRating(List<CarReview> reviews, String carId) {
    final carReviews =
        reviews.where((review) => review.carId == carId).toList();
    if (carReviews.isEmpty) {
      return 0;
    }
    final total = carReviews.fold<int>(0, (sum, review) => sum + review.rating);
    return total / carReviews.length;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

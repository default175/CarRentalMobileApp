import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/geo_point.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/info_card.dart';

class AdminPage extends ConsumerWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(adminOverviewProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: AsyncValueWidget(
        value: overview,
        data: (data) => ListView(
          children: [
            Text(
              'Admin module',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            const Text(
              'Manage users, vehicles, bookings and operational statuses from one control panel.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: InfoCard(title: 'Users', value: '${data.users.length}')),
                const SizedBox(width: 12),
                Expanded(child: InfoCard(title: 'Cars', value: '${data.cars.length}')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InfoCard(
                    title: 'Bookings',
                    value: '${data.bookings.length}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InfoCard(
                    title: 'Active trips',
                    value: '${data.activeTrips}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _AdminSection(
              title: 'Users',
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _showUserDialog(context, ref),
                      icon: const Icon(Icons.person_add_alt_1),
                      label: const Text('Add user'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...data.users.map(
                    (user) => _AdminUserTile(
                      user: user,
                      onEdit: () => _showUserDialog(context, ref, user: user),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _AdminSection(
              title: 'Cars',
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _showCarDialog(context, ref),
                      icon: const Icon(Icons.add_road),
                      label: const Text('Add car'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...data.cars.map(
                    (car) => _AdminCarTile(
                      car: car,
                      onEdit: () => _showCarDialog(context, ref, car: car),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _AdminSection(
              title: 'Bookings',
              child: Column(
                children: data.bookings
                    .map((booking) => _AdminBookingTile(booking: booking))
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUserDialog(
    BuildContext context,
    WidgetRef ref, {
    AppUser? user,
  }) async {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final licenseController =
        TextEditingController(text: user?.licenseNumber ?? '');
    var role = user?.role ?? AppRole.user;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? 'Add user' : 'Edit user'),
        content: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: licenseController,
                  decoration: const InputDecoration(labelText: 'License'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppRole>(
                  initialValue: role,
                  items: const [
                    DropdownMenuItem(value: AppRole.user, child: Text('User')),
                    DropdownMenuItem(value: AppRole.admin, child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setModalState(() {
                      role = value ?? AppRole.user;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final target = (user ??
                      AppUser(
                        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
                        name: '',
                        email: '',
                        phone: '',
                        role: role,
                      ))
                  .copyWith(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                licenseNumber: licenseController.text.trim(),
                role: role,
              );
              await ref.read(adminRepositoryProvider).saveUser(target);
              ref.invalidate(adminOverviewProvider);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCarDialog(
    BuildContext context,
    WidgetRef ref, {
    Car? car,
  }) async {
    final brandController = TextEditingController(text: car?.brand ?? '');
    final modelController = TextEditingController(text: car?.model ?? '');
    final typeController = TextEditingController(text: car?.type ?? '');
    final categoryController = TextEditingController(text: car?.category ?? '');
    final priceController =
        TextEditingController(text: car?.pricePerHour.toStringAsFixed(0) ?? '');
    final yearController = TextEditingController(text: '${car?.year ?? 2024}');
    final seatsController = TextEditingController(text: '${car?.seats ?? 5}');
    final colorController = TextEditingController(text: car?.color ?? '');
    final imageController = TextEditingController(text: car?.imageUrl ?? '');
    final descriptionController =
        TextEditingController(text: car?.description ?? '');
    var status = car?.status ?? CarStatus.available;
    var hasGpsSignal = car?.hasGpsSignal ?? true;
    var imagePreview = car?.imageUrl ?? '';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(car == null ? 'Add car' : 'Edit car'),
        content: StatefulBuilder(
          builder: (context, setModalState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(labelText: 'Brand'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(labelText: 'Model'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price per hour'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(labelText: 'Year'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: seatsController,
                  decoration: const InputDecoration(labelText: 'Seats'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(labelText: 'Color'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                  onChanged: (value) {
                    setModalState(() {
                      imagePreview = value.trim();
                    });
                  },
                ),
                const SizedBox(height: 12),
                if (imagePreview.isNotEmpty)
                  AppNetworkImage(
                    imageUrl: imagePreview,
                    height: 180,
                    width: double.infinity,
                    borderRadius: 16,
                    errorWidget: Container(
                      height: 140,
                      alignment: Alignment.center,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      child: const Text(
                        'Preview unavailable for this URL.\nTry a direct public image link.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (imagePreview.isNotEmpty) const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CarStatus>(
                  initialValue: status,
                  items: const [
                    DropdownMenuItem(
                      value: CarStatus.available,
                      child: Text('Available'),
                    ),
                    DropdownMenuItem(value: CarStatus.booked, child: Text('Booked')),
                    DropdownMenuItem(value: CarStatus.inUse, child: Text('In use')),
                    DropdownMenuItem(
                      value: CarStatus.maintenance,
                      child: Text('Maintenance'),
                    ),
                  ],
                  onChanged: (value) {
                    setModalState(() {
                      status = value ?? CarStatus.available;
                    });
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Car GPS signal available'),
                  value: hasGpsSignal,
                  onChanged: (value) {
                    setModalState(() {
                      hasGpsSignal = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final target = (car ??
                      Car(
                        id: 'car-${DateTime.now().millisecondsSinceEpoch}',
                        brand: '',
                        model: '',
                        year: 2024,
                        type: '',
                        category: '',
                        pricePerHour: 0,
                        status: status,
                        location: const GeoPoint(lat: 43.2389, lng: 76.8897),
                        imageUrl: '',
                        batteryLevel: 70,
                        rangeKm: 420,
                        seats: 5,
                        transmission: 'Automatic',
                        color: '',
                        description: '',
                        features: const ['GPS tracking', 'Insurance included'],
                        hasGpsSignal: true,
                      ))
                  .copyWith(
                brand: brandController.text.trim(),
                model: modelController.text.trim(),
                type: typeController.text.trim(),
                category: categoryController.text.trim(),
                pricePerHour: double.tryParse(priceController.text) ?? 0,
                year: int.tryParse(yearController.text) ?? 2024,
                seats: int.tryParse(seatsController.text) ?? 5,
                color: colorController.text.trim(),
                imageUrl: imageController.text.trim(),
                description: descriptionController.text.trim(),
                status: status,
                hasGpsSignal: hasGpsSignal,
              );
              await ref.read(adminRepositoryProvider).saveCar(target);
              ref.invalidate(carsProvider);
              ref.invalidate(adminOverviewProvider);
              ref.invalidate(carByIdProvider(target.id));
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AdminSection extends StatelessWidget {
  const _AdminSection({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

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
            child,
          ],
        ),
      ),
    );
  }
}

class _AdminUserTile extends ConsumerWidget {
  const _AdminUserTile({
    required this.user,
    required this.onEdit,
  });

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(user.name),
      subtitle: Text('${user.email} • ${user.phone}'),
      trailing: Wrap(
        spacing: 8,
        children: [
          FilledButton.tonal(
            onPressed: onEdit,
            child: const Text('Edit'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              await ref.read(adminRepositoryProvider).toggleUserBlocked(user.id);
              ref.invalidate(adminOverviewProvider);
            },
            child: Text(user.isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }
}

class _AdminCarTile extends ConsumerWidget {
  const _AdminCarTile({
    required this.car,
    required this.onEdit,
  });

  final Car car;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(car.title),
      subtitle: Text('${car.type} • ${car.category} • ${car.pricePerHour.toStringAsFixed(0)}'),
      trailing: Wrap(
        spacing: 8,
        children: [
          FilledButton.tonal(
            onPressed: onEdit,
            child: const Text('Edit'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              await ref.read(adminRepositoryProvider).deleteCar(car.id);
              ref.invalidate(carsProvider);
              ref.invalidate(adminOverviewProvider);
              ref.invalidate(carByIdProvider(car.id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _AdminBookingTile extends ConsumerWidget {
  const _AdminBookingTile({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text('${booking.userName} • ${booking.carName}'),
      subtitle: Text('${booking.status.name} • ${booking.startTime}'),
      trailing: PopupMenuButton<BookingStatus>(
        onSelected: (status) async {
          await ref.read(adminRepositoryProvider).updateBookingStatus(
                bookingId: booking.id,
                status: status,
              );
          ref.invalidate(bookingsControllerProvider);
          ref.invalidate(adminOverviewProvider);
        },
        itemBuilder: (context) => BookingStatus.values
            .map(
              (status) => PopupMenuItem(
                value: status,
                child: Text(status.name),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

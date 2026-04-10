import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/app_user.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/geo_point.dart';
import '../../../shared/widgets/app_network_image.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  final _userSearchController = TextEditingController();
  final _carSearchController = TextEditingController();

  @override
  void dispose() {
    _userSearchController.dispose();
    _carSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(adminOverviewProvider);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: overview.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_outlined,
                      color: Theme.of(context).colorScheme.primary, size: 38),
                  const SizedBox(height: 12),
                  Text('Admin panel unavailable',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  FilledButton(
                    onPressed: () => ref.invalidate(adminOverviewProvider),
                    child: const Text('Retry'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final settings = ref.read(apiConnectionSettingsProvider);
                      await ref
                          .read(apiConnectionSettingsProvider.notifier)
                          .save(
                            baseUrl: settings.baseUrl,
                            enabled: false,
                          );
                      ref.invalidate(adminOverviewProvider);
                      ref.invalidate(carsProvider);
                      ref.invalidate(bookingsControllerProvider);
                    },
                    icon: const Icon(Icons.cloud_off_outlined),
                    label: const Text('Use local demo data'),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (data) {
          final userQuery = _userSearchController.text.trim().toLowerCase();
          final carQuery = _carSearchController.text.trim().toLowerCase();
          final filteredUsers = data.users.where((user) {
            return userQuery.isEmpty ||
                user.name.toLowerCase().contains(userQuery) ||
                user.email.toLowerCase().contains(userQuery) ||
                user.phone.toLowerCase().contains(userQuery) ||
                user.role.name.toLowerCase().contains(userQuery);
          }).toList(growable: false);
          final filteredCars = data.cars.where((car) {
            return carQuery.isEmpty ||
                car.title.toLowerCase().contains(carQuery) ||
                car.brand.toLowerCase().contains(carQuery) ||
                car.model.toLowerCase().contains(carQuery) ||
                car.fuelType.toLowerCase().contains(carQuery) ||
                car.category.toLowerCase().contains(carQuery) ||
                car.status.name.toLowerCase().contains(carQuery) ||
                '${car.year}'.contains(carQuery);
          }).toList(growable: false);

          return ListView(
            padding: const EdgeInsets.only(bottom: 104),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings,
                        color: Colors.white, size: 30),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Panel',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Users and Cars',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Exit admin panel',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    _AdminMetricCard(
                        title: 'Users', value: '${data.users.length}'),
                    _AdminMetricCard(
                        title: 'Cars', value: '${data.cars.length}'),
                    _AdminMetricCard(
                        title: 'Bookings', value: '${data.bookings.length}'),
                    _AdminMetricCard(
                        title: 'Active', value: '${data.activeTrips}'),
                  ];
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: constraints.maxWidth < 520 ? 2 : 4,
                    childAspectRatio: constraints.maxWidth < 360 ? 1.65 : 2.1,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: cards,
                  );
                },
              ),
              const SizedBox(height: 12),
              _AdminSearchField(
                controller: _userSearchController,
                hintText: 'Search users by name, email, phone or role',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              _AdminSection(
                title: 'Users',
                action: 'Add user',
                onAction: () => _showUserDialog(context, ref),
                children: filteredUsers
                    .map((user) => _AdminUserCard(
                        user: user,
                        onEdit: () =>
                            _showUserDialog(context, ref, user: user)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              _AdminSearchField(
                controller: _carSearchController,
                hintText: 'Search cars by model, brand, fuel, year or status',
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              _AdminSection(
                title: 'Cars',
                action: 'Add car',
                onAction: () => _showCarDialog(context, ref),
                children: filteredCars
                    .map((car) => _AdminCarCard(
                        car: car,
                        onEdit: () => _showCarDialog(context, ref, car: car)))
                    .toList(),
              ),
              const SizedBox(height: 12),
              _AdminSection(
                title: 'Bookings',
                children: data.bookings
                    .map((booking) => _AdminBookingCard(booking: booking))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showUserDialog(BuildContext context, WidgetRef ref,
      {AppUser? user}) async {
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
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
                    decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 12),
                DropdownButtonFormField<AppRole>(
                  initialValue: role,
                  items: const [
                    DropdownMenuItem(value: AppRole.user, child: Text('User')),
                    DropdownMenuItem(
                        value: AppRole.admin, child: Text('Admin')),
                  ],
                  onChanged: (value) =>
                      setModalState(() => role = value ?? AppRole.user),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
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

  Future<void> _showCarDialog(BuildContext context, WidgetRef ref,
      {Car? car}) async {
    final brandController = TextEditingController(text: car?.brand ?? '');
    final modelController = TextEditingController(text: car?.model ?? '');
    final yearController = TextEditingController(text: '${car?.year ?? 2024}');
    final typeController = TextEditingController(text: car?.type ?? 'Sedan');
    final categoryController =
        TextEditingController(text: car?.category ?? 'Comfort');
    final priceController =
        TextEditingController(text: car?.pricePerHour.toStringAsFixed(0) ?? '');
    final imageController = TextEditingController(text: car?.imageUrl ?? '');
    final seatsController = TextEditingController(text: '${car?.seats ?? 5}');
    final fuelTypeController =
        TextEditingController(text: car?.fuelType ?? 'Petrol');
    final gasController = TextEditingController(text: '${car?.gasLevel ?? 80}');
    final engineController =
        TextEditingController(text: car?.engineVolume?.toString() ?? '');
    final mileageController =
        TextEditingController(text: '${car?.mileageKm ?? 0}');
    final driveController = TextEditingController(text: car?.drive ?? 'front');
    final batteryController =
        TextEditingController(text: '${car?.batteryLevel ?? 80}');
    final rangeController =
        TextEditingController(text: '${car?.rangeKm ?? 420}');
    final transmissionController =
        TextEditingController(text: car?.transmission ?? 'Automatic');
    final colorController = TextEditingController(text: car?.color ?? 'White');
    final latController =
        TextEditingController(text: '${car?.location.lat ?? 43.2389}');
    final lngController =
        TextEditingController(text: '${car?.location.lng ?? 76.8897}');
    final descriptionController =
        TextEditingController(text: car?.description ?? 'Rental car');
    final featuresController = TextEditingController(
      text: car?.features.join(', ') ?? 'GPS tracking, Insurance included',
    );
    var status = car?.status ?? CarStatus.available;
    var hasGpsSignal = car?.hasGpsSignal ?? true;
    var registered = car?.registered ?? true;

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
                    decoration: const InputDecoration(labelText: 'Brand')),
                const SizedBox(height: 12),
                TextField(
                    controller: modelController,
                    decoration: const InputDecoration(labelText: 'Model')),
                const SizedBox(height: 12),
                TextField(
                    controller: yearController,
                    decoration: const InputDecoration(labelText: 'Year')),
                const SizedBox(height: 12),
                TextField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: 'Type')),
                const SizedBox(height: 12),
                TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 12),
                TextField(
                    controller: priceController,
                    decoration:
                        const InputDecoration(labelText: 'Price per hour')),
                const SizedBox(height: 12),
                TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Image URL')),
                const SizedBox(height: 12),
                TextField(
                    controller: seatsController,
                    decoration: const InputDecoration(labelText: 'Seats')),
                const SizedBox(height: 12),
                TextField(
                    controller: fuelTypeController,
                    decoration: const InputDecoration(
                        labelText: 'Fuel type: Electric, Petrol, Gas, Diesel')),
                const SizedBox(height: 12),
                TextField(
                    controller: gasController,
                    decoration:
                        const InputDecoration(labelText: 'Gas level %')),
                const SizedBox(height: 12),
                TextField(
                    controller: engineController,
                    decoration:
                        const InputDecoration(labelText: 'Engine volume L')),
                const SizedBox(height: 12),
                TextField(
                    controller: mileageController,
                    decoration: const InputDecoration(labelText: 'Mileage km')),
                const SizedBox(height: 12),
                TextField(
                    controller: driveController,
                    decoration: const InputDecoration(
                        labelText: 'Drive: front/rear/full')),
                const SizedBox(height: 12),
                TextField(
                    controller: batteryController,
                    decoration:
                        const InputDecoration(labelText: 'Battery level')),
                const SizedBox(height: 12),
                TextField(
                    controller: rangeController,
                    decoration: const InputDecoration(labelText: 'Range km')),
                const SizedBox(height: 12),
                TextField(
                    controller: transmissionController,
                    decoration:
                        const InputDecoration(labelText: 'Transmission')),
                const SizedBox(height: 12),
                TextField(
                    controller: colorController,
                    decoration: const InputDecoration(labelText: 'Color')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latController,
                        decoration:
                            const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lngController,
                        decoration:
                            const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                    controller: featuresController,
                    decoration: const InputDecoration(
                        labelText: 'Features, comma separated')),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<CarStatus>(
                  initialValue: status,
                  items: CarStatus.values
                      .map((value) => DropdownMenuItem(
                          value: value, child: Text(value.name)))
                      .toList(),
                  onChanged: (value) => setModalState(
                      () => status = value ?? CarStatus.available),
                ),
                SwitchListTile(
                  value: hasGpsSignal,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('GPS signal'),
                  onChanged: (value) =>
                      setModalState(() => hasGpsSignal = value),
                ),
                SwitchListTile(
                  value: registered,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Registered'),
                  onChanged: (value) => setModalState(() => registered = value),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final target = (car ??
                      Car(
                        id: 'car-${DateTime.now().millisecondsSinceEpoch}',
                        brand: '',
                        model: '',
                        year: 2024,
                        type: typeController.text.trim(),
                        category: categoryController.text.trim(),
                        pricePerHour: 0,
                        status: status,
                        location: const GeoPoint(lat: 43.2389, lng: 76.8897),
                        imageUrl: '',
                        batteryLevel: 80,
                        rangeKm: 420,
                        seats: 5,
                        transmission: 'Automatic',
                        color: 'White',
                        description: 'Rental car',
                        features: const ['GPS tracking', 'Insurance included'],
                      ))
                  .copyWith(
                brand: brandController.text.trim(),
                model: modelController.text.trim(),
                year: int.tryParse(yearController.text) ?? 2024,
                type: typeController.text.trim(),
                category: categoryController.text.trim(),
                pricePerHour: double.tryParse(priceController.text) ?? 0,
                imageUrl: imageController.text.trim(),
                seats: int.tryParse(seatsController.text) ?? 5,
                fuelType: fuelTypeController.text.trim(),
                gasLevel: int.tryParse(gasController.text),
                engineVolume: double.tryParse(engineController.text),
                mileageKm: int.tryParse(mileageController.text) ?? 0,
                drive: driveController.text.trim(),
                batteryLevel: int.tryParse(batteryController.text) ?? 80,
                rangeKm: int.tryParse(rangeController.text) ?? 420,
                transmission: transmissionController.text.trim(),
                color: colorController.text.trim(),
                location: GeoPoint(
                  lat: double.tryParse(latController.text) ?? 43.2389,
                  lng: double.tryParse(lngController.text) ?? 76.8897,
                ),
                description: descriptionController.text.trim(),
                features: featuresController.text
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList(growable: false),
                status: status,
                hasGpsSignal: hasGpsSignal,
                registered: registered,
              );
              await ref.read(adminRepositoryProvider).saveCar(target);
              ref.invalidate(carsProvider);
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
}

class _AdminSearchField extends StatelessWidget {
  const _AdminSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class _AdminSection extends StatelessWidget {
  const _AdminSection({
    required this.title,
    required this.children,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            if (action != null) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonal(
                  onPressed: onAction,
                  child: Text(action!),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (children.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No records yet.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            else
              ...children,
          ],
        ),
      ),
    );
  }
}

class _AdminMetricCard extends StatelessWidget {
  const _AdminMetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUserCard extends ConsumerWidget {
  const _AdminUserCard({required this.user, required this.onEdit});

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AdminItemCard(
      title: user.name,
      subtitle: '${user.email} | ${user.phone}',
      actions: [
        FilledButton.tonal(onPressed: onEdit, child: const Text('Edit')),
        FilledButton.tonal(
          onPressed: () async {
            await ref.read(adminRepositoryProvider).toggleUserBlocked(user.id);
            ref.invalidate(adminOverviewProvider);
          },
          child: Text(user.isBlocked ? 'Unblock' : 'Block'),
        ),
      ],
    );
  }
}

class _AdminCarCard extends ConsumerWidget {
  const _AdminCarCard({required this.car, required this.onEdit});

  final Car car;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AdminItemCard(
      imageUrl: car.displayImageUrl,
      title: car.title,
      subtitle:
          '${car.year} | ${car.fuelType} | ${car.drive} | ${car.mileageKm} km | ${car.pricePerHour.toStringAsFixed(0)} KZT',
      actions: [
        FilledButton.tonal(onPressed: onEdit, child: const Text('Edit')),
        FilledButton.tonal(
          onPressed: () async {
            await ref.read(adminRepositoryProvider).deleteCar(car.id);
            ref.invalidate(carsProvider);
            ref.invalidate(adminOverviewProvider);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

class _AdminBookingCard extends ConsumerWidget {
  const _AdminBookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _AdminItemCard(
      title: booking.carName,
      subtitle: '${booking.userName} | ${booking.status.name}',
      actions: [
        PopupMenuButton<BookingStatus>(
          onSelected: (status) async {
            await ref.read(adminRepositoryProvider).updateBookingStatus(
                  bookingId: booking.id,
                  status: status,
                );
            ref.invalidate(bookingsControllerProvider);
            ref.invalidate(adminOverviewProvider);
          },
          itemBuilder: (context) => BookingStatus.values
              .map((status) =>
                  PopupMenuItem(value: status, child: Text(status.name)))
              .toList(),
        ),
      ],
    );
  }
}

class _AdminItemCard extends StatelessWidget {
  const _AdminItemCard({
    required this.title,
    required this.subtitle,
    required this.actions,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String? imageUrl;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;
        final details = Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageUrl != null) ...[
              AppNetworkImage(
                imageUrl: imageUrl!,
                height: 58,
                width: 78,
                borderRadius: 14,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: compact ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        );
        final actionRow = Wrap(
          alignment: compact ? WrapAlignment.start : WrapAlignment.end,
          spacing: 8,
          runSpacing: 8,
          children: actions,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    details,
                    const SizedBox(height: 10),
                    actionRow,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: actionRow,
                    ),
                  ],
                ),
        );
      },
    );
  }
}

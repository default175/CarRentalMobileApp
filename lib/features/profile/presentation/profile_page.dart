import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/app_providers.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/widgets/app_network_image.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _licenseController;
  final ImagePicker _imagePicker = ImagePicker();
  bool _initialized = false;
  bool _editing = false;
  bool _saving = false;
  String? _message;
  String? _selectedPhotoUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _syncControllers({
    required String name,
    required String email,
    required String phone,
    required String licenseNumber,
    required String? photoUrl,
  }) {
    _nameController.text = name;
    _emailController.text = email;
    _phoneController.text = phone;
    _licenseController.text = licenseNumber;
    _selectedPhotoUrl = photoUrl;
  }

  Future<void> _pickProfilePhoto() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 80,
    );
    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();
    final mimeType = _mimeTypeFromName(file.name);
    setState(() {
      _selectedPhotoUrl = 'data:$mimeType;base64,${base64Encode(bytes)}';
    });
  }

  String _mimeTypeFromName(String name) {
    final value = name.toLowerCase();
    if (value.endsWith('.png')) {
      return 'image/png';
    }
    if (value.endsWith('.webp')) {
      return 'image/webp';
    }
    if (value.endsWith('.gif')) {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser!;
    final bookings = ref.watch(bookingsControllerProvider);
    final cars = ref.watch(carsProvider).valueOrNull ?? const <Car>[];

    if (!_initialized) {
      _nameController = TextEditingController(text: user.name);
      _emailController = TextEditingController(text: user.email);
      _phoneController = TextEditingController(text: user.phone);
      _licenseController = TextEditingController(text: user.licenseNumber ?? '');
      _selectedPhotoUrl = user.photoUrl;
      _initialized = true;
    } else if (!_editing) {
      _syncControllers(
        name: user.name,
        email: user.email,
        phone: user.phone,
        licenseNumber: user.licenseNumber ?? '',
        photoUrl: user.photoUrl,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'My profile',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _saving
                          ? null
                          : () {
                              setState(() {
                                _message = null;
                                _editing = !_editing;
                                if (!_editing) {
                                  _syncControllers(
                                    name: user.name,
                                    email: user.email,
                                    phone: user.phone,
                                    licenseNumber: user.licenseNumber ?? '',
                                    photoUrl: user.photoUrl,
                                  );
                                }
                              });
                            },
                      icon: Icon(_editing ? Icons.close : Icons.edit_outlined),
                      label: Text(_editing ? 'Cancel editing' : 'Enable editing'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: ClipOval(
                        child: (_selectedPhotoUrl ?? '').trim().isNotEmpty
                            ? AppNetworkImage(
                                imageUrl: _selectedPhotoUrl!.trim(),
                                height: 68,
                                width: 68,
                                borderRadius: 34,
                              )
                            : Icon(
                                Icons.person_outline,
                                size: 34,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(user.email),
                          if (user.createdAt != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Member since ${DateFormat('dd.MM.yyyy').format(user.createdAt!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  enabled: _editing,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  enabled: _editing,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  enabled: _editing,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _licenseController,
                  enabled: _editing,
                  decoration: const InputDecoration(labelText: 'Driver license'),
                ),
                if (_editing) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickProfilePhoto,
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text('Choose photo'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedPhotoUrl = null;
                            });
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Remove photo'),
                        ),
                      ),
                    ],
                  ),
                ],
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: !_editing || _saving
                        ? null
                        : () async {
                            setState(() {
                              _saving = true;
                              _message = null;
                            });

                            try {
                              final updated = user.copyWith(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                licenseNumber: _licenseController.text.trim(),
                                photoUrl: _selectedPhotoUrl,
                              );
                              await ref.read(authControllerProvider).updateProfile(updated);
                              await ref.read(adminRepositoryProvider).saveUser(updated);
                              ref.invalidate(adminOverviewProvider);
                              setState(() {
                                _editing = false;
                                _message = 'Profile updated successfully.';
                              });
                            } catch (error) {
                              setState(() {
                                _message = '$error';
                              });
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _saving = false;
                                });
                              }
                            }
                          },
                    child: Text(_saving ? 'Saving...' : 'Save changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        bookings.when(
          data: (items) {
            final myBookings = items
                .where((booking) => booking.userId == user.id)
                .toList()
              ..sort((a, b) => b.startTime.compareTo(a.startTime));

            return Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        Text('Total bookings: ${myBookings.length}'),
                        Text(
                          'Upcoming bookings: ${myBookings.where((booking) => booking.isUpcoming).length}',
                        ),
                        Text(
                          'History entries: ${myBookings.where((booking) => booking.isHistory).length}',
                        ),
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
                          'Rental history',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        if (myBookings.isEmpty)
                          const Text('No bookings yet.')
                        else
                          ...myBookings.map(
                            (booking) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _BookingHistoryTile(
                                booking: booking,
                                car: cars.where((car) => car.id == booking.carId).firstOrNull,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () => ref.read(authControllerProvider).signOut(),
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign out'),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BookingHistoryTile extends StatelessWidget {
  const _BookingHistoryTile({
    required this.booking,
    required this.car,
  });

  final Booking booking;
  final Car? car;

  @override
  Widget build(BuildContext context) {
    final title = car?.title ?? booking.carName;
    final details = [
      '${DateFormat('dd.MM.yyyy HH:mm').format(booking.startTime)} - ${DateFormat('dd.MM.yyyy HH:mm').format(booking.endTime)}',
      '${booking.totalPrice.toStringAsFixed(0)} ${AppConstants.defaultCurrency}',
      'Status: ${booking.status.name}',
      if (car != null) '${car!.year} • ${car!.type} • ${car!.color}',
      if (booking.routeSummary != null) booking.routeSummary!,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...details.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line),
            ),
          ),
        ],
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

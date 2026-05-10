import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/app_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenseController = TextEditingController();

  bool _editing = false;
  bool _saving = false;
  bool _syncedOnce = false;
  String? _message;

  Future<void> _pickProfilePhoto() async {
    final user = ref.read(authControllerProvider).currentUser;
    if (user == null) {
      return;
    }
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 78,
    );
    if (picked == null) {
      return;
    }
    final bytes = await picked.readAsBytes();
    final updated = user.copyWith(
      photoUrl: 'data:image/jpeg;base64,${base64Encode(bytes)}',
    );
    await ref.read(authControllerProvider).updateProfile(updated);
    await ref.read(adminRepositoryProvider).saveUser(updated);
    ref.invalidate(adminOverviewProvider);
    setState(() => _message = 'Profile photo updated');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  void _syncFromUser() {
    final user = ref.read(authControllerProvider).currentUser;
    if (user == null) {
      return;
    }
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _licenseController.text = user.licenseNumber ?? '';
    _syncedOnce = true;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser!;
    final bookings = ref.watch(bookingsControllerProvider);
    final cars = ref.watch(carsProvider).valueOrNull ?? const <Car>[];

    if (!_syncedOnce || !_editing) {
      _syncFromUser();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      children: [
        _ProfileHeader(
          name: user.name,
          email: user.email,
          photoUrl: user.photoUrl,
          role: user.role,
          editing: _editing,
          onPhotoTap: _pickProfilePhoto,
          onEdit: () {
            setState(() {
              _message = null;
              _editing = !_editing;
              if (!_editing) {
                _syncFromUser();
              }
            });
          },
        ),
        const SizedBox(height: 12),
        _ShortcutGrid(
          items: [
            _Shortcut(
              icon: Icons.edit_outlined,
              title: 'Edit',
              onTap: () => setState(() => _editing = true),
            ),
            _Shortcut(
              icon: Icons.calendar_month_outlined,
              title: 'Bookings',
              onTap: () => context.push('/screens/my-bookings'),
            ),
            _Shortcut(
              icon: Icons.favorite_border,
              title: 'Favorites',
              onTap: () => context.push('/screens/favorite-cars'),
            ),
            _Shortcut(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet',
              onTap: () => context.push('/screens/wallet'),
            ),
            _Shortcut(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => context.push('/screens/settings-notifications'),
            ),
            if (user.role == AppRole.admin)
              _Shortcut(
                icon: Icons.admin_panel_settings_outlined,
                title: 'Admin',
                onTap: () => context.push('/screens/admin-panel'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _ProfileForm(
          editing: _editing,
          saving: _saving,
          nameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
          licenseController: _licenseController,
          message: _message,
          onSave: () async {
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
              );
              await ref.read(authControllerProvider).updateProfile(updated);
              await ref.read(adminRepositoryProvider).saveUser(updated);
              ref.invalidate(adminOverviewProvider);
              setState(() {
                _editing = false;
                _message = 'Profile saved';
              });
            } catch (error) {
              setState(() => _message = '$error');
            } finally {
              if (mounted) {
                setState(() => _saving = false);
              }
            }
          },
        ),
        const SizedBox(height: 12),
        bookings.when(
          data: (items) => _ProfileStats(
            bookings: items.where((item) => item.userId == user.id).toList(),
            cars: cars,
          ),
          loading: () => const _InfoCard(
            title: 'Profile summary',
            child: LinearProgressIndicator(),
          ),
          error: (_, __) => const _InfoCard(
            title: 'Profile summary',
            child: Text('Bookings are unavailable right now.'),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => ref.read(authControllerProvider).signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Sign out'),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.role,
    required this.editing,
    required this.onPhotoTap,
    required this.onEdit,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final AppRole role;
  final bool editing;
  final VoidCallback onPhotoTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial =
        name.trim().isEmpty ? 'U' : name.trim().characters.first.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onPhotoTap,
            borderRadius: BorderRadius.circular(38),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  backgroundImage: _profileImageProvider(photoUrl),
                  child: _profileImageProvider(photoUrl) == null
                      ? Text(
                          initial,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.photo_camera,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.trim().isEmpty ? 'User profile' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  role == AppRole.admin ? 'Administrator' : 'Customer',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: onEdit,
            icon: Icon(editing ? Icons.close : Icons.edit_outlined),
          ),
        ],
      ),
    );
  }
}

ImageProvider? _profileImageProvider(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  if (value.startsWith('data:image')) {
    final encoded = value.substring(value.indexOf(',') + 1);
    return MemoryImage(base64Decode(encoded));
  }
  return NetworkImage(value);
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.items});

  final List<_Shortcut> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 720 ? 3 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.4,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            final theme = Theme.of(context);
            return Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              shadowColor: Colors.black.withValues(alpha: 0.12),
              elevation: 1,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(item.icon, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Shortcut {
  const _Shortcut({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
}

class _ProfileForm extends StatelessWidget {
  const _ProfileForm({
    required this.editing,
    required this.saving,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.licenseController,
    required this.message,
    required this.onSave,
  });

  final bool editing;
  final bool saving;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController licenseController;
  final String? message;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Account details',
      child: Column(
        children: [
          TextField(
            controller: nameController,
            enabled: editing,
            decoration: const InputDecoration(labelText: 'Full name'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            enabled: editing,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: phoneController,
            enabled: editing,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: licenseController,
            enabled: editing,
            decoration: const InputDecoration(labelText: 'Driver license'),
          ),
          if (message != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(message!),
            ),
          ],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: editing && !saving ? onSave : null,
            child: Text(saving ? 'Saving...' : 'Save changes'),
          ),
        ],
      ),
    );
  }
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats({
    required this.bookings,
    required this.cars,
  });

  final List<Booking> bookings;
  final List<Car> cars;

  @override
  Widget build(BuildContext context) {
    final ordered = [...bookings]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final active =
        ordered.where((item) => item.isUpcoming || item.isActive).length;
    final completed =
        ordered.where((item) => item.status == BookingStatus.completed).length;

    return _InfoCard(
      title: 'Rental summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatPill(label: 'Total', value: '${ordered.length}'),
              _StatPill(label: 'Active', value: '$active'),
              _StatPill(label: 'Completed', value: '$completed'),
            ],
          ),
          const SizedBox(height: 14),
          Text('Recent bookings',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (ordered.isEmpty)
            const Text('No bookings yet.')
          else
            ...ordered.take(4).map(
                  (booking) => _BookingLine(
                    booking: booking,
                    car: cars
                        .where((item) => item.id == booking.carId)
                        .firstOrNull,
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 96),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}

class _BookingLine extends StatelessWidget {
  const _BookingLine({required this.booking, required this.car});

  final Booking booking;
  final Car? car;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car?.title ?? booking.carName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  DateFormat('dd.MM.yyyy HH:mm').format(booking.startTime),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 116),
              child: Text(
                '${booking.totalPrice.toStringAsFixed(0)} ${AppConstants.defaultCurrency}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

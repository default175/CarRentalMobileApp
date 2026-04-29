import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/di/app_providers.dart';
import '../../../core/services/push_notifications_service.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/car_review.dart';
import '../../../shared/models/payment_method_option.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../admin/presentation/admin_page.dart';

class AppScreenCatalogPage extends StatelessWidget {
  const AppScreenCatalogPage({super.key});

  static const sections = <_CatalogSection>[
    _CatalogSection('Authentication', [
      _CatalogItem('reset-password', 'Reset Password', Icons.lock_reset),
      _CatalogItem('otp', 'OTP Verification', Icons.pin_outlined),
      _CatalogItem('resend-otp', 'Resend OTP', Icons.sms_outlined),
    ]),
    _CatalogSection('Home', [
      _CatalogItem('all-cars', 'All Cars', Icons.directions_car),
      _CatalogItem('favorite-cars', 'Favorite Cars', Icons.favorite_border),
      _CatalogItem(
          'notifications', 'Notifications', Icons.notifications_outlined),
    ]),
    _CatalogSection('Bookmarks', [
      _CatalogItem('bookmarks', 'Bookmark', Icons.bookmark_border),
    ]),
    _CatalogSection('Booking', [
      _CatalogItem('car-booking', 'Car Booking', Icons.calendar_month),
      _CatalogItem('orders-history', 'Orders History', Icons.history),
      _CatalogItem('active-bookings', 'Active Bookings', Icons.timer_outlined),
      _CatalogItem('completed-bookings', 'Completed Bookings', Icons.done_all),
      _CatalogItem(
          'cancelled-bookings', 'Cancelled Bookings', Icons.cancel_outlined),
      _CatalogItem(
          'booking-tracking', 'Booking Tracking', Icons.route_outlined),
      _CatalogItem(
          'booking-tracking-details', 'Tracking Details', Icons.map_outlined),
    ]),
    _CatalogSection('Checkout', [
      _CatalogItem('payment', 'Payment', Icons.payments_outlined),
      _CatalogItem('order-confirmation', 'Order Confirmation',
          Icons.fact_check_outlined),
      _CatalogItem('order-successfully', 'Order Successfully',
          Icons.check_circle_outline),
      _CatalogItem(
          'track-my-order', 'Track My Order', Icons.local_shipping_outlined),
      _CatalogItem('order-status', 'Order Status', Icons.timeline),
    ]),
    _CatalogSection('Wallet', [
      _CatalogItem('wallet', 'Wallet', Icons.account_balance_wallet_outlined),
      _CatalogItem('transactions', 'Transactions', Icons.receipt_long_outlined),
    ]),
    _CatalogSection('Profile', [
      _CatalogItem('payment-methods', 'Payment Methods', Icons.credit_card),
      _CatalogItem('add-card', 'Add Card', Icons.add_card),
      _CatalogItem(
          'payment-summary', 'Payment Summary', Icons.summarize_outlined),
      _CatalogItem('payment-successfully', 'Payment Successfully',
          Icons.verified_outlined),
      _CatalogItem('change-password', 'Change Password', Icons.password),
      _CatalogItem('my-bookings', 'My Bookings', Icons.event_note_outlined),
      _CatalogItem(
          'edit-profile', 'Edit Profile', Icons.manage_accounts_outlined),
    ]),
    _CatalogSection('Reviews', [
      _CatalogItem(
          'write-review', 'Write A Review', Icons.rate_review_outlined),
      _CatalogItem('reviews', 'Reviews', Icons.reviews_outlined),
    ]),
    _CatalogSection('Settings', [
      _CatalogItem('settings-notifications', 'Notifications Settings',
          Icons.notifications_active_outlined),
      _CatalogItem(
          'privacy-policy', 'Privacy Policy', Icons.privacy_tip_outlined),
      _CatalogItem(
          'terms-of-service', 'Terms Of Service', Icons.description_outlined),
      _CatalogItem('faqs', 'FAQS', Icons.help_outline),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      itemCount: sections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        final section = sections[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.75,
              ),
              itemBuilder: (context, itemIndex) {
                final item = section.items[itemIndex];
                return _CatalogTile(item: item);
              },
            ),
          ],
        );
      },
    );
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({required this.item});

  final _CatalogItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/screens/${item.slug}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(item.icon),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppTemplateScreenPage extends ConsumerStatefulWidget {
  const AppTemplateScreenPage({
    required this.slug,
    this.carId,
    this.embedded = false,
    super.key,
  });

  final String slug;
  final String? carId;
  final bool embedded;

  @override
  ConsumerState<AppTemplateScreenPage> createState() =>
      _AppTemplateScreenPageState();
}

class _AppTemplateScreenPageState extends ConsumerState<AppTemplateScreenPage> {
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _searchController = TextEditingController();
  final _apiBaseUrlController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  bool _withDriver = true;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  int _rating = 5;
  String _category = 'All';
  String _fuelType = 'All';
  String _drive = 'All';
  RangeValues _catalogYearRange = const RangeValues(1990, 2026);
  RangeValues _catalogPriceRange = const RangeValues(0, 1000000);
  bool _catalogWithoutRentalsOnly = false;
  String? _notice;
  Car? _pendingPaymentCar;
  DateTime _pickup = DateTime.now().add(const Duration(days: 1));
  DateTime _returnAt = DateTime.now().add(const Duration(days: 2));

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _searchController.dispose();
    _apiBaseUrlController.dispose();
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _refreshApiBackedData() {
    ref.invalidate(carsProvider);
    ref.invalidate(bookingsControllerProvider);
    ref.invalidate(notificationsProvider);
    ref.invalidate(adminOverviewProvider);
  }

  Future<void> _selectPaymentMethod(String id) async {
    ref.read(selectedPaymentMethodProvider.notifier).state = id;
    await ref.read(localAppStorageProvider).saveSelectedPaymentMethodId(id);
  }

  Future<void> _deletePaymentMethod(String id) async {
    final current = ref.read(paymentMethodsProvider);
    final next = current.where((method) => method.id != id).toList();
    ref.read(paymentMethodsProvider.notifier).state = next;
    await ref.read(localAppStorageProvider).savePaymentMethods(next);
    if (next.isNotEmpty && ref.read(selectedPaymentMethodProvider) == id) {
      await _selectPaymentMethod(next.first.id);
    } else if (next.isEmpty) {
      ref.read(selectedPaymentMethodProvider.notifier).state = '';
      await ref.read(localAppStorageProvider).saveSelectedPaymentMethodId('');
    }
    if (mounted) {
      setState(() => _notice = 'Card deleted.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.slug == 'admin-panel') {
      return const AdminPage();
    }
    final item = AppScreenCatalogPage.sections
        .expand((section) => section.items)
        .where((candidate) => candidate.slug == widget.slug)
        .firstOrNull;
    final title = item?.title ?? 'Screen';
    final icon = item?.icon ?? Icons.apps;

    final body = _canRenderWithoutFleetData(widget.slug)
        ? _buildScaffoldBody(title, icon, const <Car>[], const <Booking>[])
        : AsyncValueWidget(
            value: ref.watch(carsProvider),
            data: (cars) {
              final bookings =
                  ref.watch(bookingsControllerProvider).valueOrNull ??
                      const <Booking>[];
              return _buildScaffoldBody(title, icon, cars, bookings);
            },
          );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_isHomeLike(widget.slug))
            IconButton(
              onPressed: () => context.push('/screens/favorite-cars'),
              icon: const Icon(Icons.favorite_border),
            ),
        ],
      ),
      body: body,
    );
  }

  bool _canRenderWithoutFleetData(String slug) {
    return const {
      'settings-notifications',
      'add-card',
      'wallet',
      'payment-methods',
      'change-password',
      'privacy-policy',
      'terms-of-service',
      'faqs',
    }.contains(slug);
  }

  Widget _buildScaffoldBody(
    String title,
    IconData icon,
    List<Car> cars,
    List<Booking> bookings,
  ) {
    final showHeroHeader = !widget.embedded && widget.slug != 'all-cars';
    return ListView(
      padding: EdgeInsets.fromLTRB(16, widget.embedded ? 8 : 8, 16, 104),
      children: [
        if (showHeroHeader) _HeroHeader(title: title, icon: icon),
        if (_notice != null) ...[
          const SizedBox(height: 12),
          _Notice(text: _notice!),
        ],
        if (showHeroHeader) const SizedBox(height: 14),
        ..._buildScreen(cars, bookings),
      ],
    );
  }

  List<Widget> _buildScreen(List<Car> cars, List<Booking> bookings) {
    final visibleBookings = _visibleBookings(bookings);
    switch (widget.slug) {
      case 'reset-password':
        return _resetPassword();
      case 'otp':
        return _otp();
      case 'resend-otp':
        return _resendOtp();
      case 'search-cars':
        return _allCars(cars, bookings);
      case 'all-cars':
        return _allCars(cars, bookings);
      case 'favorite-cars':
      case 'bookmarks':
        final favoriteIds = ref.watch(favoriteCarIdsProvider);
        final saved =
            cars.where((car) => favoriteIds.contains(car.id)).toList();
        if (saved.isEmpty) {
          return [
            _ActionCard(
              title: 'No favorite cars yet',
              subtitle: 'Tap the heart on any car to save it here.',
              icon: Icons.favorite_border,
              primaryText: 'Browse cars',
              onPrimary: () => context.push('/screens/all-cars'),
            ),
          ];
        }
        return _carList(saved, title: 'Saved cars', favorite: true);
      case 'notifications':
        return _notifications(cars, visibleBookings);
      case 'filter-favorite-car':
        return _filterFavorites();
      case 'car-booking':
        return _carBooking(cars);
      case 'payment':
        return _payment();
      case 'add-card':
        return _addCard();
      case 'payment-summary':
        return _paymentSummary();
      case 'payment-successfully':
        return _success('Payment successfully',
            'Your payment method was saved.', 'Continue', 'order-confirmation');
      case 'order-confirmation':
        return _orderConfirmation(cars);
      case 'order-successfully':
        return _success(
            'Order successfully',
            'Your booking is confirmed and ready to track.',
            'Track order',
            'track-my-order');
      case 'track-my-order':
      case 'booking-tracking':
        return _bookingList(visibleBookings,
            statusFilter: null, actionSlug: 'booking-tracking-details');
      case 'order-status':
        return _orderStatus(visibleBookings);
      case 'booking-tracking-details':
        return _trackingDetails(visibleBookings);
      case 'orders-history':
      case 'my-bookings':
        return _myBookings(visibleBookings);
      case 'active-bookings':
        return _bookingList(visibleBookings,
            statusFilter: (b) => b.isUpcoming || b.isActive,
            actionSlug: 'booking-tracking-details');
      case 'completed-bookings':
        return _bookingList(visibleBookings,
            statusFilter: (b) => b.status == BookingStatus.completed,
            actionSlug: 'write-review');
      case 'cancelled-bookings':
        return _bookingList(visibleBookings,
            statusFilter: (b) => b.status == BookingStatus.cancelled,
            actionSlug: 'all-cars');
      case 'wallet':
        return _wallet();
      case 'transactions':
        return _transactions(cars);
      case 'payment-methods':
        return _paymentMethods();
      case 'change-password':
        return _changePassword();
      case 'edit-profile':
        return _editProfile();
      case 'write-review':
        return _writeReview(cars, visibleBookings);
      case 'reviews':
      case 'submit-review':
        return _reviewsList(cars);
      case 'settings-notifications':
        return _settingsNotifications();
      case 'privacy-policy':
        return _textPage('Privacy Policy',
            'We store profile, booking and payment metadata only for the rental workflow. Location data is used for trip tracking and admin fleet monitoring.');
      case 'terms-of-service':
        return _textPage('Terms Of Service',
            'Use the app to book available cars, manage payments, track active orders and contact support. Cancelled bookings may follow platform refund rules.');
      case 'faqs':
        return _faqs();
      default:
        return _success('Screen ready',
            'This screen is connected to the navigation graph.', 'Back', null);
    }
  }

  List<Booking> _visibleBookings(List<Booking> bookings) {
    final user = ref.read(authControllerProvider).currentUser;
    if (user == null || user.isAdmin) {
      return bookings;
    }
    return bookings
        .where((booking) => booking.userId == user.id)
        .toList(growable: false);
  }

  List<Widget> _resetPassword() => [
        _InputCard(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                setState(() => _notice =
                    'Reset code was sent to ${_emailController.text.trim().isEmpty ? 'your email' : _emailController.text.trim()}.');
                context.push('/screens/otp?flow=reset');
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ];

  List<Widget> _otp() => [
        _InputCard(
          children: [
            const Text(
                'Enter the 4 digit code sent to your email or phone. Demo code: 1234.'),
            const SizedBox(height: 14),
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                counterText: '',
                labelText: 'OTP code',
                prefixIcon: Icon(Icons.pin_outlined),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                final flow =
                    GoRouterState.of(context).uri.queryParameters['flow'];
                if (flow == 'reset') {
                  context.push('/screens/change-password');
                } else if (ref.read(authControllerProvider).isAuthenticated) {
                  context.go('/app');
                } else {
                  context.go('/login');
                }
              },
              child: const Text('Verify'),
            ),
            TextButton(
              onPressed: () => context.push('/screens/resend-otp'),
              child: const Text('Resend code'),
            ),
          ],
        ),
      ];

  List<Widget> _resendOtp() => [
        _ActionCard(
          title: 'Resend OTP',
          subtitle: 'A new verification code will be sent to the same contact.',
          icon: Icons.sms_outlined,
          primaryText: 'Resend OTP',
          onPrimary: () => context.push('/screens/otp'),
        ),
      ];

  List<Widget> _allCars(List<Car> cars, List<Booking> bookings) {
    final params = GoRouterState.of(context).uri.queryParameters;
    final query =
        (params['query'] ?? _searchController.text).trim().toLowerCase();
    final initialCategory = params['category'];
    final status = params['status'];
    final effectiveCategory = _category != 'All'
        ? _category
        : initialCategory != null && initialCategory.isNotEmpty
            ? initialCategory
            : 'All';
    final categories = ['All', ...cars.map((car) => car.category).toSet()];
    final filtered = cars.where((car) {
      final matchesQuery = query.isEmpty ||
          car.title.toLowerCase().contains(query) ||
          car.brand.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          '${car.year}'.contains(query) ||
          car.type.toLowerCase().contains(query) ||
          car.category.toLowerCase().contains(query) ||
          car.fuelType.toLowerCase().contains(query) ||
          car.drive.toLowerCase().contains(query) ||
          car.transmission.toLowerCase().contains(query) ||
          car.features.any((feature) => feature.toLowerCase().contains(query));
      final matchesCategory = effectiveCategory == 'All' ||
          car.category.toLowerCase() == effectiveCategory.toLowerCase() ||
          car.type.toLowerCase() == effectiveCategory.toLowerCase();
      final matchesFuel = _fuelType == 'All' || car.fuelType == _fuelType;
      final matchesDrive = _drive == 'All' || car.drive == _drive;
      final matchesYear = car.year >= _catalogYearRange.start.round() &&
          car.year <= _catalogYearRange.end.round();
      final hasActiveRental = bookings.any((booking) {
        final active = booking.status == BookingStatus.created ||
            booking.status == BookingStatus.confirmed ||
            booking.status == BookingStatus.active;
        return booking.carId == car.id && active;
      });
      final matchesPrice = car.pricePerHour >= _catalogPriceRange.start &&
          car.pricePerHour <= _catalogPriceRange.end;
      final matchesStatus = status == null || car.status.name == status;
      final matchesRental = !_catalogWithoutRentalsOnly || !hasActiveRental;
      return matchesQuery &&
          matchesCategory &&
          matchesFuel &&
          matchesDrive &&
          matchesYear &&
          matchesPrice &&
          matchesRental &&
          matchesStatus;
    }).toList(growable: false);
    final availableCars =
        cars.where((car) => car.status == CarStatus.available).toList();
    final maxCatalogPrice = (availableCars.isEmpty ? cars : availableCars)
        .fold<double>(
            0, (max, car) => car.pricePerHour > max ? car.pricePerHour : max);
    final safeMaxPrice =
        maxCatalogPrice <= 0 ? 1.0 : maxCatalogPrice.ceilToDouble();
    final safePriceRange = RangeValues(
      _catalogPriceRange.start.clamp(0, safeMaxPrice).toDouble(),
      _catalogPriceRange.end.clamp(0, safeMaxPrice).toDouble(),
    );

    return [
      SizedBox(
        height: 46,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final category = categories[index];
            final selected = category == effectiveCategory;
            return ChoiceChip(
              selected: selected,
              label: Text(category),
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerLow,
              side: BorderSide(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).dividerColor.withValues(alpha: 0.35),
              ),
              onSelected: (_) => setState(() => _category = category),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          hintText: 'Search by car, year, fuel, drive or characteristic',
          prefixIcon: Icon(Icons.search),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<String>(
              initialValue: _fuelType,
              decoration: const InputDecoration(labelText: 'Fuel'),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Electric', child: Text('Electric')),
                DropdownMenuItem(value: 'Petrol', child: Text('Petrol')),
                DropdownMenuItem(value: 'Gas', child: Text('Gas')),
                DropdownMenuItem(value: 'Diesel', child: Text('Diesel')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) => setState(() => _fuelType = value ?? 'All'),
            ),
          ),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<String>(
              initialValue: _drive,
              decoration: const InputDecoration(labelText: 'Drive'),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'front', child: Text('Front')),
                DropdownMenuItem(value: 'rear', child: Text('Rear')),
                DropdownMenuItem(value: 'full', child: Text('Full')),
              ],
              onChanged: (value) => setState(() => _drive = value ?? 'All'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _RangeFilterCard(
        label:
            'Year: ${_catalogYearRange.start.round()} - ${_catalogYearRange.end.round()}',
        values: _catalogYearRange,
        min: 1990,
        max: 2026,
        divisions: 36,
        startLabel: '${_catalogYearRange.start.round()}',
        endLabel: '${_catalogYearRange.end.round()}',
        onChanged: (value) => setState(() => _catalogYearRange = value),
      ),
      const SizedBox(height: 10),
      _RangeFilterCard(
        label:
            'Price: ${safePriceRange.start.round()} - ${safePriceRange.end.round()} KZT/h',
        values: safePriceRange,
        min: 0,
        max: safeMaxPrice,
        divisions: safeMaxPrice.round().clamp(1, 100),
        startLabel: '${safePriceRange.start.round()}',
        endLabel: '${safePriceRange.end.round()} KZT/h',
        onChanged: (value) => setState(() => _catalogPriceRange = value),
      ),
      SwitchListTile(
        value: _catalogWithoutRentalsOnly,
        onChanged: (value) =>
            setState(() => _catalogWithoutRentalsOnly = value),
        title: const Text('Without active rental'),
        contentPadding: EdgeInsets.zero,
      ),
      const SizedBox(height: 14),
      ..._carList(
        filtered,
        title: 'All cars',
        showTitle: widget.embedded,
      ),
    ];
  }

  List<Widget> _carList(List<Car> cars,
          {required String title,
          bool favorite = false,
          bool showTitle = true}) =>
      [
        if (showTitle) ...[
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge)),
              if (favorite)
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/screens/filter-favorite-car'),
                  icon: const Icon(Icons.tune),
                  label: const Text('Filter'),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        if (cars.isEmpty)
          const _Notice(text: 'No cars found.')
        else
          ...cars.map((car) => _CarListTile(car: car)),
      ];

  List<Widget> _notifications(List<Car> cars, List<Booking> bookings) {
    final firstCar = cars.firstOrNull;
    return [
      _NavigationTile(
        icon: Icons.event_available,
        title: 'Booking confirmed',
        subtitle: bookings.isEmpty
            ? 'Create your first booking.'
            : '${bookings.first.carName} is ready.',
        onTap: () => context.push('/screens/order-status'),
      ),
      _NavigationTile(
        icon: Icons.local_offer_outlined,
        title: 'New deal',
        subtitle: firstCar == null
            ? 'Open catalog to browse cars.'
            : '${firstCar.title} has a special price today.',
        onTap: () => firstCar == null
            ? context.push('/screens/all-cars')
            : context.push('/cars/${firstCar.id}'),
      ),
      _NavigationTile(
        icon: Icons.notifications_active_outlined,
        title: 'Notification settings',
        subtitle: 'Configure booking reminders and trip alerts.',
        onTap: () => context.push('/screens/settings-notifications'),
      ),
    ];
  }

  List<Widget> _filterFavorites() => [
        _InputCard(
          children: [
            const Text('Favorite car filters'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                Chip(label: Text('SUV')),
                Chip(label: Text('Sedan')),
                Chip(label: Text('Luxury')),
                Chip(label: Text('Daily')),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/screens/favorite-cars'),
              child: const Text('Apply filter'),
            ),
          ],
        ),
      ];

  List<Widget> _carBooking(List<Car> cars) {
    final selected = cars.where((car) => car.id == widget.carId).firstOrNull ??
        cars.where((car) => car.status != CarStatus.maintenance).firstOrNull;
    if (selected == null) {
      return [const _Notice(text: 'No car available for booking.')];
    }

    return [
      _MiniCarSummary(car: selected),
      const SizedBox(height: 12),
      _InputCard(
        children: [
          SwitchListTile(
            value: _withDriver,
            onChanged: (value) => setState(() => _withDriver = value),
            title: const Text('With driver'),
            contentPadding: EdgeInsets.zero,
          ),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Pick up location',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Return location',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month),
            title: const Text('Pick up date & time'),
            subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(_pickup)),
            onTap: () => _pickDateTime(
              initial: _pickup,
              onPicked: (value) {
                setState(() {
                  _pickup = value;
                  if (!_returnAt.isAfter(_pickup)) {
                    _returnAt = _pickup.add(const Duration(days: 1));
                  }
                });
              },
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_available),
            title: const Text('Return date & time'),
            subtitle: Text(DateFormat('dd.MM.yyyy HH:mm').format(_returnAt)),
            onTap: () => _pickDateTime(
              initial: _returnAt,
              firstDate: _pickup,
              onPicked: (value) => setState(() => _returnAt = value),
            ),
          ),
          FilledButton(
            onPressed: () async {
              _pendingPaymentCar = selected;
              if (mounted) {
                context.push('/screens/payment?carId=${selected.id}');
              }
            },
            child: const Text('Continue to Payment'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _payment() => [
        ...ref.watch(paymentMethodsProvider).map(
              (method) => _PaymentCard(
                selected: ref.watch(selectedPaymentMethodProvider) == method.id,
                title: method.title,
                subtitle: method.subtitle,
                onTap: () => _selectPaymentMethod(method.id),
              ),
            ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => context.push('/screens/add-card'),
          icon: const Icon(Icons.add_card),
          label: const Text('Add new card'),
        ),
        const SizedBox(height: 10),
        FilledButton(
          onPressed: () {
            if (ref.read(paymentMethodsProvider).isEmpty ||
                ref.read(selectedPaymentMethodProvider).isEmpty) {
              setState(
                  () => _notice = 'Add and select a payment method first.');
              return;
            }
            final carId =
                GoRouterState.of(context).uri.queryParameters['carId'];
            final allCars = ref.read(carsProvider).valueOrNull ?? const <Car>[];
            final selected = _pendingPaymentCar ??
                allCars.where((car) => car.id == carId).firstOrNull ??
                allCars.firstOrNull;
            if (selected != null) {
              final method = ref.read(selectedPaymentMethodProvider);
              setState(() => _notice = 'Payment method: $method');
            }
            if (mounted && selected != null) {
              context.push('/screens/order-confirmation?carId=${selected.id}');
            }
          },
          child: const Text('Continue to confirmation'),
        ),
      ];

  Future<void> _pickDateTime({
    required DateTime initial,
    required ValueChanged<DateTime> onPicked,
    DateTime? firstDate,
  }) async {
    final date = await showDatePicker(
      context: context,
      firstDate: firstDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDate: initial.isBefore(firstDate ?? DateTime.now())
          ? (firstDate ?? DateTime.now())
          : initial,
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) {
      return;
    }
    onPicked(DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  List<Widget> _addCard() => [
        _InputCard(
          children: [
            TextField(
                controller: _cardHolderController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z ]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Card holder',
                  helperText: 'Latin letters, as printed on the card',
                )),
            const SizedBox(height: 12),
            TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Card number',
                  helperText: '15-16 digits',
                )),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: TextField(
                        controller: _cardExpiryController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                          _ExpiryDateInputFormatter(),
                        ],
                        decoration: const InputDecoration(labelText: 'MM/YY'))),
                const SizedBox(width: 12),
                Expanded(
                    child: TextField(
                        controller: _cardCvvController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(labelText: 'CVV'))),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () async {
                final validationError = _validateCardFields();
                if (validationError != null) {
                  setState(() => _notice = validationError);
                  return;
                }
                final digits = _cardNumberController.text
                    .replaceAll(RegExp(r'[^0-9]'), '');
                final last4 = digits.length >= 4
                    ? digits.substring(digits.length - 4)
                    : '0000';
                final id =
                    'card-$last4-${DateTime.now().millisecondsSinceEpoch}';
                final current = ref.read(paymentMethodsProvider);
                ref.read(paymentMethodsProvider.notifier).state = [
                  ...current,
                  PaymentMethodOption(
                    id: id,
                    title: 'Credit card',
                    subtitle: 'Card **** $last4',
                  ),
                ];
                await ref
                    .read(localAppStorageProvider)
                    .savePaymentMethods(ref.read(paymentMethodsProvider));
                setState(() {
                  _notice = 'Card saved.';
                });
                await _selectPaymentMethod(id);
                _cardHolderController.clear();
                _cardNumberController.clear();
                _cardExpiryController.clear();
                _cardCvvController.clear();
                if (mounted) {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/screens/wallet');
                  }
                }
              },
              child: const Text('Save Card'),
            ),
          ],
        ),
      ];

  String? _validateCardFields() {
    final holder = _cardHolderController.text.trim();
    final digits = _cardNumberController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final expiry = _cardExpiryController.text.trim();
    final cvv = _cardCvvController.text.trim();

    if (holder.isEmpty ||
        !RegExp(r'^[A-Za-z]+(?: [A-Za-z]+)+$').hasMatch(holder)) {
      return 'Enter card holder name in Latin letters, for example IVAN IVANOV.';
    }
    if (digits.length < 15 || digits.length > 16) {
      return 'Card number must contain 15-16 digits.';
    }
    final expiryMatch = RegExp(r'^(0[1-9]|1[0-2])/(\d{2})$').firstMatch(expiry);
    if (expiryMatch == null) {
      return 'Expiry date must be in MM/YY format.';
    }
    final month = int.parse(expiryMatch.group(1)!);
    final year = 2000 + int.parse(expiryMatch.group(2)!);
    final lastDay = DateTime(year, month + 1, 0, 23, 59, 59);
    if (lastDay.isBefore(DateTime.now())) {
      return 'Card expiry date is in the past.';
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(cvv)) {
      return 'CVV must contain 3 or 4 digits.';
    }
    return null;
  }

  List<Widget> _paymentSummary() => [
        const _SummaryRow(label: 'Per day car rent', value: '22000 KZT'),
        const _SummaryRow(label: 'Total 2 day rent', value: '44000 KZT'),
        const Divider(),
        const _SummaryRow(
            label: 'Total payment', value: '44000 KZT', strong: true),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: () => context.push('/screens/payment-successfully'),
          child: const Text('Confirm Payment'),
        ),
      ];

  List<Widget> _orderConfirmation(List<Car> cars) {
    final carId = GoRouterState.of(context).uri.queryParameters['carId'];
    final selected = cars.where((car) => car.id == carId).firstOrNull ??
        _pendingPaymentCar ??
        cars.firstOrNull;
    return [
      if (selected != null) ...[
        _MiniCarSummary(car: selected),
        const SizedBox(height: 12),
      ],
      _ActionCard(
        title: 'Confirm your order',
        subtitle: 'Car, dates, payment method and contact data are ready.',
        icon: Icons.fact_check_outlined,
        primaryText: 'Confirm Order',
        onPrimary: () async {
          final user = ref.read(authControllerProvider).currentUser;
          if (selected == null || user == null) {
            setState(() => _notice = 'Choose a car and sign in first.');
            return;
          }
          await ref.read(bookingsControllerProvider.notifier).createBooking(
                user: user,
                car: selected,
                start: _pickup,
                end: _returnAt,
              );
          ref.invalidate(notificationsProvider);
          ref.invalidate(adminOverviewProvider);
          if (mounted) {
            context.push('/screens/order-successfully');
          }
        },
      ),
    ];
  }

  List<Widget> _myBookings(List<Booking> bookings) => [
        _NavigationTile(
          icon: Icons.timer_outlined,
          title: 'Active',
          subtitle:
              '${bookings.where((booking) => booking.isUpcoming || booking.isActive).length} bookings',
          onTap: () => context.push('/screens/active-bookings'),
        ),
        _NavigationTile(
          icon: Icons.done_all,
          title: 'Completed',
          subtitle:
              '${bookings.where((booking) => booking.status == BookingStatus.completed).length} bookings',
          onTap: () => context.push('/screens/completed-bookings'),
        ),
        _NavigationTile(
          icon: Icons.cancel_outlined,
          title: 'Cancelled',
          subtitle:
              '${bookings.where((booking) => booking.status == BookingStatus.cancelled).length} bookings',
          onTap: () => context.push('/screens/cancelled-bookings'),
        ),
        const SizedBox(height: 12),
        ..._bookingList(bookings,
            statusFilter: null, actionSlug: 'booking-tracking-details'),
      ];

  List<Widget> _bookingList(
    List<Booking> bookings, {
    required bool Function(Booking booking)? statusFilter,
    required String actionSlug,
  }) {
    final filtered =
        statusFilter == null ? bookings : bookings.where(statusFilter).toList();
    if (filtered.isEmpty) {
      return [
        _ActionCard(
          title: 'No bookings yet',
          subtitle: 'Choose a car and create your first rental.',
          icon: Icons.calendar_month,
          primaryText: 'Browse cars',
          onPrimary: () => context.push('/screens/all-cars'),
        ),
      ];
    }
    return filtered
        .map(
            (booking) => _BookingTile(booking: booking, actionSlug: actionSlug))
        .toList();
  }

  List<Widget> _orderStatus(List<Booking> bookings) {
    final bookingId =
        GoRouterState.of(context).uri.queryParameters['bookingId'];
    final booking =
        bookings.where((item) => item.id == bookingId).firstOrNull ??
            bookings
                .where((item) => item.isActive || item.isUpcoming)
                .firstOrNull ??
            bookings.firstOrNull;
    final isCancelled = booking?.status == BookingStatus.cancelled;
    final isCompleted = booking?.status == BookingStatus.completed;
    return [
      _ActionCard(
        title: booking?.carName ?? 'Order status',
        subtitle: booking == null
            ? 'No active order yet.'
            : 'Status: ${booking.status.name}. ${DateFormat('dd.MM HH:mm').format(booking.startTime)} - ${DateFormat('dd.MM HH:mm').format(booking.endTime)}',
        icon: isCancelled ? Icons.cancel_outlined : Icons.timeline,
        primaryText: isCancelled
            ? 'Book Another Car'
            : isCompleted
                ? 'Write a Review'
                : 'Back to bookings',
        onPrimary: () => context.push(
          isCancelled
              ? '/screens/all-cars'
              : isCompleted
                  ? '/screens/write-review'
                  : '/screens/my-bookings',
        ),
      ),
    ];
  }

  List<Widget> _trackingDetails(List<Booking> bookings) {
    final bookingId =
        GoRouterState.of(context).uri.queryParameters['bookingId'];
    final booking =
        bookings.where((item) => item.id == bookingId).firstOrNull ??
            bookings
                .where((item) => item.isActive || item.isUpcoming)
                .firstOrNull ??
            bookings.firstOrNull;

    if (booking == null) {
      return [
        _ActionCard(
          title: 'No tracking details',
          subtitle: 'Create or choose a booking first.',
          icon: Icons.route_outlined,
          primaryText: 'Open bookings',
          onPrimary: () => context.push('/screens/orders-history'),
        ),
      ];
    }

    return [
      _InputCard(
        children: [
          Icon(Icons.route_outlined,
              color: Theme.of(context).colorScheme.primary, size: 34),
          const SizedBox(height: 12),
          Text(booking.carName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Status: ${booking.status.name}'),
          Text(
            '${DateFormat('dd.MM HH:mm').format(booking.startTime)} - ${DateFormat('dd.MM HH:mm').format(booking.endTime)}',
          ),
          if (booking.routeSummary != null) ...[
            const SizedBox(height: 8),
            Text(booking.routeSummary!),
          ],
          const SizedBox(height: 8),
          Text('${booking.distanceKm.toStringAsFixed(1)} km'),
        ],
      ),
    ];
  }

  List<Widget> _wallet() => [
        Text('Payment methods', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (ref.watch(paymentMethodsProvider).isEmpty)
          _ActionCard(
            title: 'No payment methods',
            subtitle: 'Add a card before confirming a booking.',
            icon: Icons.credit_card_off_outlined,
            primaryText: 'Add new card',
            onPrimary: () => context.push('/screens/add-card'),
          ),
        ...ref.watch(paymentMethodsProvider).map(
              (method) => _PaymentCard(
                selected: ref.watch(selectedPaymentMethodProvider) == method.id,
                title: method.title,
                subtitle: method.subtitle,
                onTap: () => _selectPaymentMethod(method.id),
                onDelete: () => _deletePaymentMethod(method.id),
              ),
            ),
        OutlinedButton.icon(
          onPressed: () => context.push('/screens/add-card'),
          icon: const Icon(Icons.add_card),
          label: const Text('Add new card'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
            onPressed: () => context.push('/screens/transactions'),
            child: const Text('Transactions history')),
      ];

  List<Widget> _transactions(List<Car> cars) => [
        ...cars.take(4).map(
              (car) => _NavigationTile(
                icon: Icons.receipt_long_outlined,
                title: 'Car rental payment',
                subtitle:
                    '${car.title} | ${car.pricePerHour.toStringAsFixed(0)} KZT',
                onTap: () => context.push('/cars/${car.id}'),
              ),
            ),
      ];

  List<Widget> _paymentMethods() => [
        ...ref.watch(paymentMethodsProvider).map(
              (method) => _PaymentCard(
                selected: ref.watch(selectedPaymentMethodProvider) == method.id,
                title: method.title,
                subtitle: method.subtitle,
                onTap: () => _selectPaymentMethod(method.id),
                onDelete: method.id.startsWith('card-')
                    ? () => _deletePaymentMethod(method.id)
                    : null,
              ),
            ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => context.push('/screens/add-card'),
          icon: const Icon(Icons.add_card),
          label: const Text('Add new card'),
        ),
      ];

  List<Widget> _changePassword() => [
        _InputCard(
          children: [
            TextField(
              controller: _passwordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                labelText: 'New password',
                suffixIcon: IconButton(
                  tooltip: _showNewPassword ? 'Hide password' : 'Show password',
                  onPressed: () => setState(
                    () => _showNewPassword = !_showNewPassword,
                  ),
                  icon: Icon(
                    _showNewPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm password',
                suffixIcon: IconButton(
                  tooltip:
                      _showConfirmPassword ? 'Hide password' : 'Show password',
                  onPressed: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                setState(
                    () => _notice = 'Password updated. Please sign in again.');
                ref.read(authControllerProvider).signOut();
              },
              child: const Text('Update Password'),
            ),
          ],
        ),
      ];

  List<Widget> _editProfile() {
    final user = ref.read(authControllerProvider).currentUser;
    _nameController.text =
        _nameController.text.isEmpty ? user?.name ?? '' : _nameController.text;
    _emailController.text = _emailController.text.isEmpty
        ? user?.email ?? ''
        : _emailController.text;
    _phoneController.text = _phoneController.text.isEmpty
        ? user?.phone ?? ''
        : _phoneController.text;
    return [
      _InputCard(
        children: [
          TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Id')),
          const SizedBox(height: 12),
          TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone number')),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final current = ref.read(authControllerProvider).currentUser;
              if (current != null) {
                final updated = current.copyWith(
                  name: _nameController.text.trim(),
                  email: _emailController.text.trim(),
                  phone: _phoneController.text.trim(),
                );
                await ref.read(authControllerProvider).updateProfile(updated);
                await ref.read(adminRepositoryProvider).saveUser(updated);
                setState(() => _notice = 'Profile saved.');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _writeReview(List<Car> cars, List<Booking> bookings) {
    final params = GoRouterState.of(context).uri.queryParameters;
    final carId = params['carId'];
    final completed = bookings
        .where((booking) => booking.status == BookingStatus.completed)
        .firstOrNull;
    final target = carId == null
        ? cars.where((car) => car.id == completed?.carId).firstOrNull ??
            cars.firstOrNull
        : cars.where((car) => car.id == carId).firstOrNull;

    if (target == null) {
      return [const _Notice(text: 'No car is available for review.')];
    }

    return [
      _MiniCarSummary(car: target),
      const SizedBox(height: 12),
      _InputCard(
        children: [
          Text(
            'Your review will be saved on ${target.title} and shown on the car details page.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => setState(() => _rating = index + 1),
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFB020),
                ),
              ),
            ),
          ),
          TextField(
            controller: _messageController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Comment'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final user = ref.read(authControllerProvider).currentUser;
              final comment = _messageController.text.trim();
              if (comment.isEmpty) {
                setState(() => _notice = 'Write a comment before submitting.');
                return;
              }
              final current = ref.read(carReviewsProvider);
              ref.read(carReviewsProvider.notifier).state = [
                ...current,
                CarReview(
                  id: 'review-${DateTime.now().microsecondsSinceEpoch}',
                  userId: user?.id ?? 'guest',
                  userName: user?.name ?? 'Guest',
                  carId: target.id,
                  carName: target.title,
                  rating: _rating,
                  comment: comment,
                  createdAt: DateTime.now(),
                ),
              ];
              try {
                await ref.read(apiClientProvider).dio.post<void>(
                  '/api/reviews',
                  data: {
                    'user_id': user?.id ?? 'guest',
                    'user_name': user?.name ?? 'Guest',
                    'car_id': target.id,
                    'car_name': target.title,
                    'rating': _rating,
                    'comment': comment,
                  },
                );
              } catch (_) {
                // The local review stays visible even when the backend is offline.
              }
              _messageController.clear();
              setState(() => _notice = 'Review saved.');
              if (mounted) {
                context.replace('/cars/${target.id}');
              }
            },
            child: const Text('Save Review'),
          ),
        ],
      ),
    ];
  }

  List<Widget> _reviewsList(List<Car> cars) {
    final carId = GoRouterState.of(context).uri.queryParameters['carId'];
    final allReviews = ref.watch(carReviewsProvider);
    final reviews = carId == null
        ? allReviews
        : allReviews.where((review) => review.carId == carId).toList();
    final carTitle = carId == null
        ? null
        : cars.where((car) => car.id == carId).firstOrNull?.title;
    if (reviews.isEmpty) {
      return [
        _ActionCard(
          title: 'No reviews yet',
          subtitle: carTitle == null
              ? 'Completed bookings can be reviewed from Booking history.'
              : 'No reviews for $carTitle yet.',
          icon: Icons.reviews_outlined,
          primaryText: 'Open bookings',
          onPrimary: () => context.push('/screens/completed-bookings'),
        ),
      ];
    }

    return [
      if (carTitle != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '$carTitle reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ...reviews.reversed.map(
        (review) => _NavigationTile(
          icon: Icons.star_rate,
          title: '${review.carName} - ${review.rating}/5',
          subtitle: review.comment,
          onTap: () => context.push('/cars/${review.carId}'),
        ),
      )
    ];
  }

  List<Widget> _settingsNotifications() {
    final apiSettings = ref.watch(apiConnectionSettingsProvider);
    final pushEnabled = ref.watch(pushNotificationsEnabledProvider);
    if (_apiBaseUrlController.text.isEmpty) {
      _apiBaseUrlController.text = apiSettings.baseUrl;
    }

    return [
      _InputCard(
        children: [
          Text(
            'Backend API',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'For a real phone use a reachable address, for example http://192.168.1.25:8080 or https://api.your-domain.kz. Emulator-only 10.0.2.2 is not required.',
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _apiBaseUrlController,
            decoration: const InputDecoration(
              labelText: 'API base URL',
              prefixIcon: Icon(Icons.dns_outlined),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: apiSettings.enabled,
            onChanged: (value) async {
              await ref.read(apiConnectionSettingsProvider.notifier).save(
                    baseUrl: _apiBaseUrlController.text,
                    enabled: value,
                  );
              _refreshApiBackedData();
              setState(() {
                _notice = value
                    ? 'Backend API enabled.'
                    : 'Backend API disabled. Local demo data is active.';
              });
            },
            title: const Text('Use MongoDB backend API'),
            subtitle: Text(
              apiSettings.shouldUseBackend
                  ? 'Active: ${apiSettings.baseUrl}'
                  : 'Off: app uses local demo data until API is enabled.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              await ref.read(apiConnectionSettingsProvider.notifier).save(
                    baseUrl: _apiBaseUrlController.text,
                    enabled: apiSettings.enabled,
                  );
              _refreshApiBackedData();
              setState(() => _notice = 'API settings saved.');
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save API Settings'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(apiConnectionSettingsProvider.notifier).save(
                    baseUrl: _apiBaseUrlController.text,
                    enabled: false,
                  );
              _refreshApiBackedData();
              setState(() {
                _notice = 'Backend API disabled. Local demo data is active.';
              });
            },
            icon: const Icon(Icons.cloud_off_outlined),
            label: const Text('Use local demo data'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(apiConnectionSettingsProvider.notifier).reset();
              _apiBaseUrlController.text =
                  ref.read(apiConnectionSettingsProvider).baseUrl;
              _refreshApiBackedData();
              setState(() => _notice = 'API settings reset.');
            },
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset API Settings'),
          ),
        ],
      ),
      SwitchListTile(
        value: pushEnabled,
        onChanged: (value) async {
          ref.read(pushNotificationsEnabledProvider.notifier).state = value;
          await ref
              .read(localAppStorageProvider)
              .savePushNotificationsEnabled(value);
          PushNotificationsService.instance
              ?.setLocalNotificationsEnabled(value);
          setState(() {
            _notice = value
                ? 'Push notifications enabled.'
                : 'Push notifications disabled.';
          });
        },
        title: const Text('Push notifications'),
        subtitle: const Text('Show booking alerts as phone notifications.'),
        contentPadding: EdgeInsets.zero,
      ),
      SwitchListTile(
          value: true,
          onChanged: pushEnabled ? (_) {} : null,
          title: const Text('Booking reminders')),
      SwitchListTile(
          value: true,
          onChanged: pushEnabled ? (_) {} : null,
          title: const Text('Payment alerts')),
      SwitchListTile(
          value: false,
          onChanged: pushEnabled ? (_) {} : null,
          title: const Text('Marketing deals')),
    ];
  }

  List<Widget> _textPage(String title, String text) => [
        _InputCard(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(text),
          ],
        ),
      ];

  List<Widget> _faqs() => const [
        _FaqTile(
            question: 'How do I book a car?',
            answer:
                'Choose a car, open details, select booking dates and continue to payment.'),
        _FaqTile(
            question: 'Can I track a booking?',
            answer:
                'Users can track their order status. Vehicle GPS is available to admins for rented cars.'),
        _FaqTile(
            question: 'How do payments work?',
            answer:
                'Select a saved card or add a new one, then confirm the order.'),
      ];

  List<Widget> _success(
          String title, String subtitle, String button, String? slug) =>
      [
        _ActionCard(
          title: title,
          subtitle: subtitle,
          icon: Icons.check_circle_outline,
          primaryText: button,
          onPrimary: slug == null
              ? () => Navigator.of(context).maybePop()
              : () => context.push('/screens/$slug'),
        ),
        OutlinedButton(
          onPressed: () => context.go('/app'),
          child: const Text('Back to Home'),
        ),
      ];

  bool _isHomeLike(String slug) => slug == 'search-cars' || slug == 'all-cars';
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryText,
    required this.onPrimary,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryText;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 38),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 14),
            FilledButton(onPressed: onPrimary, child: Text(primaryText)),
          ],
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          foregroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _CarListTile extends ConsumerWidget {
  const _CarListTile({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteCarIdsProvider);
    final reviews = ref.watch(carReviewsProvider);
    final favorite = favorites.contains(car.id);
    final rating = _averageRating(reviews, car.id);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/cars/${car.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AppNetworkImage(
                imageUrl: car.displayImageUrl,
                height: 82,
                width: 116,
                borderRadius: 14,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(car.model,
                        style: Theme.of(context).textTheme.titleMedium),
                    Text('${car.brand} | ${car.year} | ${car.fuelType}'),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 15, color: Color(0xFFFFB020)),
                        const SizedBox(width: 4),
                        Text(rating.toStringAsFixed(1)),
                      ],
                    ),
                    Text(
                      '${car.pricePerHour.toStringAsFixed(0)} ${AppConstants.defaultCurrency}/hour',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${car.drive} drive | ${car.mileageKm} km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  final next = {...favorites};
                  favorite ? next.remove(car.id) : next.add(car.id);
                  ref.read(favoriteCarIdsProvider.notifier).state = next;
                  ref.read(localAppStorageProvider).saveFavoriteCarIds(next);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        favorite
                            ? 'Removed from favorites'
                            : 'Added to favorites',
                      ),
                    ),
                  );
                },
                icon: Icon(
                  favorite ? Icons.favorite : Icons.favorite_border,
                  color: favorite ? Colors.redAccent : null,
                ),
              ),
            ],
          ),
        ),
      ),
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

class _MiniCarSummary extends StatelessWidget {
  const _MiniCarSummary({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            AppNetworkImage(
              imageUrl: car.displayImageUrl,
              height: 90,
              width: 128,
              borderRadius: 16,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(car.title,
                      style: Theme.of(context).textTheme.titleMedium),
                  Text('${car.category} | ${car.transmission}'),
                  Text(
                    '${car.pricePerHour.toStringAsFixed(0)} ${AppConstants.defaultCurrency}/hour',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTile extends ConsumerWidget {
  const _BookingTile({required this.booking, required this.actionSlug});

  final Booking booking;
  final String actionSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelled = booking.status == BookingStatus.cancelled;
    final isCompleted = booking.status == BookingStatus.completed;
    final canCancel = !isCancelled && !isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 6),
                Text(
                    '${booking.endTime.difference(booking.startTime).inHours}h rental'),
                const Spacer(),
                Chip(label: Text(booking.status.name)),
              ],
            ),
            Text(booking.carName,
                style: Theme.of(context).textTheme.titleMedium),
            Text(DateFormat('dd.MM.yyyy HH:mm').format(booking.startTime)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: canCancel
                        ? () async {
                            await ref
                                .read(bookingsControllerProvider.notifier)
                                .updateStatus(
                                  bookingId: booking.id,
                                  status: BookingStatus.cancelled,
                                );
                            ref.invalidate(notificationsProvider);
                            ref.invalidate(adminOverviewProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Booking cancelled'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: Text(isCancelled ? 'Cancelled' : 'Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      if (isCancelled) {
                        context.push('/screens/car-booking');
                      } else if (isCompleted) {
                        context.push('/screens/write-review');
                      } else {
                        context.push(
                            '/screens/$actionSlug?bookingId=${booking.id}');
                      }
                    },
                    child: Text(
                      isCancelled
                          ? 'Rebook'
                          : isCompleted
                              ? 'Review'
                              : 'Track',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeFilterCard extends StatelessWidget {
  const _RangeFilterCard({
    required this.label,
    required this.values,
    required this.min,
    required this.max,
    required this.divisions,
    required this.startLabel,
    required this.endLabel,
    required this.onChanged,
  });

  final String label;
  final RangeValues values;
  final double min;
  final double max;
  final int divisions;
  final String startLabel;
  final String endLabel;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleSmall),
            RangeSlider(
              values: values,
              min: min,
              max: max,
              divisions: divisions,
              labels: RangeLabels(startLabel, endLabel),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && index % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final text = digits.length <= 2
        ? digits
        : '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          leading: Icon(Icons.credit_card,
              color: Theme.of(context).colorScheme.primary),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text(subtitle),
          trailing: Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (onDelete != null)
                IconButton(
                  tooltip: 'Delete card',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? Theme.of(context).colorScheme.primary : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title:
            Text(question, style: const TextStyle(fontWeight: FontWeight.w800)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text),
    );
  }
}

class _CatalogSection {
  const _CatalogSection(this.title, this.items);

  final String title;
  final List<_CatalogItem> items;
}

class _CatalogItem {
  const _CatalogItem(this.slug, this.title, this.icon);

  final String slug;
  final String title;
  final IconData icon;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

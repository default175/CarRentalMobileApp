import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_providers.dart';
import '../../../shared/models/app_role.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/car_review.dart';
import '../../../shared/models/geo_point.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../../tracking/presentation/gps_fullscreen_page.dart';
import '../../tracking/presentation/widgets/tracking_map_card.dart';

class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({this.onProfileTap, super.key});

  final VoidCallback? onProfileTap;

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  String? _selectedTrackedCarId;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).currentUser!;
    final cars = ref.watch(carsProvider);
    final bookings = ref.watch(bookingsControllerProvider);
    final isAdmin = user.role == AppRole.admin;
    final locationState = ref.watch(locationAccessControllerProvider);
    final locationLabel = locationState.currentLocation == null
        ? 'Tap to detect location'
        : _cityNameFor(locationState.currentLocation!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 104),
      children: [
        _LocationHeader(
          name: user.name,
          photoUrl: user.photoUrl,
          isAdmin: isAdmin,
          locationLabel: locationLabel,
          cars: cars.valueOrNull ?? const <Car>[],
          onLocationTap: () => ref
              .read(locationAccessControllerProvider.notifier)
              .requestAccess(),
          onProfileTap: widget.onProfileTap,
        ),
        const SizedBox(height: 14),
        cars.when(
          data: (items) => _DealCarousel(cars: items.take(5).toList()),
          loading: () => const _DealCarousel(cars: []),
          error: (_, __) => const _DealCarousel(cars: []),
        ),
        const SizedBox(height: 18),
        bookings.when(
          data: (items) => _BookingStrip(bookings: items, userId: user.id),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 18),
        cars.when(
          data: (items) => _AvailableCarsGrid(cars: items.take(4).toList()),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        if (isAdmin) ...[
          const SizedBox(height: 18),
          _AdminGpsPanel(
            selectedCarId: _selectedTrackedCarId,
            onSelectedCarChanged: (value) {
              setState(() {
                _selectedTrackedCarId = value;
              });
            },
          ),
        ],
      ],
    );
  }

  String _cityNameFor(GeoPoint point) {
    const knownCities = <({String name, double lat, double lng})>[
      (name: 'Almaty, Kazakhstan', lat: 43.2389, lng: 76.8897),
      (name: 'Astana, Kazakhstan', lat: 51.1694, lng: 71.4491),
      (name: 'Qyzylorda, Kazakhstan', lat: 44.8488, lng: 65.4823),
      (name: 'Shymkent, Kazakhstan', lat: 42.3417, lng: 69.5901),
      (name: 'Shanghai, China', lat: 31.2304, lng: 121.4737),
      (name: 'New York, USA', lat: 40.7128, lng: -74.0060),
      (name: 'London, UK', lat: 51.5072, lng: -0.1276),
      (name: 'Istanbul, Turkey', lat: 41.0082, lng: 28.9784),
    ];
    final nearest = knownCities.reduce((a, b) {
      final distanceA = (point.lat - a.lat) * (point.lat - a.lat) +
          (point.lng - a.lng) * (point.lng - a.lng);
      final distanceB = (point.lat - b.lat) * (point.lat - b.lat) +
          (point.lng - b.lng) * (point.lng - b.lng);
      return distanceA <= distanceB ? a : b;
    });
    return nearest.name;
  }
}

class _LocationHeader extends StatefulWidget {
  const _LocationHeader({
    required this.name,
    required this.photoUrl,
    required this.isAdmin,
    required this.locationLabel,
    required this.cars,
    required this.onLocationTap,
    this.onProfileTap,
  });

  final String name;
  final String? photoUrl;
  final bool isAdmin;
  final String locationLabel;
  final List<Car> cars;
  final VoidCallback onLocationTap;
  final VoidCallback? onProfileTap;

  @override
  State<_LocationHeader> createState() => _LocationHeaderState();
}

class _LocationHeaderState extends State<_LocationHeader> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Car> get _suggestions {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }
    return widget.cars
        .where((car) {
          return car.title.toLowerCase().contains(query) ||
              car.brand.toLowerCase().contains(query) ||
              car.model.toLowerCase().contains(query) ||
              '${car.year}'.contains(query) ||
              car.type.toLowerCase().contains(query) ||
              car.category.toLowerCase().contains(query) ||
              car.fuelType.toLowerCase().contains(query) ||
              car.drive.toLowerCase().contains(query) ||
              car.features
                  .any((feature) => feature.toLowerCase().contains(query));
        })
        .take(5)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = _suggestions;
    final profileImage = _profileImageProvider(widget.photoUrl) ??
        const NetworkImage(
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80',
        );
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 44),
              const Spacer(),
              Text(
                'Home',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: widget.onProfileTap,
                borderRadius: BorderRadius.circular(24),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: profileImage,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.isAdmin ? 'Fleet location' : 'Your location',
              style: const TextStyle(
                  color: Colors.white70, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: widget.onLocationTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  onChanged: (value) => setState(() => _query = value),
                  onSubmitted: (value) {
                    final encoded = Uri.encodeComponent(value.trim());
                    if (encoded.isNotEmpty) {
                      context.push('/screens/all-cars?query=$encoded');
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Search cars',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    prefixIcon:
                        Icon(Icons.search, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                ),
              ),
            ],
          ),
          if (suggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: suggestions
                    .map(
                      (car) => ListTile(
                        dense: true,
                        onTap: () => context.push('/cars/${car.id}'),
                        leading: Icon(
                          Icons.directions_car,
                          color: theme.colorScheme.primary,
                        ),
                        title: Text(car.title),
                        subtitle: Text(
                          '${car.year} - ${car.fuelType} - ${car.drive} drive',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.72),
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
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

class _DealCarousel extends StatelessWidget {
  const _DealCarousel({required this.cars});

  final List<Car> cars;

  @override
  Widget build(BuildContext context) {
    if (cars.isEmpty) {
      return const _DealBanner(car: null);
    }
    return SizedBox(
      height: 138,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.94),
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index == cars.length - 1 ? 0 : 10),
            child: _DealBanner(car: cars[index]),
          );
        },
      ),
    );
  }
}

class _DealBanner extends StatelessWidget {
  const _DealBanner({required this.car});

  final Car? car;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (car == null) {
          context.push('/screens/all-cars');
        } else {
          context.push('/cars/${car!.id}');
        }
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 138,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 18,
              bottom: 20,
              width: 155,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Cars',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Long term and short term',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    car == null
                        ? 'Open catalog'
                        : '${car!.pricePerHour.toStringAsFixed(0)} KZT / hour',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (car != null)
              Positioned(
                right: -10,
                top: 10,
                bottom: 10,
                width: 170,
                child: AppNetworkImage(
                  imageUrl: car!.displayImageUrl,
                  height: 118,
                  fit: BoxFit.cover,
                  borderRadius: 14,
                ),
              )
            else
              const Positioned(
                right: 28,
                top: 38,
                child:
                    Icon(Icons.directions_car, color: Colors.white, size: 76),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingStrip extends StatelessWidget {
  const _BookingStrip({
    required this.bookings,
    required this.userId,
  });

  final List<Booking> bookings;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final upcoming = bookings
        .where((booking) => booking.userId == userId && booking.isUpcoming)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'Bookings history',
          action: 'See all',
          onTap: () => context.push('/screens/my-bookings'),
        ),
        const SizedBox(height: 10),
        if (upcoming.isEmpty)
          const _EmptyState(text: 'Choose a car to create your first booking.')
        else
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: upcoming.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final booking = upcoming[index];
                return Container(
                  width: 250,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.carName,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(DateFormat('dd MMM, HH:mm')
                          .format(booking.startTime)),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${booking.totalPrice.toStringAsFixed(0)} KZT',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          Chip(label: Text(booking.status.name)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AvailableCarsGrid extends StatelessWidget {
  const _AvailableCarsGrid({required this.cars});

  final List<Car> cars;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: 'TOP DEALS',
          action: 'view all',
          onTap: () => context.push('/screens/all-cars'),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final crossAxisCount = width >= 1100
                ? 4
                : width >= 760
                    ? 3
                    : 2;
            final imageHeight =
                (width / crossAxisCount * 0.58).clamp(120.0, 220.0);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cars.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: width >= 760 ? 0.9 : 0.72,
              ),
              itemBuilder: (context, index) {
                final car = cars[index];
                return _MiniCarCard(car: car, imageHeight: imageHeight);
              },
            );
          },
        ),
      ],
    );
  }
}

class _MiniCarCard extends ConsumerWidget {
  const _MiniCarCard({required this.car, required this.imageHeight});

  final Car car;
  final double imageHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteCarIdsProvider);
    final reviews = ref.watch(carReviewsProvider);
    final favorite = favorites.contains(car.id);
    final rating = _averageRating(reviews, car.id);
    return Card(
      child: InkWell(
        onTap: () => context.push('/cars/${car.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppNetworkImage(
                imageUrl: car.displayImageUrl,
                height: imageHeight,
                width: double.infinity,
                borderRadius: 12,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
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
              ),
              const SizedBox(height: 2),
              Text(
                car.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Color(0xFFFFB020)),
                  const SizedBox(width: 3),
                  Text('${rating.toStringAsFixed(1)} | ${car.seats} seats'),
                ],
              ),
              const Spacer(),
              Text(
                '${car.pricePerHour.toStringAsFixed(0)} KZT/h',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
        ),
        const Spacer(),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            children: [
              Text(
                action,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminGpsPanel extends ConsumerWidget {
  const _AdminGpsPanel({
    required this.selectedCarId,
    required this.onSelectedCarChanged,
  });

  final String? selectedCarId;
  final ValueChanged<String?> onSelectedCarChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider);
    final bookings =
        ref.watch(bookingsControllerProvider).valueOrNull ?? const <Booking>[];
    final locationState = ref.watch(locationAccessControllerProvider);

    return cars.when(
      data: (carItems) {
        final rentedCarIds = bookings
            .where(_hasActiveTrackingStatus)
            .map((booking) => booking.carId)
            .toSet();
        final trackableCars = carItems
            .where((car) => rentedCarIds.contains(car.id))
            .toList(growable: false);

        if (trackableCars.isEmpty) {
          return const _EmptyState(text: 'No rented cars to track.');
        }

        final effectiveCar = trackableCars.firstWhere(
          (car) => car.id == selectedCarId,
          orElse: () => trackableCars.first,
        );
        if (selectedCarId != effectiveCar.id) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSelectedCarChanged(effectiveCar.id);
          });
        }

        final tracking = ref.watch(trackingStreamProvider(effectiveCar.id));
        return tracking.when(
          data: (snapshot) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Fleet GPS',
                      style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: 'Open map',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const GpsFullscreenPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_full),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: effectiveCar.id,
                decoration: const InputDecoration(labelText: 'Fleet car'),
                items: trackableCars
                    .map(
                      (car) => DropdownMenuItem<String>(
                        value: car.id,
                        child: Text(
                          '${car.title} - ${_renterLabel(car, bookings)}',
                        ),
                      ),
                    )
                    .toList(growable: false),
                onChanged: onSelectedCarChanged,
              ),
              const SizedBox(height: 10),
              TrackingMapCard(
                car: effectiveCar,
                snapshot: snapshot,
                userLocation: locationState.currentLocation,
                height: 260,
              ),
            ],
          ),
          loading: () => const _EmptyState(text: 'Loading fleet GPS.'),
          error: (_, __) =>
              const _EmptyState(text: 'Fleet GPS is unavailable.'),
        );
      },
      loading: () => const _EmptyState(text: 'Loading cars.'),
      error: (_, __) => const _EmptyState(text: 'Cars unavailable.'),
    );
  }

  String _renterLabel(Car car, List<Booking> bookings) {
    final booking = bookings
        .where((item) => item.carId == car.id && _hasActiveTrackingStatus(item))
        .firstOrNull;
    return booking?.userName ?? 'no active renter';
  }

  bool _hasActiveTrackingStatus(Booking item) {
    return item.status == BookingStatus.created ||
        item.status == BookingStatus.confirmed ||
        item.status == BookingStatus.active;
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

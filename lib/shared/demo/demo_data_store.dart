import '../../core/services/local_app_storage.dart';
import '../../core/services/push_notifications_service.dart';
import '../models/app_notification.dart';
import '../models/app_role.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/car.dart';
import 'demo_seed_data.dart';

class DemoDataStore {
  DemoDataStore(this._storage)
      : _users = _mergeUsers(
          DemoSeedData.users(),
          _storage.persistedUsers,
        ),
        _cars = List<Car>.from(DemoSeedData.cars()),
        _bookings = List<Booking>.from(DemoSeedData.bookings()),
        _notifications =
            List<AppNotification>.from(DemoSeedData.notifications()) {
    _notificationIds.addAll(_notifications.map((item) => item.id));
  }

  final LocalAppStorage _storage;
  final List<AppUser> _users;
  final List<Car> _cars;
  final List<Booking> _bookings;
  final List<AppNotification> _notifications;
  final Set<String> _notificationIds = <String>{};

  List<AppUser> get users => List.unmodifiable(_users);
  List<Car> get cars => List.unmodifiable(_cars);
  List<Booking> get bookings => List.unmodifiable(_bookings);
  List<AppNotification> get notifications {
    _refreshBookingNotifications();
    return List.unmodifiable(_notifications);
  }

  AppUser? findUserByEmail(String email) {
    return _users.where((user) => user.email == email).firstOrNull;
  }

  AppUser? findUserById(String userId) {
    return _users.where((user) => user.id == userId).firstOrNull;
  }

  Car? findCarById(String carId) {
    return _cars.where((car) => car.id == carId).firstOrNull;
  }

  void saveUser(AppUser user) {
    final index = _users.indexWhere((item) => item.id == user.id);
    if (index >= 0) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
    _persistUsers();
  }

  void toggleUserBlocked(String userId) {
    final user = findUserById(userId);
    if (user == null) {
      return;
    }

    saveUser(user.copyWith(isBlocked: !user.isBlocked));
  }

  void saveCar(Car car) {
    final index = _cars.indexWhere((item) => item.id == car.id);
    if (index >= 0) {
      _cars[index] = car;
    } else {
      _cars.add(car);
    }
  }

  void deleteCar(String carId) {
    _cars.removeWhere((car) => car.id == carId);
    _bookings.removeWhere((booking) => booking.carId == carId);
  }

  void createBooking({
    required AppUser user,
    required Car car,
    required DateTime startTime,
    required DateTime endTime,
  }) {
    if (!endTime.isAfter(startTime)) {
      throw StateError('The booking end time must be after the start time.');
    }

    final hasOverlap = _bookings.any(
      (booking) =>
          booking.carId == car.id &&
          _blocksSchedule(booking) &&
          startTime.isBefore(booking.endTime) &&
          endTime.isAfter(booking.startTime),
    );

    if (hasOverlap) {
      throw StateError(
        'This car is already booked for the selected period. Choose another date or time.',
      );
    }

    final durationMinutes = endTime.difference(startTime).inMinutes;
    final durationHours = (durationMinutes / 60).clamp(1, 24 * 14);
    final booking = Booking(
      id: 'booking-${_bookings.length + 1}',
      userId: user.id,
      userName: user.name,
      carId: car.id,
      carName: car.title,
      startTime: startTime,
      endTime: endTime,
      status: BookingStatus.created,
      totalPrice: car.pricePerHour * durationHours,
      distanceKm: 0,
      routeSummary: 'Awaiting vehicle pickup',
    );
    _bookings.insert(0, booking);
    _addNotification(
      AppNotification(
        id: 'booking-created-${booking.id}',
        title: 'Booking created',
        message:
            '${car.title} is reserved from ${booking.startTime.day.toString().padLeft(2, '0')}.${booking.startTime.month.toString().padLeft(2, '0')} ${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')} to ${booking.endTime.day.toString().padLeft(2, '0')}.${booking.endTime.month.toString().padLeft(2, '0')} ${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}.',
        type: AppNotificationType.booking,
        createdAt: DateTime.now(),
      ),
    );
  }

  void updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index < 0) {
      return;
    }

    final booking = _bookings[index].copyWith(status: status);
    _bookings[index] = booking;
    if (status == BookingStatus.cancelled) {
      _addNotification(
        AppNotification(
          id: 'booking-cancelled-${booking.id}',
          title: 'Booking cancelled',
          message: '${booking.carName} booking was cancelled.',
          type: AppNotificationType.booking,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  AppUser registerUser({
    required String name,
    required String email,
    required String phone,
    String? licenseNumber,
    AppRole role = AppRole.user,
  }) {
    final user = AppUser(
      id: 'user-${_users.length + 1}',
      name: name,
      email: email.trim().toLowerCase(),
      phone: phone,
      role: role,
      licenseNumber: licenseNumber,
      photoUrl: null,
      createdAt: DateTime.now(),
    );
    saveUser(user);
    return user;
  }

  void _persistUsers() {
    _storage.saveUsers(_users);
  }

  static List<AppUser> _mergeUsers(
    List<AppUser> seeded,
    List<AppUser> persisted,
  ) {
    final merged = <String, AppUser>{
      for (final user in seeded) user.id: user,
    };
    for (final user in persisted) {
      merged[user.id] = user;
    }
    return merged.values.toList(growable: true);
  }

  bool _blocksSchedule(Booking booking) {
    return booking.status != BookingStatus.cancelled &&
        booking.status != BookingStatus.completed;
  }

  void dismissNotification(String notificationId) {
    _notifications.removeWhere((item) => item.id == notificationId);
    _notificationIds.remove(notificationId);
  }

  void _refreshBookingNotifications() {
    final now = DateTime.now();
    for (final booking in _bookings) {
      if (!_blocksSchedule(booking)) {
        continue;
      }

      final untilStart = booking.startTime.difference(now);
      if (untilStart.inMinutes >= 0 && untilStart.inMinutes <= 120) {
        _addNotification(
          AppNotification(
            id: 'booking-start-${booking.id}',
            title: 'Rental starts soon',
            message:
                '${booking.carName} starts at ${booking.startTime.hour.toString().padLeft(2, '0')}:${booking.startTime.minute.toString().padLeft(2, '0')}.',
            type: AppNotificationType.reminder,
            createdAt: now,
          ),
        );
      }

      final untilEnd = booking.endTime.difference(now);
      if (untilEnd.inMinutes >= 0 && untilEnd.inMinutes <= 60) {
        _addNotification(
          AppNotification(
            id: 'booking-end-${booking.id}',
            title: 'Rental ends soon',
            message:
                '${booking.carName} ends at ${booking.endTime.hour.toString().padLeft(2, '0')}:${booking.endTime.minute.toString().padLeft(2, '0')}.',
            type: AppNotificationType.reminder,
            createdAt: now,
          ),
        );
      }
    }
  }

  void _addNotification(AppNotification notification) {
    if (_notificationIds.contains(notification.id)) {
      return;
    }

    _notificationIds.add(notification.id);
    _notifications.insert(0, notification);
    PushNotificationsService.instance?.showLocalNotification(
      notificationId: notification.id,
      title: notification.title,
      body: notification.message,
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

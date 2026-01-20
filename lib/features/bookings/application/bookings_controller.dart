import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/app_user.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../domain/bookings_repository.dart';

class BookingsController extends StateNotifier<AsyncValue<List<Booking>>> {
  BookingsController(this._repository) : super(const AsyncValue.loading()) {
    load();
  }

  final BookingsRepository _repository;

  Future<void> load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_repository.fetchBookings);
  }

  Future<void> createDemoBooking({
    required AppUser user,
    required Car car,
  }) async {
    final start = DateTime.now().add(const Duration(hours: 1));
    final end = start.add(const Duration(hours: 6));

    await _repository.createBooking(
      user: user,
      car: car,
      startTime: start,
      endTime: end,
    );

    await load();
  }

  Future<void> createBooking({
    required AppUser user,
    required Car car,
    required DateTime start,
    required DateTime end,
  }) async {
    await _repository.createBooking(
      user: user,
      car: car,
      startTime: start,
      endTime: end,
    );

    await load();
  }
}

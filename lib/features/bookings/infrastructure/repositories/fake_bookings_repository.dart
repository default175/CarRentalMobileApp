import '../../../../shared/demo/demo_data_store.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/booking.dart';
import '../../../../shared/models/car.dart';
import '../../domain/bookings_repository.dart';

class FakeBookingsRepository implements BookingsRepository {
  FakeBookingsRepository(this._store);

  final DemoDataStore _store;

  @override
  List<Booking> get bookings => _store.bookings;

  @override
  Future<void> createBooking({
    required AppUser user,
    required Car car,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _store.createBooking(
      user: user,
      car: car,
      startTime: startTime,
      endTime: endTime,
    );
  }

  @override
  Future<List<Booking>> fetchBookings() async {
    return bookings;
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    _store.updateBookingStatus(bookingId: bookingId, status: status);
  }
}

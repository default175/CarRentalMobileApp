import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';
import '../../../shared/models/app_user.dart';

abstract class BookingsRepository {
  List<Booking> get bookings;

  Future<List<Booking>> fetchBookings();
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  });

  Future<void> createBooking({
    required AppUser user,
    required Car car,
    required DateTime startTime,
    required DateTime endTime,
  });
}

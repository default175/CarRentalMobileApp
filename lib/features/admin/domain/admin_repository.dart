import '../../../shared/models/app_user.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/car.dart';

class AdminOverview {
  const AdminOverview({
    required this.users,
    required this.cars,
    required this.bookings,
    required this.activeTrips,
  });

  final List<AppUser> users;
  final List<Car> cars;
  final List<Booking> bookings;
  final int activeTrips;
}

abstract class AdminRepository {
  Future<AdminOverview> fetchOverview();
  Future<void> saveUser(AppUser user);
  Future<void> toggleUserBlocked(String userId);
  Future<void> saveCar(Car car);
  Future<void> deleteCar(String carId);
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  });
}

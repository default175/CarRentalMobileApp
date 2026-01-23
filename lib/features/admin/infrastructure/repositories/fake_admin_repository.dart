import '../../../../shared/demo/demo_data_store.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/booking.dart';
import '../../../../shared/models/car.dart';
import '../../domain/admin_repository.dart';

class FakeAdminRepository implements AdminRepository {
  FakeAdminRepository(this._store);

  final DemoDataStore _store;

  @override
  Future<AdminOverview> fetchOverview() async {
    final users = _store.users;
    final cars = _store.cars;
    final bookings = _store.bookings;

    return AdminOverview(
      users: users,
      cars: cars,
      bookings: bookings,
      activeTrips: bookings.where((booking) => booking.isActive).length,
    );
  }

  @override
  Future<void> deleteCar(String carId) async {
    _store.deleteCar(carId);
  }

  @override
  Future<void> saveCar(Car car) async {
    _store.saveCar(car);
  }

  @override
  Future<void> saveUser(AppUser user) async {
    _store.saveUser(user);
  }

  @override
  Future<void> toggleUserBlocked(String userId) async {
    _store.toggleUserBlocked(userId);
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    _store.updateBookingStatus(bookingId: bookingId, status: status);
  }
}

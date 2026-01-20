import '../../../../core/network/api_client.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/booking.dart';
import '../../../../shared/models/car.dart';
import '../../domain/bookings_repository.dart';

class ApiBookingsRepository implements BookingsRepository {
  ApiBookingsRepository(this._client);

  final ApiClient _client;
  List<Booking> _cache = const [];

  @override
  List<Booking> get bookings => List.unmodifiable(_cache);

  @override
  Future<void> createBooking({
    required AppUser user,
    required Car car,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    await _client.dio.post<void>(
      '/api/bookings',
      data: {
        'user_id': user.id,
        'user_name': user.name,
        'car_id': car.id,
        'car_name': car.title,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'total_price':
            car.pricePerHour * endTime.difference(startTime).inHours.clamp(1, 24),
      },
    );
  }

  @override
  Future<List<Booking>> fetchBookings() async {
    final response = await _client.dio.get<List<dynamic>>('/api/bookings');
    final items = response.data ?? const [];
    _cache = items
        .map((item) => _mapBooking(Map<String, dynamic>.from(item as Map)))
        .toList();
    return bookings;
  }

  @override
  Future<void> updateBookingStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    await _client.dio.patch<void>(
      '/api/bookings/$bookingId/status',
      data: {'status': status.name},
    );
  }

  Booking _mapBooking(Map<String, dynamic> raw) {
    return Booking(
      id: raw['id'] as String,
      userId: raw['user_id'] as String,
      userName: raw['user_name'] as String? ?? 'Unknown user',
      carId: raw['car_id'] as String,
      carName: raw['car_name'] as String,
      startTime: DateTime.parse(raw['start_time'] as String),
      endTime: DateTime.parse(raw['end_time'] as String),
      status: _statusFromString(raw['status'] as String),
      totalPrice: (raw['total_price'] as num).toDouble(),
      distanceKm: (raw['distance_km'] as num).toDouble(),
      routeSummary: raw['route_summary'] as String?,
    );
  }

  BookingStatus _statusFromString(String value) {
    switch (value) {
      case 'created':
        return BookingStatus.created;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'active':
        return BookingStatus.active;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
      default:
        return BookingStatus.cancelled;
    }
  }
}

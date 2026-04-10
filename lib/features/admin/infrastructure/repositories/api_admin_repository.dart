import '../../../../core/network/api_client.dart';
import '../../../../shared/models/app_role.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/models/booking.dart';
import '../../../../shared/models/car.dart';
import '../../../../shared/models/geo_point.dart';
import '../../domain/admin_repository.dart';

class ApiAdminRepository implements AdminRepository {
  ApiAdminRepository(this._client);

  final ApiClient _client;

  @override
  Future<AdminOverview> fetchOverview() async {
    final response =
        await _client.dio.get<Map<String, dynamic>>('/api/admin/overview');
    final data = response.data ?? const {};

    return AdminOverview(
      users: (data['users'] as List<dynamic>? ?? const [])
          .map((item) => _mapUser(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      cars: (data['cars'] as List<dynamic>? ?? const [])
          .map((item) => _mapCar(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      bookings: (data['bookings'] as List<dynamic>? ?? const [])
          .map((item) => _mapBooking(Map<String, dynamic>.from(item as Map)))
          .toList(growable: false),
      activeTrips: data['active_trips'] as int? ?? 0,
    );
  }

  @override
  Future<void> deleteCar(String carId) async {
    await _client.dio.delete<void>('/api/cars/$carId');
  }

  @override
  Future<void> saveCar(Car car) async {
    await _client.dio.put<void>(
      '/api/cars/${car.id}',
      data: {
        'brand': car.brand,
        'model': car.model,
        'year': car.year,
        'type': car.type,
        'category': car.category,
        'price_per_hour': car.pricePerHour,
        'status': car.status.name,
        'battery_level': car.batteryLevel,
        'range_km': car.rangeKm,
        'seats': car.seats,
        'transmission': car.transmission,
        'color': car.color,
        'description': car.description,
        'features': car.features,
        'fuel_type': car.fuelType,
        'gas_level': car.gasLevel,
        'engine_volume': car.engineVolume,
        'mileage_km': car.mileageKm,
        'drive': car.drive,
        'registered': car.registered,
        'image_url': car.imageUrl,
        'has_gps_signal': car.hasGpsSignal,
        'location': {
          'lat': car.location.lat,
          'lng': car.location.lng,
        },
      },
    );
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _client.dio.put<void>(
      '/api/users/${user.id}',
      data: {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role.name,
        'license_number': user.licenseNumber,
        'photo_url': user.photoUrl,
      },
    );
  }

  @override
  Future<void> toggleUserBlocked(String userId) async {
    await _client.dio.patch<void>('/api/users/$userId/toggle-block');
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

  AppUser _mapUser(Map<String, dynamic> raw) {
    return AppUser(
      id: raw['id'] as String,
      name: raw['name'] as String,
      email: raw['email'] as String,
      phone: raw['phone'] as String,
      role: (raw['role'] as String) == 'admin' ? AppRole.admin : AppRole.user,
      licenseNumber: raw['license_number'] as String?,
      photoUrl: raw['photo_url'] as String?,
      createdAt: raw['created_at'] == null
          ? null
          : DateTime.parse(raw['created_at'] as String),
      isBlocked: raw['blocked'] as bool? ?? false,
    );
  }

  Car _mapCar(Map<String, dynamic> raw) {
    final location = Map<String, dynamic>.from(raw['location'] as Map);

    return Car(
      id: raw['id'] as String,
      brand: raw['brand'] as String,
      model: raw['model'] as String,
      year: raw['year'] as int,
      type: raw['type'] as String,
      category: raw['category'] as String? ?? raw['type'] as String,
      pricePerHour: (raw['price_per_hour'] as num).toDouble(),
      status: _statusFromString(raw['status'] as String),
      location: GeoPoint(
        lat: (location['lat'] as num).toDouble(),
        lng: (location['lng'] as num).toDouble(),
      ),
      imageUrl: raw['image_url'] as String? ?? '',
      batteryLevel: raw['battery_level'] as int,
      rangeKm: raw['range_km'] as int,
      seats: raw['seats'] as int? ?? 5,
      transmission: raw['transmission'] as String? ?? 'Automatic',
      color: raw['color'] as String? ?? 'Unknown',
      description: raw['description'] as String? ?? 'No description provided.',
      features: (raw['features'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(growable: false),
      fuelType: raw['fuel_type'] as String? ?? 'Petrol',
      gasLevel: (raw['gas_level'] as num?)?.toInt(),
      engineVolume: (raw['engine_volume'] as num?)?.toDouble(),
      mileageKm: (raw['mileage_km'] as num?)?.toInt() ?? 0,
      drive: raw['drive'] as String? ?? 'front',
      registered: raw['registered'] as bool? ?? true,
      hasGpsSignal: raw['has_gps_signal'] as bool? ?? true,
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
      status: _bookingStatusFromString(raw['status'] as String),
      totalPrice: (raw['total_price'] as num).toDouble(),
      distanceKm: (raw['distance_km'] as num).toDouble(),
      routeSummary: raw['route_summary'] as String?,
    );
  }

  CarStatus _statusFromString(String value) {
    switch (value) {
      case 'available':
        return CarStatus.available;
      case 'booked':
        return CarStatus.booked;
      case 'inUse':
      case 'in_use':
        return CarStatus.inUse;
      case 'maintenance':
      default:
        return CarStatus.maintenance;
    }
  }

  BookingStatus _bookingStatusFromString(String value) {
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

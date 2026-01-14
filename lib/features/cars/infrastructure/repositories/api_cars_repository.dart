import '../../../../core/network/api_client.dart';
import '../../../../shared/models/car.dart';
import '../../../../shared/models/geo_point.dart';
import '../../domain/cars_repository.dart';

class ApiCarsRepository implements CarsRepository {
  ApiCarsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Car>> fetchCars() async {
    final response = await _client.dio.get<List<dynamic>>('/api/cars');
    final items = response.data ?? const [];

    return items
        .map((item) => _mapCar(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
  }

  @override
  Future<Car?> getCarById(String carId) async {
    final cars = await fetchCars();
    for (final car in cars) {
      if (car.id == carId) {
        return car;
      }
    }
    return null;
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
  Future<void> deleteCar(String carId) async {
    await _client.dio.delete<void>('/api/cars/$carId');
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
      hasGpsSignal: raw['has_gps_signal'] as bool? ?? true,
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
}

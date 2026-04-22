import 'geo_point.dart';

enum CarStatus {
  available,
  booked,
  inUse,
  maintenance,
}

class Car {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.type,
    required this.category,
    required this.pricePerHour,
    required this.status,
    required this.location,
    required this.imageUrl,
    required this.batteryLevel,
    required this.rangeKm,
    required this.seats,
    required this.transmission,
    required this.color,
    required this.description,
    required this.features,
    this.fuelType = 'Petrol',
    this.gasLevel,
    this.engineVolume,
    this.mileageKm = 0,
    this.drive = 'front',
    this.registered = true,
    this.hasGpsSignal = true,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final String type;
  final String category;
  final double pricePerHour;
  final CarStatus status;
  final GeoPoint location;
  final String imageUrl;
  final int batteryLevel;
  final int rangeKm;
  final int seats;
  final String transmission;
  final String color;
  final String description;
  final List<String> features;
  final String fuelType;
  final int? gasLevel;
  final double? engineVolume;
  final int mileageKm;
  final String drive;
  final bool registered;
  final bool hasGpsSignal;

  String get title => '$brand $model';

  bool get isElectric => fuelType.toLowerCase() == 'electric';

  String get fuelLabel => isElectric ? 'Battery' : 'Gas';

  String get energyValue =>
      isElectric ? '$batteryLevel%' : '${gasLevel ?? 70}%';

  String get displayImageUrl {
    if (imageUrl.trim().isNotEmpty) {
      return imageUrl.trim();
    }

    final key = '$brand $model'.toLowerCase();
    if (key.contains('tesla')) {
      return 'https://images.unsplash.com/photo-1560958089-b8a1929cea89?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('nissan leaf')) {
      return 'https://images.unsplash.com/photo-1593941707882-a5bba53b0999?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('bmw x5')) {
      return 'https://images.unsplash.com/photo-1556189250-72ba954cfc2b?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('range rover')) {
      return 'https://images.unsplash.com/photo-1563720223185-11003d516935?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('audi a6')) {
      return 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('volkswagen') || key.contains('passat')) {
      return 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('honda accord')) {
      return 'https://images.unsplash.com/photo-1619767886558-efdc259cde1a?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('chevrolet camaro')) {
      return 'https://images.unsplash.com/photo-1612825173281-9a193378527e?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('hyundai staria')) {
      return 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('hyundai') || key.contains('sonata')) {
      return 'https://images.unsplash.com/photo-1617469767053-d3b523a0b982?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('toyota') || key.contains('rav4')) {
      return 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('kia')) {
      return 'https://images.unsplash.com/photo-1619682817481-e994891cd1f5?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('nissan')) {
      return 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('mercedes')) {
      return 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('ford')) {
      return 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=80';
    }
    if (key.contains('renault')) {
      return 'https://images.unsplash.com/photo-1542362567-b07e54358753?auto=format&fit=crop&w=1200&q=80';
    }
    return 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80';
  }

  Car copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    String? type,
    String? category,
    double? pricePerHour,
    CarStatus? status,
    GeoPoint? location,
    String? imageUrl,
    int? batteryLevel,
    int? rangeKm,
    int? seats,
    String? transmission,
    String? color,
    String? description,
    List<String>? features,
    String? fuelType,
    int? gasLevel,
    double? engineVolume,
    int? mileageKm,
    String? drive,
    bool? registered,
    bool? hasGpsSignal,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      type: type ?? this.type,
      category: category ?? this.category,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      status: status ?? this.status,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      rangeKm: rangeKm ?? this.rangeKm,
      seats: seats ?? this.seats,
      transmission: transmission ?? this.transmission,
      color: color ?? this.color,
      description: description ?? this.description,
      features: features ?? this.features,
      fuelType: fuelType ?? this.fuelType,
      gasLevel: gasLevel ?? this.gasLevel,
      engineVolume: engineVolume ?? this.engineVolume,
      mileageKm: mileageKm ?? this.mileageKm,
      drive: drive ?? this.drive,
      registered: registered ?? this.registered,
      hasGpsSignal: hasGpsSignal ?? this.hasGpsSignal,
    );
  }
}

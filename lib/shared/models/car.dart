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
  final bool hasGpsSignal;

  String get title => '$brand $model';

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
      hasGpsSignal: hasGpsSignal ?? this.hasGpsSignal,
    );
  }
}
